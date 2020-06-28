/*
   disasm.c

   Copyright (c) 2014 by Daniel Kelley

*/

#include "config.h"
#if !defined PACKAGE && !defined PACKAGE_VERSION
#error config.h malformed
#endif
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <inttypes.h>
#include <limits.h>
#include <unistd.h>
#include <endian.h>
#include <bfd.h>
#include <dis-asm.h>
#include <libgen.h>

/* PAREN_VOCS_OFFSET could be generated */
#define PAREN_VOCS_OFFSET 34

#define U32_PTR(x) ((uint32_t *)(x))
#define U64_PTR(x) ((uint64_t *)(x))
#define UCHAR_PTR(x) ((unsigned char *)(x))
#define ALIGNED(x) (((x) & (wl - 1)) == 0)
#define LEX_MASK 0x1f
#define NAME_LEN (LEX_MASK+1)
#define OP_LEN 64
#define COUNT(a) (sizeof((a))/sizeof((a)[0]))

typedef int (*is_does_comma_f)(const bfd_byte *data);

struct info
{
  int rc;
  bfd_byte *text;
  uint64_t text_size;
  asection *text_section;
  uint64_t text_vma;
  bfd_byte *data;
  uint64_t data_size;
  asection *data_section;
  uint64_t data_vma;
  asymbol **usersym;
  asymbol **doessym;
  asymbol **exitsym;
  asymbol **dovoc_romsym;
  uint64_t voc_head_vma;
};

struct disassembler
{
  bfd *abfd;
  disassembler_ftype disassemble;
  struct disassemble_info info;
  uint64_t size;
  uint64_t vma;
  const bfd_byte *data;
  char buf[OP_LEN];
} bfd_disassembler;

struct dict_entry
{
  uint64_t cfa;
  uint64_t nfa;
  char name[NAME_LEN];
};

static int verbose;
static char *prog;

static asymbol **symtab;
static long sym_count;
static asymbol **sym_by_name; /* sorted by name */
static asymbol **sym_by_value; /* sorted by address */

static int dict_max;
static int dict_count;
static struct dict_entry *dict;

static int interp_max;
static int interp_count;
static struct dict_entry *interp;

static unsigned int wl; /* word length */
static uint32_t (*to_h_uint32_t)(uint32_t t_uint32);
static uint64_t (*to_h_uint64_t)(uint64_t t_uint64);
static is_does_comma_f is_does_comma;

static int is_does_comma_x86(const bfd_byte *data);
static int is_does_comma_mmix(const bfd_byte *data);
static int is_does_comma_arm32(const bfd_byte *data);
static int is_does_comma_thumb32(const bfd_byte *data);
static int is_does_comma_arm64(const bfd_byte *data);
static int is_does_comma_mips32(const bfd_byte *data);
static int is_does_comma_riscv(const bfd_byte *data);

static struct does_comma_checker_s {
  const char *target;
  is_does_comma_f checker;
} does_comma_checker[] = {
  {"i386", is_does_comma_x86},
  {"i386:x86-64", is_does_comma_x86},
  {"mmix", is_does_comma_mmix},
  {"armv5t", is_does_comma_arm32},
  {"arm", is_does_comma_thumb32},
  {"aarch64", is_does_comma_arm64},
  {"mips:3000", is_does_comma_mips32},
  {"mips:4000", is_does_comma_mips32},
  {"riscv:rv32", is_does_comma_riscv},
  {"riscv:rv64", is_does_comma_riscv},
};

/* compare symbols by name */
static int symcmp_sort_name(const void *a, const void *b)
{
  const asymbol **sa = (const asymbol **)a;
  const asymbol **sb = (const asymbol **)b;
  return strcmp(bfd_asymbol_name(*sa), bfd_asymbol_name(*sb));
}

/* compare symbols by name */
static int symcmp_sort_value(const void *a, const void *b)
{
  const asymbol **sa = (const asymbol **)a;
  const asymbol **sb = (const asymbol **)b;
  uint64_t va,vb;
  int result;

  va = bfd_asymbol_value(*sa);
  vb = bfd_asymbol_value(*sb);
  result = (va - vb);

  if (!result) {
    result = strcmp(bfd_asymbol_name(*sa), bfd_asymbol_name(*sb));
  }

  return result;
}

/* search symbols by name */
static int symcmp_search_name(const void *a, const void *b)
{
  const char *name = (const char *)a;
  const asymbol **sb = (const asymbol **)b;
  return strcmp(name, bfd_asymbol_name(*sb));
}

/* search symbols by name */
static int symcmp_search_value(const void *a, const void *b)
{
  uint64_t va = *(uint64_t *)a;
  const asymbol **sb = (const asymbol **)b;
  uint64_t vb;

  vb = bfd_asymbol_value(*sb);
  return va - vb;
}

/* endian conversion functions */
uint32_t d_be32toh(uint32_t big_endian_32bits)
{
  return be32toh(big_endian_32bits);
}

uint32_t d_le32toh(uint32_t little_endian_32bits)
{
  return le32toh(little_endian_32bits);
}

uint64_t d_be64toh(uint64_t big_endian_64bits)
{
  return be64toh(big_endian_64bits);
}

uint64_t d_le64toh(uint64_t little_endian_64bits)
{
  return le64toh(little_endian_64bits);
}


/* get a word from target via word pointer address */
static uint64_t word_at(const bfd_byte *data)
{
  uint64_t w = 0;
  switch (wl) {
  case sizeof(uint32_t):
    w = to_h_uint32_t(*U32_PTR(data));
    break;
  case sizeof(uint64_t):
    w = to_h_uint64_t(*U64_PTR(data));
    break;
  default:
    assert(0);
    break;
  }

  return w;
}

