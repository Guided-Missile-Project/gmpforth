/*
   profile.c

   Copyright (c) 2014 by Daniel Kelley

*/

#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <limits.h>
#include <bfd.h>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/user.h>
#include <libgen.h>

#define MAX_ADDR 256*1024

static unsigned long pc_base;
static unsigned char *op;
static unsigned long *pc_count;
static unsigned long *ip_count;
static unsigned long pc_min = ULONG_MAX;
static unsigned long pc_max;
static unsigned long ip_min = ULONG_MAX;
static unsigned long ip_max;
static int verbose;
static FILE *output;
static char *prog;

/*
  Map FORTH registers to CPU registers
 */
#if defined(__x86_64__)
#define PC rip
#define IP rsi
#define BFD_TARGET "elf64-x86-64"
#elif defined(__i386__)
#define PC eip
#define IP esi
#define BFD_TARGET "elf32-i386"
#else
#error no arch support
#endif

static int strmatch(const char *a, const char *b)
{
  return strncmp(a,b,strlen(b));
}

static int scan_symbol(asymbol *symbol)
{
  const char *sect_name;
  const char *sym_name;
  unsigned long value;

  sect_name = bfd_section_name(bfd_asymbol_section(symbol));
  if (!strcmp(sect_name, ".text")) {
    sym_name = bfd_asymbol_name(symbol);
    value = bfd_asymbol_value(symbol);
    if (!strmatch(sym_name, "__trace_next")) {
      op[value - pc_base] = 1;
      if (verbose) {
        printf("%s: %08lx %08lx\n", sym_name, value, value-pc_base);
      }
    }
  }
  return 0;
}

static int scan_prog(bfd *abfd)
{
  int rc = 1;
  long size;
  asymbol **symtab;
  long count;
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
    count = bfd_canonicalize_symtab(abfd, symtab);
    if (count < 0) {
      bfd_perror(prog);
      break;
    }

    for (i=0; i<count; i++) {
      rc = scan_symbol(symtab[i]);
      if (rc) {
        break;
      }
    }
  } while (0);

  return rc;
}

static int init(const char *appl)
{
  int rc = 1;
  bfd *abfd;
  char **match;

  do {
    op = calloc(MAX_ADDR, sizeof(op[0]));
    if (op == NULL) {
      perror(prog);
      break;
    }
    pc_count = calloc(MAX_ADDR, sizeof(pc_count[0]));
    if (pc_count == NULL) {
      perror(prog);
      break;
    }
    ip_count = calloc(MAX_ADDR, sizeof(ip_count[0]));
    if (ip_count == NULL) {
      perror(prog);
      break;
    }
    abfd = bfd_openr(appl, BFD_TARGET);
    if (abfd == NULL) {
      perror(prog);
      break;
    }

    if (!bfd_check_format_matches(abfd, bfd_object, &match)) {
      bfd_perror(prog);
      break;
    }
    
    if (abfd->start_address) {
      pc_base = abfd->start_address;
    } else {
      fprintf(stderr, "%s: %s start address is zero\n", prog, appl);
    }

    rc = scan_prog(abfd);

  } while (0);

  if (rc == 0 && abfd && !bfd_close(abfd)) {
    bfd_perror(prog);
  }

  return rc;
}

static long capture(pid_t pid)
{
  struct user u;
  unsigned long pc;
  unsigned long ip;
  long ptrc;

  ptrc = ptrace(PTRACE_GETREGS, pid, NULL, &u);

  if (ptrc == -1) {
    return ptrc;
  }

  pc = u.regs.PC;
  ip = u.regs.IP;

  if (pc < pc_min) {
    pc_min = pc;
  }

  if (pc > pc_max) {
    pc_max = pc;
  }

  if (ip < ip_min) {
    ip_min = ip;
  }

  if (ip > ip_max) {
    ip_max = ip;
  }

  if (pc >= pc_base) {
    pc -= pc_base;
    if (pc < MAX_ADDR) {
      pc_count[pc]++;

      if (op[pc] && ip > pc_base) {
        ip -= pc_base;

        if (ip < MAX_ADDR) {
          ip_count[ip]++;
        }
      }
    }

  }

  return ptrc;
}