static int scan_sym(bfd *abfd)
{
  int rc = 1;
  long size;
  int i;

  do {
    size = bfd_get_symtab_upper_bound(abfd);
    if (size <= 0) {
      bfd_perror(prog);
      break;
    }


    symtab = malloc(size);
    if (symtab == NULL) {
      perror(prog);
      break;
    }
    sym_count = bfd_canonicalize_symtab(abfd, symtab);
    if (sym_count < 0) {
      bfd_perror(prog);
      break;
    }

    sym_by_name = calloc(sym_count, sizeof(sym_by_name[0]));
    if (sym_by_name == NULL) {
      perror(prog);
      break;
    }

    sym_by_value = calloc(sym_count, sizeof(sym_by_value[0]));
    if (sym_by_value == NULL) {
      perror(prog);
      break;
    }

    for (i=0; i<sym_count; i++) {
      sym_by_name[i] = symtab[i];
      sym_by_value[i] = symtab[i];
    }
    qsort(sym_by_name, sym_count, sizeof(sym_by_name[0]), symcmp_sort_name);
    qsort(sym_by_value, sym_count, sizeof(sym_by_name[0]), symcmp_sort_value);

    rc = 0;
  } while (0);

  return rc;
}

static asymbol **lookup_sym_name(const char *name)
{
  return
    bsearch(name,
            sym_by_name,
            sym_count, sizeof(sym_by_name[0]),
            symcmp_search_name);
}

static asymbol **lookup_sym_value(uint64_t value)
{
  return
    bsearch(&value,
            sym_by_value,
            sym_count, sizeof(sym_by_value[0]),
            symcmp_search_value);
}

static void show_labels(asymbol **labels)
{
  asymbol *base = *labels;
  int count = 0;

  while (*labels && base->value == (*labels)->value) {
    const char *name = bfd_asymbol_name(*labels);
    if (name) {
      printf("%s<%s>:\n", count==0?"\n":"", name);
    }
    labels++;
    count++;
  }
}

static void dump_mem(const bfd_byte *data,
                     uint64_t len,
                     uint64_t vma __attribute__((unused)),
                     int bpl,
                     asymbol **labels)
{
  unsigned int i, j;
  int machine = 0;
  unsigned int ubpl;
  if (bpl < 0) {
    ubpl = -bpl;
    machine = 1;
  } else {
    ubpl = bpl;
  }

  if (labels) {
    show_labels(labels);
  }

  for (i=0; i<len; i += bpl) {
    printf("%8"PRIx64, vma+i);
    for (j=0; j<ubpl; j++) {
      if ((i+j) < len) {
        printf(" %02x", data[i+j]);
      } else {
        printf("   ");
      }
    }
    /* Make ASCII dump aligned regardless of bpl */
    for (;j<wl; j++) {
      printf("   ");
    }
    if (machine) {
      return; /* yeah it's a hack */
    }
    printf("   ");
    for (j=0; j<ubpl; j++) {
      if ((i+j) < len) {
        bfd_byte c = data[i+j];
        printf("%c", isprint(c)?c:'.');
      } else {
        break;
      }
    }
    printf("\n");
  }

}

#define UNSMUDGED(x) (((x) & 0x80) == 0x80)

static int dict_sort(const void *a, const void *b)
{
  struct dict_entry *da = (struct dict_entry *)a;
  struct dict_entry *db = (struct dict_entry *)b;

  return da->cfa - db->cfa;
}

static int dict_search(const void *a, const void *b)
{
  uint64_t cfa = *(uint64_t *)a;
  struct dict_entry *sb = (struct dict_entry *)b;

  return cfa - sb->cfa;
}

static void extract_name(char *buf, const bfd_byte *data)
{
  int n = *data++;

  n &= LEX_MASK;

  memset(buf, 0, NAME_LEN);
  memcpy(buf, data, n);
}

static void add_interp(uint64_t itp, uint64_t nfa)
{
  struct dict_entry *entry = bsearch(&itp, interp,
                                      interp_count, sizeof(interp[0]),
                                      dict_search);

  assert(interp_count < interp_max);
  if (!entry) {
    interp[interp_count].cfa = itp;
    interp[interp_count].nfa = nfa;
    if (nfa) {
      /* code word */
      strcpy(interp[interp_count].name, "CODE");
    }
    interp_count++;
    qsort(interp,
          interp_count, sizeof(interp[0]),
          dict_sort);
  }
}

static void add_cfa(uint64_t cfa, uint64_t nfa, const bfd_byte *name)
{
  assert(dict_count < dict_max);
  dict[dict_count].cfa = cfa;
  dict[dict_count].nfa = nfa;
  extract_name(dict[dict_count].name, name);
  dict_count++;
}

static void finish_dict(void)
{
  qsort(dict, dict_count, sizeof(dict[0]), dict_sort);
}

static void finish_interp(const bfd_byte *data __attribute__((unused)),
                          uint64_t size __attribute__((unused)),
                          uint64_t vma __attribute__((unused)))
{
  int i,j;
  /*
    Scan through the interpreters associating a name with
    any entries that don't have one, usually does> or ;code defs.

    Note: by definition, any word using an interpreter must have that
    interpreter defined before the word, so even though this won't
    corrently resolve an interpreter that is the last word in the
    dictionary, this won't arise in practice anyway, so it's a corner
    case we'll ignore. gmpfc does allow forward references, but these
    references are very early anyway.
   */

  for (i=0; i<interp_count; i++) {
    if (!interp[i].nfa) {
      for (j=0; j<dict_count; j++) {
        if (dict[j].nfa > interp[i].cfa) {
          /* Went past an entry just beyond the interpreter address,
           so the *previous* nfa was the one we are looking for. */
          break;
        } else {
          interp[i].nfa = dict[j].nfa; /* could be... */
          strcpy(interp[i].name, dict[j].name);
        }
      }
    }
  }
}

static void mark_dict_entry(const bfd_byte *data,
                            uint64_t size __attribute__((unused)),
                            uint64_t vma,
                            uint64_t entry,
                            unsigned char *dis_op)
{
  /*
    link
    lex
    name
    pad
    cfa
    pfa
   */
  uint64_t idx = entry - vma;
  uint64_t itp;
  uint64_t nfa;
  uint64_t cfa;
  int lex;
  int i;
  int is_code;

  assert(ALIGNED(vma));
  assert(ALIGNED(entry));
  assert(ALIGNED(idx));

  /* link */
  dis_op[idx] = 'w';
  idx += wl;

  /* lex */
  nfa = vma+idx;
  assert(ALIGNED(idx));
  dis_op[idx] = 'b';
  lex = data[idx];
  assert(UNSMUDGED(lex));
  lex &= LEX_MASK;
  idx++;

  /* name */
  assert(!ALIGNED(idx));
  for (i=0; i<lex; i++) {
    dis_op[idx] = 'b';
    idx++;
  }

  /* pad */
  while (!ALIGNED(idx)) {
    dis_op[idx] = 'b';
    idx++;
  }
  assert(ALIGNED(idx));

  /* code */
  dis_op[idx] = 'c';
  cfa = vma+idx;
  itp = word_at(data+idx);
  idx += wl;
  /* parameter */
  assert(ALIGNED(idx));
  is_code = ((itp-vma) == idx);
  dis_op[idx] = is_code ? 'a' : 'w';
  add_interp(itp, is_code ? nfa : 0);
  add_cfa(cfa,nfa,data+nfa-vma);
}

static int is_does_comma_x86(const bfd_byte *data)
{
  unsigned char a[4];
  unsigned char b[4] = {0x90, 0x90, 0x90, 0xe8};
  a[0] = *UCHAR_PTR(data+0);
  a[1] = *UCHAR_PTR(data+1);
  a[2] = *UCHAR_PTR(data+2);
  a[3] = *UCHAR_PTR(data+3);
  /* same in i386 or x86_64 */

  return !memcmp(a,b,sizeof(a));
}

static int is_does_comma_mmix(const bfd_byte *data)
{
  unsigned char a[8];
  unsigned char b[8] = {0xfd, 0x00, 0x00, 0x00, 0x9f, 0xff, 0xfe, 0x00};
  a[0] = *UCHAR_PTR(data+0);
  a[1] = *UCHAR_PTR(data+1);
  a[2] = *UCHAR_PTR(data+2);
  a[3] = *UCHAR_PTR(data+3);
  a[4] = *UCHAR_PTR(data+4);
  a[5] = *UCHAR_PTR(data+5);
  a[6] = *UCHAR_PTR(data+6);
  a[7] = *UCHAR_PTR(data+7);

  return !memcmp(a,b,sizeof(a));
}

static int is_does_comma_arm32(const bfd_byte *data)
{
  unsigned char a[1];
  unsigned char b[1] = {0xeb};
  a[0] = *UCHAR_PTR(data+0);

  return !memcmp(a,b,sizeof(a));
}

/*
  Thumb encoding

  11j1kbbb bbbbbbbb 11110saa aaaaaaaa
  11010000 00000000 11110000 00000000 value
  11010000 00000000 11111000 00000000 mask
 */
static int is_does_comma_thumb32(const bfd_byte *data)
{
  unsigned char a[4];
  unsigned char b[4] = {0xd0, 0x00, 0xf0, 0x00};
  unsigned char m[4] = {0xd0, 0x00, 0xf8, 0x00};


  a[0] = *UCHAR_PTR(data+0) & m[0];
  a[1] = *UCHAR_PTR(data+1) & m[1];
  a[2] = *UCHAR_PTR(data+2) & m[2];
  a[3] = *UCHAR_PTR(data+3) & m[3];

  return !memcmp(a,b,sizeof(a));
}

static int is_does_comma_arm64(const bfd_byte *data)
{
  unsigned char a[8];
  unsigned char b[8] = {0x1f, 0x20, 0x03, 0xd5, 0x00, 0x00, 0x00, 0x94};
  unsigned char m[8] = {0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0xfc};
  a[0] = *UCHAR_PTR(data+0) & m[0];
  a[1] = *UCHAR_PTR(data+1) & m[1];
  a[2] = *UCHAR_PTR(data+2) & m[2];
  a[3] = *UCHAR_PTR(data+3) & m[3];
  a[4] = *UCHAR_PTR(data+4) & m[4];
  a[5] = *UCHAR_PTR(data+5) & m[5];
  a[6] = *UCHAR_PTR(data+6) & m[6];
  a[7] = *UCHAR_PTR(data+7) & m[7];

  return !memcmp(a,b,sizeof(a));
}