static int trace(char *argv[])
{
  pid_t child;
  int rc = 1;
  long ptrc;


  child = fork();

  if (child == -1) {
    /* error */
    rc = 3;
  } else if (child == 0) {
    /* child */
    ptrc = ptrace(PTRACE_TRACEME, 0, NULL, NULL);
    if (ptrc == 0) {
      (void)execv(argv[0], argv+1);
    }
  } else {
    int status = 0;
    /* parent */
    for (;;) {
      wait(&status);
      if (status != 1407) {
        rc = 0;
        break;
      }
      ptrc = capture(child);
      if (ptrc == -1) {
        rc = 5;
        break;
      }
      ptrc = ptrace(PTRACE_SINGLESTEP, child, NULL, NULL);
      if (ptrc == -1) {
        rc = 2;
        break;
      }
    }
  }

  return rc;
}

static int report(char **argv, FILE *f)
{
  int i;

  fprintf(f, "---\n");
  fprintf(f, "  argv:\n");
  while(*argv) {
    fprintf(f, "    - %s\n", *argv++);
  }
  fprintf(f, "  pc_base: 0x%lx\n", pc_base);
  fprintf(f, "  pc_min: 0x%lx\n", pc_min);
  fprintf(f, "  pc_max: 0x%lx\n", pc_max);
  fprintf(f, "  ip_min: 0x%lx\n", ip_min);
  fprintf(f, "  ip_max: 0x%lx\n", ip_max);

  fprintf(f, "  pc_count:\n");
  for (i=0; i<MAX_ADDR; i++) {
    if (pc_count[i] != 0) {
      fprintf(f, "    0x%lx: %ld\n", i+pc_base, pc_count[i]);
    }
  }

  fprintf(f, "  ip_count:\n");
  for (i=0; i<MAX_ADDR; i++) {
    if (ip_count[i] != 0) {
      fprintf(f, "    0x%lx: %ld\n", i+pc_base, ip_count[i]);
    }
  }

  fprintf(f, "  op:\n");
  for (i=0; i<MAX_ADDR; i++) {
    if (op[i] != 0) {
      fprintf(f, "    0x%lx: %d\n", i+pc_base, op[i]);
    }
  }

  return 0;
}

static int profile(char *argv[])
{
  int rc = 1;

  bfd_init();

  do {
    rc = init(argv[0]);
    if (rc) {
      break;
    }

    rc = trace(argv);
    if (rc) {
      break;
    }

  } while (0);

  return rc;
}

static void usage(void)
{
  fprintf(stderr, "%s [-o report] [-vh] args...\n", prog);
}

int main(int argc, char *argv[])
{
  int rc = 1;
  int c;
  char *arg0;
  char *rpt_file = NULL;

  arg0 = strdup(argv[0]);
  if (arg0) {
    prog = basename(arg0);
  }
  output = stderr;

  while ((c = getopt(argc, argv, "o:vh")) != EOF) {
    switch (c) {
    case 'o':
      rpt_file = optarg;
      break;
    case 'v':
      verbose = 1;
      break;
    case 'h':
      rc = 0;
      /* fall through */
    default:
      usage();
      free(arg0);
      return (rc);
    }
  }

  if ((argc - optind) == 0) {
      usage();
  } else {
    if (rpt_file) {
      output = fopen(rpt_file, "w");
      if (output == NULL) {
        fprintf(stderr, "%s: '%s' %s\n", prog, rpt_file, strerror(errno));
      }
    }
    if (output) {
      rc = profile(argv+optind);
      if (!rc) {
        rc = report(argv+optind, output);
      }
    }
  }

  free(arg0);

  return rc;
}