static int is_does_comma_mips32(const bfd_byte *data)
{
  unsigned char a[8];
  unsigned char b[8] = {0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  unsigned char m[8] = {0xff, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff};
  a[0] = *UCHAR_PTR(data+0) & m[0];
  a[1] = *UCHAR_PTR(data+1) & m[1];
  a[2] = *UCHAR_PTR(data+2) & m[2];
  a[3] = *UCHAR_PTR(data+3) & m[3];
  a[4] = *UCHAR_PTR(data+4) & m[4];
  a[5] = *UCHAR_PTR(data+5) & m[5];
  a[6] = *UCHAR_PTR(data+6) & m[6];
  a[7] = *UCHAR_PTR(data+7) & m[7];

  return !memcmp(a,b,sizeof(a));
}

static int is_does_comma_riscv(const bfd_byte *data)
{
  unsigned char a[4];
  unsigned char b[4] = {0xef, 0x00, 0x00, 0x00};
  unsigned char m[4] = {0xff, 0x00, 0x00, 0x00};
  a[0] = *UCHAR_PTR(data+0) & m[0];
  a[1] = *UCHAR_PTR(data+1) & m[1];
  a[2] = *UCHAR_PTR(data+2) & m[2];
  a[3] = *UCHAR_PTR(data+3) & m[3];

  return !memcmp(a,b,sizeof(a));
}

static void mark_paren_semi_code(const bfd_byte *data,
                                 uint64_t size,
                                 uint64_t vma,
                                 unsigned char *dis_op)
{
  uint64_t colon_cfa = 0;
  uint64_t dolit_cfa = 0;
  uint64_t pscode_cfa = 0;
  int i;

  /* Scan all colon definitons for instances of (;code) not preceded
     by (dolit) and mark words following until the next entry as
     assembly.

     What's a little tricky is to also recognize a does> sequence and
     to terminate the disassembly at that point.

     Both x86_64 and i386 use the same call sequence to align the
     end of the code sequence on a cell boundry:

       90             nop
       90             nop
       90             nop
       e8 .. .. .. .. call <>

  */

  /* find colon */
  for (i=0; i<interp_count; i++) {
    if (!strcmp(interp[i].name, ":")) {
      colon_cfa = interp[i].cfa;
      break;
    }
  }

  /* find (dolit) (;code) */
  for (i=0; i<dict_count; i++) {
    if (!strcmp(dict[i].name, "(dolit)")) {
      dolit_cfa = dict[i].cfa;
    } else if (!strcmp(dict[i].name, "(;code)")) {
      pscode_cfa = dict[i].cfa;
    }
  }

  /* scan colon defs */
  for (i=0; i<dict_count; i++) {
    if (word_at(data + dict[i].cfa - vma) == colon_cfa) {
      uint64_t p;
      uint64_t q;
      uint64_t w;
      int mark;
      /* get parameter field boundries */
      p = dict[i].cfa + wl;
      q = (i<(dict_count-1)) ? dict[i+1].nfa-wl : (vma+size);
      p -= vma;
      q -= vma;
      mark = 0;

      /* Only need to mark word boundries; ops will get expanded later */
      for (;p<q; p += wl) {
        if (mark) {
          dis_op[p] = 'a';
        } else {
          w = word_at(data+p);
          if (w == dolit_cfa) {
            p += wl;
            /* FIXME - check (s") (c") */
          } else if (w == pscode_cfa) {
            if (is_does_comma(data+p+wl)) { /* arch dependent */
              p += wl;
              dis_op[p] = 'a';
              p += wl;
              dis_op[p] = 'w';
              p += wl;
            } else {
              mark = 1;
            }
          }
        }
      }


      if (mark && p < size && dis_op[p] == 0) {
        dis_op[p] = 'w';
      }
    }
  }
}

static void mark_does(struct info *info,
                      uint64_t size,
                      uint64_t vma,
                      unsigned char *dis_op)
{
  uint64_t does = bfd_asymbol_value(*info->doessym);

  if (does > vma && does < (vma+size)) {
    dis_op[does-vma] = 'a';
  } else {
    fprintf(stderr, "warning: does in different section\n");
  }
}

static void scan_voc(const bfd_byte *data,
                     uint64_t size,
                     uint64_t vma,
                     uint64_t link_vma,
                     unsigned char *dis_op,
                     struct info *info)
{
  link_vma = word_at(data + link_vma - vma);
  if (info->dovoc_romsym) {
    /* ROMable vocabulary first parameter word has another level of
     * indirection that points the head of the vocabulary list in the
     * data segment. The resulting VMA should be in the text segment.
     */
    link_vma = word_at(info->data + link_vma - info->data_vma);
  }
  while (link_vma != 0) {
    mark_dict_entry(data,size,vma,link_vma,dis_op);
    link_vma = word_at(data + link_vma - vma);
  }
}

static unsigned char *scan_dict(const bfd_byte *data,
                                uint64_t size,
                                uint64_t vma,
                                struct info *info)
{
  uint64_t voc_vma = info->voc_head_vma;
  uint64_t voc_link;
  unsigned char *dis_op;

  do {
    dis_op = calloc(size,sizeof(dis_op[0]));
    if (!dis_op) {
      perror(prog);
      break;
    }

    assert(wl != 0);
    dict_max = (size/(4*wl));
    dict_count = 0;
    dict = calloc(dict_max, sizeof(dict[0]));
    if (!dict) {
      perror(prog);
      free(dis_op);
      dis_op = NULL;
      break;
    }

    interp_max = dict_max;
    interp_count = 0;
    interp = calloc(interp_max, sizeof(interp[0]));
    if (!interp) {
      perror(prog);
      free(interp);
      free(dis_op);
      dis_op = NULL;
      break;
    }

    while (voc_vma != 0) {
      scan_voc(data, size, vma, voc_vma, dis_op, info);
      voc_link = voc_vma + wl;
      voc_vma = word_at(data + voc_link - vma);
    }

    finish_dict();
    finish_interp(data,size,vma);

    mark_paren_semi_code(data, size, vma, dis_op);

    if (info->doessym != NULL) {
      mark_does(info, size, vma, dis_op);
    }

  } while (0);

  return dis_op;
}

static void dump_symbol(const bfd_byte *data,
                        uint64_t len,
                        uint64_t vma,
                        int bpl)
{
  dump_mem(data, len, vma, bpl, lookup_sym_value(vma));
}

static int contig_ops(unsigned char *dis_op, uint64_t size, unsigned int idx)
{
  int n = 1;
  unsigned char op = dis_op[idx++];

  while ((idx < size) && ((dis_op[idx] == op) || (dis_op[idx] == 0))) {
    n++;
    idx++;
  }

  return n;
}

static int read_memory(bfd_vma memaddr,
                       bfd_byte *myaddr,
                       unsigned int length,
                       struct disassemble_info *info)
{
  struct disassembler *d = info->application_data;
  const void *from = d->data + memaddr - d->vma;
  memcpy(myaddr, from, length);
  return 0;
}

static void memory_error(int status,
                         bfd_vma memaddr,
                         struct disassemble_info *info __attribute__((unused)))
{
  fprintf(stderr, "%s: disassembler error %d reading %"PRIx64"x\n",
          prog, status, (uint64_t)memaddr);
  exit(2);
}

static void print_address(bfd_vma addr,
                          struct disassemble_info *info __attribute__((unused)))
{
  int len;
  asymbol **labels;

  len = strlen(bfd_disassembler.buf);
  labels = lookup_sym_value(addr);

  if (labels) {
    snprintf(bfd_disassembler.buf+len,
             sizeof(bfd_disassembler.buf)-len,
             "%8"PRIx64" <%s>", (uint64_t)addr, bfd_asymbol_name(*labels));
  } else {
    snprintf(bfd_disassembler.buf+len,
             sizeof(bfd_disassembler.buf)-len,
             "%8"PRIx64, (uint64_t)addr);
  }
}

static int disasm_fprintf(FILE *stream __attribute__((unused)),
                          const char *format, ...)
{
  int rc;
  int len;
  va_list ap;

  len = strlen(bfd_disassembler.buf);
  va_start(ap, format);
  rc = vsnprintf(bfd_disassembler.buf+len,
                 sizeof(bfd_disassembler.buf)-len,
                 format, ap);
  va_end(ap);

  return rc;
}

static int setup_machine(struct disassembler *d)
{
  d->info.flavour = bfd_get_flavour(d->abfd);
  d->info.arch = bfd_get_arch(d->abfd);
  d->info.mach = bfd_get_mach(d->abfd);
  d->info.disassembler_options = "";
  d->info.octets_per_byte = bfd_arch_mach_octets_per_byte
    (bfd_get_arch_info(d->abfd)->arch, bfd_get_arch_info(d->abfd)->mach);
  d->info.skip_zeroes = 0;
  d->info.skip_zeroes_at_end = 0;
  d->info.disassembler_needs_relocs = FALSE;

  if (bfd_big_endian(d->abfd)) {
    d->info.display_endian = d->info.endian = BFD_ENDIAN_BIG;
    to_h_uint32_t = d_be32toh;
    to_h_uint64_t = d_be64toh;
  } else if (bfd_little_endian(d->abfd)) {
    d->info.display_endian = d->info.endian = BFD_ENDIAN_LITTLE;
    to_h_uint32_t = d_le32toh;
    to_h_uint64_t = d_le64toh;
  } else {
    d->info.endian = BFD_ENDIAN_UNKNOWN;
    fprintf(stderr, "error: target endian is unknown");
    assert(0);
  }
  d->info.fprintf_func = (fprintf_ftype)disasm_fprintf;
  d->info.stream = stdout;
  d->info.application_data = d;
  /* d->info.section set later */
  /* d->info.symbols set later */
  /* d->info.num_symbols set later */
  d->info.read_memory_func = read_memory;
  d->info.memory_error_func = memory_error;
  d->info.print_address_func = print_address;

  d->disassemble = disassembler(d->info.arch,
                                (d->info.endian == BFD_ENDIAN_BIG),
                                d->info.mach,
                                d->abfd);

  return (d->disassemble != NULL);
}

static int setup_mach_deps(void)
{
  int ok = 0;
  unsigned int i;
  const char *target = bfd_printable_name(bfd_disassembler.abfd);
  for (i=0; i<COUNT(does_comma_checker); i++) {
    if (!strcmp(target, does_comma_checker[i].target)) {
      is_does_comma = does_comma_checker[i].checker;
      ok = 1;
      break;
    }
  }
  return ok;
}

static uint64_t disasm_machine(const bfd_byte *data,
                               uint64_t size,
                               uint64_t vma,
                               unsigned char *dis_op,
                               uint64_t idx)
{
  unsigned int n,m;
  uint64_t idx0, idx1;

  idx0 = idx;
  if (dis_op) {
    n = contig_ops(dis_op, size, idx);
  } else {
    n = size;
  }
  idx1 = idx0 + n;

  assert((idx + n) <= size);
  while (idx < idx1) {
    memset(bfd_disassembler.buf, 0, sizeof(bfd_disassembler.buf));
    m = bfd_disassembler.disassemble(vma+idx, &bfd_disassembler.info);
    dump_mem(data+idx, m, vma+idx, -wl, lookup_sym_value(vma+idx));
    printf(" | %s\n", bfd_disassembler.buf);
    if ((idx + m) <= idx1) {
      idx += m;
    } else {
      /* stop disassembly if slopped over section limit */
      break;
    }
    /*assert(idx <= size);*/
  }
  if (idx < idx1) {
    /* not everything got disassembled */
    dump_symbol(data+idx, idx1-idx, vma+idx, wl);
  }
  return idx1;
}

/* Vertical bar '|' is used as a marker for 'liveness' and must be in
   the same column for code and colon dumps. */
#define WIDTH  ((wl * (wl/4)))

static void spaces(int n)
{
  while (n--) {
    printf(" ");
  }
}

static uint64_t disasm_word(const bfd_byte *data,
                            uint64_t size,
                            uint64_t vma,
                            unsigned char *dis_op,
                            uint64_t idx)
{
  int z,n,idx0;
  uint64_t w;
  struct dict_entry *entry;
  int dolit;

  idx0 = idx;
  n = z = contig_ops(dis_op, size, idx);
  assert((idx + n) <= size);

  dolit = 0;
  while (n > 0) {
    w = word_at(data+idx);
    entry = bsearch(&w, dict,
                    dict_count, sizeof(dict[0]),
                    dict_search);

    if (entry) {
      asymbol **labels = lookup_sym_value(vma+idx);
      if (labels) {
        show_labels(labels);
      }
      printf("%8"PRIx64" %8"PRIx64, vma+idx, w);
      spaces(WIDTH);
      /* don't mark an executable entry as live if it's just a
         parameter for (dolit) */
      printf("%c %s\n", dolit ? ' ' : '|', entry->name);
      dolit = !strcmp(entry->name, "(dolit)");
    } else {
      dump_symbol(data+idx, wl, vma+idx, wl);
      dolit = 0;
    }
    idx += wl;
    n -= wl;
  }

  return idx0+z;
}

static uint64_t disasm_cfa(const bfd_byte *data,
                           uint64_t size,
                           uint64_t vma,
                           unsigned char *dis_op,
                           uint64_t idx)
{
  int n;
  struct dict_entry *ientry; /* dictionary entry for interpreter */
  struct dict_entry *centry; /* dictionary entry for current cfa */
  uint64_t itp;
  uint64_t cfa;

  n = contig_ops(dis_op, size, idx);
  assert((idx + n) <= size);

  /* find dictionary entry for current cfa; easier to look up than
     to seach backwards for smudge bit in nfa */
  cfa = vma+idx;
  centry = bsearch(&cfa, dict,
                   dict_count, sizeof(dict[0]),
                   dict_search);

  /* find dictionary entry for interpreter */
  itp = word_at(data+idx);
  ientry = bsearch(&itp, interp,
                   interp_count, sizeof(interp[0]),
                   dict_search);

  if (ientry) {
    asymbol **labels = lookup_sym_value(vma+idx);

    if (labels) {
      show_labels(labels);
    }
    printf("%8"PRIx64" %8"PRIx64, vma+idx, itp);
    spaces(WIDTH);
    printf("> %s %s\n", ientry->name, centry ? centry->name : "");
  } else {
    dump_symbol(data+idx, n, vma+idx, wl);
  }

  return idx+n;
}

static uint64_t disasm_byte(const bfd_byte *data,
                            uint64_t size,
                            uint64_t vma,
                            unsigned char *dis_op,
                            uint64_t idx)
{
  int n;

  n = contig_ops(dis_op, size, idx);
  assert((idx + n) <= size);
  dump_symbol(data+idx, n, vma+idx, wl);
  return idx+n;
}

#define ILLEGAL_OP 0

static int disasm_op(const bfd_byte *data,
                     uint64_t size,
                     uint64_t vma,
                     unsigned char *dis_op,
                     uint64_t idx)
{
  assert(idx < size);
  switch (dis_op[idx]) {
  case 'w':
    idx = disasm_word(data, size, vma, dis_op, idx);
    break;
  case 'c':
    idx = disasm_cfa(data, size, vma, dis_op, idx);
    break;
  case 'b':
    idx = disasm_byte(data, size, vma, dis_op, idx);
    break;
  case 'a':
    idx = disasm_machine(data, size, vma, dis_op, idx);
    break;
  default:
    assert(ILLEGAL_OP);
    break;
  }
  assert(idx <= size);

  return idx;
}

static void expand_dis_op(unsigned char *dis_op, uint64_t size)
{
  uint64_t i;
  uint64_t count;
  unsigned char cur_op;
  unsigned char new_op;

  /* How many unknown ops at the start? */
  for (i=0; i<size; i++) {
    if (dis_op[i]) {
      break;
    }
  }

  /* Mark beginning */
  count = i;
  if (count > 0) {
    for (i=0; i < count;) {
      dis_op[i] = 'a';
      i++;
      assert(i <= size);
    }
  }
  assert(count == i);
  assert(dis_op[i] != 0);       /* must already be marked */
  assert(dis_op[i] != 'b');     /* must not be a dict string */

  cur_op = dis_op[i];

  while (i < size) {
    if ((new_op = dis_op[i]) != 0) {
      if (new_op == 'w' || new_op == 'a') {
        cur_op = new_op;
      }
      if (new_op == 'w' || new_op == 'c') {
        i += wl;
        assert(i <= size);
      } else {
        i++;
      }
    } else {
      switch (cur_op) {
      case 'a':
        dis_op[i] = cur_op;
        i++;
        break;
      case 'w':
        dis_op[i] = cur_op;
        i += wl;
        break;
      default:
        assert(ILLEGAL_OP);
        break;
      }
    }
    assert(i <= size);
  }

}

static int disasm_dict(const bfd_byte *data,
                       uint64_t size,
                       uint64_t vma,
                       unsigned char *dis_op)
{
  uint64_t idx;

  idx=0;
  while (idx < size) {
    idx = disasm_op(data, size, vma, dis_op, idx);
  }
  return 0;
}

static void disasm_section(bfd *abfd, asection *sect, struct info *info)
{
  uint64_t size;
  uint64_t vma;
  bfd_byte *data;
  unsigned char *dis_op;
  const char *sname = bfd_section_name(sect);
  printf("*** section %s\n", sname);
  bfd_disassembler.info.section = sect;
  size = bfd_section_size(sect);

  if (!bfd_malloc_and_get_section(abfd, sect, &data)) {
    bfd_perror(prog);
    info->rc = 1;
    return;
  }

  vma = bfd_section_vma(sect);

  bfd_disassembler.size = size;
  bfd_disassembler.vma = vma;
  bfd_disassembler.data = data;

  if (info->voc_head_vma >= vma && info->voc_head_vma <= (vma+size)) {
    dis_op = scan_dict(data, size, vma, info);
    if (dis_op) {
      expand_dis_op(dis_op, size);
      info->rc = disasm_dict(data, size, vma, dis_op);
      free(dis_op);
    } else {
      info->rc = 1;
    }
  } else {
    /* assume raw machine code */
    fprintf(stderr,"assuming %s is raw code\n", sname);
    disasm_machine(data, size, vma, NULL, 0);
  }
  free(data);
}


static void dump_section(bfd *abfd, asection *sect, struct info *info)
{
  uint64_t size;
  uint64_t vma;
  bfd_byte *data;
  asymbol **sym;
  int offset = 0;
  const char *sname;

  sname = bfd_section_name(sect);
  size = bfd_section_size(sect);
  printf("*** section %s\n", sname);

  if (!bfd_malloc_and_get_section(abfd, sect, &data)) {
    bfd_perror(prog);
    info->rc = 1;
    return;
  }

  vma = bfd_section_vma(sect);

  sym = lookup_sym_value(vma);
  while (sym) {
    int idx = sym - sym_by_value;
    asymbol **next = NULL;

    /* make sure we are in the same section... */
    if (strcmp(sname, bfd_section_name(bfd_asymbol_section(*sym)))) {
      break;
    }

    do {
      if (++idx < sym_count) {
        next = sym_by_value + idx;
      } else {
        break;
      }
    } while (bfd_asymbol_value(*sym) == bfd_asymbol_value(*next));
    if (next) {
      uint64_t this_val = bfd_asymbol_value(*sym);
      uint64_t next_val = bfd_asymbol_value(*next);
      int len = next_val - this_val;
      offset = this_val - vma;

      dump_mem(data + offset, len, this_val, wl, sym);
      sym = next;

      /* keep track in case we run out of symbols */
      offset += len;
      size -= len;
    } else {
      sym = NULL;
    }
  }

  if (size > 0) {
    dump_mem(data+offset, size, vma, wl, NULL);
  }

  free(data);
}

static void find_user(bfd *abfd __attribute__((unused)),
                      asection *sect, void *obj)
{
  const char *name = bfd_section_name(sect);
  struct info *info = (struct info *)obj;
  asection *usersym_sect = bfd_asymbol_section(*info->usersym);
  bfd_byte *mem = NULL;
  uint64_t user_vma = bfd_asymbol_value(*info->usersym);
  uint64_t sect_vma = bfd_section_vma(sect);
  uint64_t sect_size = bfd_section_size(sect);
  uint64_t paren_vocs_vma;
  uint64_t pvv_offset;

  if (!strcmp(name, bfd_section_name(usersym_sect)) &&
      user_vma >= sect_vma && user_vma < (sect_vma+sect_size)) {
    paren_vocs_vma = user_vma + (PAREN_VOCS_OFFSET * wl);
    pvv_offset = paren_vocs_vma - sect_vma;
    if (!strcmp(name, ".text")) {
      mem = info->text;
    } else if (!strcmp(name, ".data")) {
      mem = info->data;
    } else {
      fprintf(stderr, "warning: info missing %s section\n", name);
    }
    if (mem) {
      info->voc_head_vma = word_at(mem + pvv_offset);
    }
  }
}

static void handle_section(bfd *abfd, asection *sect, void *obj)
{
  const char *name = bfd_section_name(sect);
  struct info *info = (struct info *)obj;

  if (!strcmp(name, ".text")) {
    disasm_section(abfd, sect, info);
  } else if (!strcmp(name, ".data")) {
    if (info->exitsym != NULL &&
        !strcmp(name, (*info->exitsym)->section->name)) {
      disasm_section(abfd, sect, info);
    } else {
      dump_section(abfd, sect, info);
    }
  }
}

static void show_matches(char **match)
{
  fprintf(stderr, "matching formats:");
  while (*match) {
    fprintf(stderr, " %s", *match++);
  }
  fprintf(stderr, "\n");
}

static bfd *open_bfd(const char *appl, const char *target)
{
  bfd *abfd = NULL;
  char **match = NULL;

  for (;;) {
    abfd = bfd_openr(appl, target);
    if (abfd == NULL) {
      bfd_perror(prog);
      break;
    }

    if (match) {
      free(match);
    }

    if (!bfd_check_format_matches(abfd, bfd_object, &match)) {
      if (target == NULL && match != NULL) {
        /* retry first match */
        bfd_close(abfd);
        target = match[0];
        if (verbose) {
          show_matches(match);
        }
      } else {
        bfd_perror(prog);
        break;
      }
    } else {
      break;
    }
  }

  if (match) {
    free(match);
  }

  return abfd;
}

static int read_symtab(const char *appl, const char *target)
{
  int rc = 1;
  bfd *abfd;

  abfd = open_bfd(appl, target);
  if (abfd != NULL) {
      char *dbg = bfd_follow_gnu_debuglink(abfd, ".");
      if (dbg) {
        bfd_close(abfd);
        abfd = open_bfd(dbg, target);
        free(dbg);
      }
  }
  if (abfd != NULL) {
    rc = scan_sym(abfd);
  }

  return rc;
}


static int disasm(const char *appl, const char *target)
{
  int rc = 1;
  bfd *abfd;
  struct info info;

  bfd_init();
  bfd_set_error_program_name(prog);
  memset(&info, 0, sizeof(info));

  do {
    abfd = open_bfd(appl, target);
    if (abfd == NULL) {
      perror(prog);
      break;
    }

    bfd_disassembler.abfd = abfd;
    if (!setup_machine(&bfd_disassembler)) {
      fprintf(stderr, "%s: error: No disassembler found\n", prog);
      break;
    }

    if (!setup_mach_deps()) {
      fprintf(stderr, "%s: error: No machine support for '%s'\n",
              prog, bfd_printable_name(abfd));
      break;
    }

    /* let's not get too weird yet */
    assert(bfd_arch_mach_octets_per_byte(bfd_get_arch_info(abfd)->arch,
                                         bfd_get_arch_info(abfd)->mach) == 1);

    wl = bfd_get_arch_info(abfd)->bits_per_word / CHAR_BIT;

    printf("*** arch:%s mach:%s word:%d addr:%d\n",
           bfd_printable_name(abfd),
           bfd_printable_arch_mach(bfd_get_arch_info(abfd)->arch,
                                   bfd_get_arch_info(abfd)->mach),
           bfd_get_arch_info(abfd)->bits_per_word,
           bfd_get_arch_info(abfd)->bits_per_address);

    info.text_section = bfd_get_section_by_name(abfd, ".text");
    if (!info.text_section) {
      bfd_perror(prog);
      info.rc = 1;
      break;
    }
    if (!bfd_malloc_and_get_section(abfd,
                                    info.text_section,
                                    &info.text)) {
      bfd_perror(prog);
      info.rc = 1;
      break;
    }
    info.text_size = bfd_section_size(info.text_section);
    info.text_vma = bfd_section_vma(info.text_section);

    info.data_section = bfd_get_section_by_name(abfd, ".data");
    if (!info.data_section) {
      bfd_perror(prog);
      info.rc = 1;
      break;
    }
    if (!bfd_malloc_and_get_section(abfd,
                                    info.data_section,
                                    &info.data)) {
      bfd_perror(prog);
      info.rc = 1;
      break;
    }
    info.data_size = bfd_section_size(info.data_section);
    info.data_vma = bfd_section_vma(info.data_section);

    info.usersym = lookup_sym_name("_USER");
    if (info.usersym) {
      bfd_map_over_sections(abfd,find_user, &info);
    } else {
      fprintf(stderr, "cannot find user area\n");
    }

    info.doessym = lookup_sym_name("does");
    if (!info.doessym) {
      fprintf(stderr, "cannot find does handler\n");
    }

    info.exitsym = lookup_sym_name("exit");
    if (!info.exitsym) {
      fprintf(stderr, "cannot find exit\n");
    }

    info.dovoc_romsym = lookup_sym_name("DOVOC_ROM");

    if (info.rc == 0) {
      bfd_map_over_sections(abfd,handle_section, &info);
      rc = info.rc;
    }

  } while (0);

  if (rc == 0 && abfd && !bfd_close(abfd)) {
    bfd_perror(prog);
  }

  if (info.text) {
    free(info.text);
  }

  if (info.data) {
    free(info.data);
  }

  return rc;
}

static void usage(void)
{
  fprintf(stderr, "%s [-vhL] [-t target] args...\n", prog);
}

int main(int argc, char *argv[])
{
  int rc = 1;
  int c;
  char *arg0;
  char *target = NULL;
  int run = 1;
  int list = 0;
  int numarg;

  arg0 = strdup(argv[0]);
  if (arg0) {
    prog = basename(arg0);
  }

  while ((c = getopt(argc, argv, "vht:L")) != EOF) {
    switch (c) {
    case 'v':
      verbose = 1;
      break;
    case 't':
      target = optarg;
      break;
    case 'L':
      run = 0;
      list = 1;
      break;
    case 'h':
      rc = 0;
      /* fall through */
    default:
      run = 0;
    }
  }

  numarg = argc - optind;

  if ((numarg == 1 || numarg == 2) && run) {
    int image_idx = optind;
    int symtab_idx = optind;

    if (numarg > 1) {
      /* separate debug image */
      symtab_idx++;
    }
    rc = read_symtab(argv[symtab_idx], target);
    if (!rc) {
      rc = disasm(argv[image_idx], target);
    }
  } else if (numarg == 0 && list) {
    const char **targets = bfd_target_list();
    int i;
    for (i=0; targets[i] != NULL; i++) {
      puts(targets[i]);
    }
    free(targets);
  } else {
    usage();
  }

  if (symtab) {
    free(symtab);
  }

  if (sym_by_name) {
    free(sym_by_name);
  }

  if (sym_by_value) {
    free(sym_by_value);
  }

  if (dict) {
    free(dict);
  }

  if (interp) {
    free(interp);
  }

  if (arg0) {
    free(arg0);
  }

  return rc;
}
