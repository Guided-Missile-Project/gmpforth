/*

   GFP: GMP Forth valgrind-based profiling tool

   Copyright (C) 2014 Daniel Kelley
      dkelley@gmp.san-jose.ca.us

   This file derived from Lackey, an example Valgrind tool that does
   some simple program measurement and tracing.

   See also https://valgrind.org/docs/manual/manual-writing-tools.html

   Copyright (C) 2002-2012 Nicholas Nethercote
      njn@valgrind.org

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307, USA.

   The GNU General Public License is contained in the file COPYING.
*/

#include <limits.h>
#include "valgrind.h"
#include "pub_tool_basics.h"
#include "pub_tool_tooliface.h"
#include "pub_tool_libcassert.h"
#include "pub_tool_libcprint.h"
#include "pub_tool_mallocfree.h"
#include "pub_tool_debuginfo.h"
#include "pub_tool_vki.h"
#include "pub_tool_libcbase.h"
#include "pub_tool_libcfile.h"
#include "pub_tool_options.h"
#include "pub_tool_machine.h"     // VG_(fnptr_to_fnentry)

#define MAX_ADDR 256*1024
#define MAGIC 0xa55a3003

struct stat {
   UInt   *count;
   ULong  min;
   ULong  max;
   UInt   oor;
};

static struct info {
   Long   magic;
   ULong  pc_base;
   UChar *op;
   UChar *marked;
   struct stat pc;
   struct stat ip;
   struct stat w;
} info;

/*------------------------------------------------------------*/
/*--- Command line options                                 ---*/
/*------------------------------------------------------------*/

/* Report output file */
static const Char* clo_output = NULL;
/* Executable input file */
static const Char* clo_input = NULL;
/* symtab input */
static const Char* clo_symtab = NULL;
/* text base input */
static const Char* clo_text = NULL;
/* verbosity */
static Int clo_verbose = 0;

/* Statically linked images won't have a symbol table available, so it
   needs to be passed in separately. The format is the output of
   "nm".

i386:
0804cbd5 t __trace_next_trap_79
0804c955 t __trace_transfer_io_100

x86_64:
0000000000408605 t __trace_next_trap_58
00000000004082ec t __trace_transfer_io_100

*/

struct GFP_Symbol
{
   ULong addr;   /* Address of symbol */
   enum {
      DATA,
      TEXT,
      TRACE,
      NEXT,
      CFA
   } kind;
};

enum {
  OP_NONE,
  OP_NEXT,
  OP_W
};

static Bool gfp_update_table(struct GFP_Symbol *sym)
{
   Int offset = sym->addr - info.pc_base;
   Bool overlap = False;

   switch (sym->kind) {
   case DATA:
      break;
   case TEXT:
      break;
   case TRACE:
      break;
   case CFA:
      if (info.op[offset] == OP_NONE) {
         info.op[offset] = OP_W;
      } else {
         overlap = True;
      }
      break;
   case NEXT:
      if (info.op[offset] == OP_NONE) {
         info.op[offset] = OP_NEXT;
      } else {
         overlap = True;
      }
      break;
   }

   if (overlap) {
      VG_(umsg)("CFA/NEXT error at address %llx\n", sym->addr);
   }

   return True;
}

static Bool strmatch(const Char* a, const Char* b)
{
   return VG_(strncmp(a, b, VG_(strlen)(b)));
}

static Int gfp_parse_symtab_line(Int fd, struct GFP_Symbol *sym,
                                 const Char* symtab, Int line)
{
   static Char buf[128];
   Char *p;
   Char *addr;
   Char *section;
   Char *name;
   Int c;
   Int rc;
   Int i;
   enum {
      ADDR,
      SECT,
      SYM,
      SKIP,
      EOL,
      EOF,
      ERR
   } state;

   p = buf;
   addr = p;
   section = NULL;
   name = NULL;
   state = ADDR;
   sym->kind = DATA;

   for (i=0; i<sizeof(buf); i++, p++) {
      rc = VG_(read)(fd,p,sizeof(*p));
      if (rc < 0) {
         VG_(umsg)("Error reading %s at line %d\n", symtab, line);
         state = ERR;
         break;
      } else if (rc == 0) {
         state = EOF;
         break;
      }
      c = *p;

      if (c == '\n') {
         *p = 0;
         state = (state == SYM) ? EOL : ERR;
         break;
      } else if (VG_(isspace)(c)) {
         if (state == ADDR) {
            if (i == 0) {
               /* Address is blank - skip whole record */
               state = SKIP;
            } else {
               *p = 0;
               section = p+1;
               state = SECT;
            }
         } else if (state == SECT) {
            *p = 0;
            name = p+1;
            state = SYM;
         } else if (state == SYM) {
            /* Something bad happened */
            VG_(umsg)("Error parsing %s at line %d\n", symtab, line);
            state = ERR;
            break;
         }
      }
   }

   if ((state == EOL) && addr && section && name) {
      if (!VG_(strcmp(section, "t"))) {
         sym->kind = TEXT;
         sym->addr = VG_(strtoull16)(addr, NULL);
         if (!strmatch(name, "__trace")) {
            if (!strmatch(name, "__trace_next")) {
               sym->kind = NEXT;
            } else if (!strmatch(name, "__trace_transfer_cfa")) {
               sym->kind = CFA;
            } else {
               sym->kind = TRACE;
            }
         }
      }
   }

   return (state == ERR) ? -1 : (state == EOL);
}

static Bool gfp_parse_symtab(const Char* symtab)
{
   Int fd;
   Int rc = False;

   VG_(umsg)("Reading symtab %s\n", symtab);
   fd = VG_(fd_open)(symtab, 0, 0);
   if (fd < 0) {
      VG_(umsg)("Error opening %s\n", symtab);
   } else {
      Int line;
      Int prc;
      struct GFP_Symbol symbol;

      VG_(memset)(&symbol, 0, sizeof(symbol));
      line = 1;
      while ((prc=gfp_parse_symtab_line(fd, &symbol, symtab, line)) > 0) {
         gfp_update_table(&symbol);
         line++;
      }
      rc = (prc > 0);
   }

   VG_(close(fd));
   return rc;
}

static Bool gfp_process_cmd_line_option(const HChar* arg)
{
   VG_(umsg)("CLO %s\n", arg);
   if VG_STR_CLO(arg, "--output", clo_output) {
   } else if VG_STR_CLO(arg, "--input", clo_input) {
         /*
           pub_tool_clientstate.h
           extern const HChar* VG_(args_the_exename);
          */
   } else if VG_BOOL_CLO(arg, "--verbose", clo_verbose) {
   } else if VG_STR_CLO(arg, "--symtab", clo_symtab) {
   } else if VG_STR_CLO(arg, "--text", clo_text) {
   } else {
      return False;
   }
   return True;
}

static void gfp_print_usage(void)
{
   VG_(printf)(
      "    --output=file             report file\n"
      "    --verbose=[yes|no]        verbosity\n"
      );
}

static void gfp_print_debug_usage(void)
{
   VG_(printf)(
      "    (none)\n"
      );
}

/* Generic function to get called each instruction */

#if defined(VGA_amd64)
#include "libvex_guest_amd64.h"
#define ARCH VexGuestAMD64State
#define IP guest_RSI
#define W  guest_RAX
#define REGLEN sizeof(ULong)
typedef ULong PC_off_t;
#define IRPC_Offset IRConst_U64
#elif defined(VGA_x86)
#include "libvex_guest_x86.h"
#define ARCH VexGuestX86State
#define IP guest_ESI
#define W  guest_EAX
#define REGLEN sizeof(UInt)
typedef UInt PC_off_t;
#define IRPC_Offset IRConst_U32
#else
#error unsupported
#endif

#define IP_OFFSET (offsetof(ARCH,IP))
#define W_OFFSET (offsetof(ARCH,W))

static void gfp_i_pc(PC_off_t offset, struct info *inf)
{
   if (inf->magic != MAGIC) {
      VG_(umsg)("*** %s inf->magic damaged\n", __FUNCTION__);
      return;
   }
   inf->pc.count[offset]++;
}

/* Some interaction between REGPARM() and needsBBP in Valgrind 3.8.1 */
static void gfp_i_ip(ARCH* gst, struct info *inf)
{
   ULong ip;

   if (inf->magic != MAGIC) {
      VG_(umsg)("*** %s inf->magic damaged\n", __FUNCTION__);
      return;
   }
   ip = gst->IP;

   if (ip < inf->ip.min) {
      inf->ip.min = ip;
   }

   if (ip > inf->ip.max) {
      inf->ip.max = ip;
   }

   if (ip > inf->pc_base) {
      ip -= inf->pc_base;

      if (ip < MAX_ADDR) {
         inf->ip.count[ip]++;
      } else {
         inf->ip.oor++;
      }
   }
}

static void gfp_i_w(ARCH* gst, struct info *inf)
{
   ULong w;

   if (inf->magic != MAGIC) {
      VG_(umsg)("*** %s inf->magic damaged\n", __FUNCTION__);
      return;
   }
   w = gst->W;

   if (w < inf->w.min) {
      inf->w.min = w;
   }

   if (w > inf->w.max) {
      inf->w.max = w;
   }

   if (w > inf->pc_base) {
      w -= inf->pc_base;

      if (w < MAX_ADDR) {
         inf->w.count[w]++;
      } else {
         inf->w.oor++;
      }
   }
}

static void gfp_out(HChar c, void* opaque)
{
   Int *fdp = (Int *)opaque;
   VG_(write)(*fdp, &c, sizeof(c));
}

static void gfp_printf(Int fd, const HChar *format, ... )
{
   va_list vargs;
   va_start(vargs, format);
   VG_(vcbprintf) (gfp_out, &fd, format, vargs);
   va_end(vargs);
}

static int gfp_report(void)
{
   Int i;
   Int fd;

   if (clo_output == NULL || clo_output[0] == 0) {
      clo_output = "gfp.yaml";
      if (clo_verbose) {
         VG_(umsg)("Using default output file %s\n", clo_output);
      }
   }

   fd = VG_(fd_open)(clo_output, VKI_O_WRONLY|VKI_O_CREAT|VKI_O_TRUNC, 0644);

   if (fd < 0) {
      VG_(umsg)("Error creating %s\n", clo_output);
      return fd;
   }

   gfp_printf(fd, "---\n");
   if (clo_input) {
      gfp_printf(fd, "  argv:\n");
      gfp_printf(fd, "    - %s\n", clo_input);
   }
   gfp_printf(fd, "  tool: valgrind_gfp\n");
   gfp_printf(fd, "  pc_base: 0x%llx\n", info.pc_base);
   gfp_printf(fd, "  pc_min: 0x%llx\n", info.pc.min);
   gfp_printf(fd, "  pc_max: 0x%llx\n", info.pc.max);
   gfp_printf(fd, "  ip_min: 0x%llx\n", info.ip.min);
   gfp_printf(fd, "  ip_max: 0x%llx\n", info.ip.max);
   gfp_printf(fd, "  w_min: 0x%llx\n", info.w.min);
   gfp_printf(fd, "  w_max: 0x%llx\n", info.w.max);

   gfp_printf(fd, "  pc_count:\n");
   for (i=0; i<MAX_ADDR; i++) {
      if (info.pc.count[i] != 0) {
         gfp_printf(fd, "    0x%llx: %d\n", i+info.pc_base, info.pc.count[i]);
      }
   }

   gfp_printf(fd, "  ip_count:\n");
   for (i=0; i<MAX_ADDR; i++) {
      if (info.ip.count[i] != 0) {
         gfp_printf(fd, "    0x%llx: %d\n", i+info.pc_base, info.ip.count[i]);
      }
   }

   gfp_printf(fd, "  w_count:\n");
   for (i=0; i<MAX_ADDR; i++) {
      if (info.w.count[i] != 0) {
         gfp_printf(fd, "    0x%llx: %d\n", i+info.pc_base, info.w.count[i]);
      }
   }

   gfp_printf(fd, "  op:\n");
   for (i=0; i<MAX_ADDR; i++) {
      if (info.op[i] != 0) {
         gfp_printf(fd, "    0x%llx: %d\n", i+info.pc_base, info.op[i]);
      }
   }

   gfp_printf(fd, "  instr:\n");
   for (i=0; i<MAX_ADDR; i++) {
      if (info.marked[i] != 0) {
         gfp_printf(fd, "    0x%llx: %d\n", i+info.pc_base, info.marked[i]);
      }
   }

   VG_(close)(fd);
   return 0;
}


/*------------------------------------------------------------*/
/*--- Basic tool functions                                 ---*/
/*------------------------------------------------------------*/

static void gfp_post_clo_init(void)
{
   /* Make sure guest state is accurate at instruction boundaries */

   VG_(clo_vex_control).iropt_register_updates_default
      = VexRegUpdAllregsAtEachInsn;

   if (clo_text) {
      info.pc_base = VG_(strtoull16)((char *)clo_text, NULL);
   } else {
      VG_(umsg)("Text base not set\n");
   }
   info.magic = MAGIC;
   info.pc.min = ULONG_MAX;
   info.ip.min = ULONG_MAX;
   info.w.min = ULONG_MAX;
   info.op = VG_(calloc)((HChar *)__FUNCTION__, MAX_ADDR,
                         sizeof(info.op[0]));
   info.marked = VG_(calloc)((HChar *)__FUNCTION__, MAX_ADDR,
                             sizeof(info.marked[0]));
   info.pc.count = VG_(calloc)((HChar *)__FUNCTION__, MAX_ADDR,
                               sizeof(info.pc.count[0]));
   info.ip.count = VG_(calloc)((HChar *)__FUNCTION__, MAX_ADDR,
                               sizeof(info.ip.count[0]));
   info.w.count = VG_(calloc)((HChar *)__FUNCTION__, MAX_ADDR,
                               sizeof(info.w.count[0]));
   (void)gfp_parse_symtab(clo_symtab);
}

static void gfp_insert_pc(IRSB* sbOut, IRStmt* st)
{
   IRDirty*   di;
   IRExpr* offset;
   IRExpr* inf;
   ULong addr = st->Ist.IMark.addr;

   /* ourAddr = st->Ist.IMark.addr; FIXME: need to handle delta */

   if (addr < info.pc.min) {
      info.pc.min = addr;
   }

   if (addr > info.pc.max) {
      info.pc.max = addr;
   }

   if ((addr < info.pc_base) || (addr > (info.pc_base + MAX_ADDR))) {
     info.pc.oor++;
     /* Address is out of range, so there's nothing to insert */
     return;
   }

   offset = IRExpr_Const(IRPC_Offset(addr - info.pc_base));
   inf = mkIRExpr_HWord( (HWord)&info );
   di = unsafeIRDirty_0_N(0, "gfp_i_pc",
                          VG_(fnptr_to_fnentry)( &gfp_i_pc ),
                          mkIRExprVec_2(offset, inf));
   if (clo_verbose) {
     VG_(umsg)("\r\nDI@%lld: ", addr);
     ppIRDirty(di);
     VG_(umsg)("\r\n");
   }
   /* Insert our call */
   addStmtToIRSB( sbOut,  IRStmt_Dirty(di));

}

static void gfp_insert_ip(IRSB* sbOut, IRStmt* st)
{
   IRDirty*   di;
   IRExpr* inf = mkIRExpr_HWord( (HWord)&info );

   di = unsafeIRDirty_0_N(0, "gfp_i_ip",
                          VG_(fnptr_to_fnentry)( &gfp_i_ip ),
                          mkIRExprVec_2(IRExpr_GSPTR(), inf));

   di->mFx = Ifx_None;
   di->nFxState = 1;
   VG_(memset)(&di->fxState, 0, sizeof(di->fxState));
   di->fxState[0].fx = Ifx_Read;
   di->fxState[0].offset = IP_OFFSET;
   di->fxState[0].size = REGLEN;
   if (clo_verbose) {
     VG_(umsg)("\r\nDI@%lu: ", st->Ist.IMark.addr);
     ppIRDirty(di);
     VG_(umsg)("\r\n");
   }
   /* Insert our call */
   addStmtToIRSB( sbOut,  IRStmt_Dirty(di));

}

static void gfp_insert_w(IRSB* sbOut, IRStmt* st)
{
   IRDirty*   di;
   IRExpr* inf = mkIRExpr_HWord( (HWord)&info );

   di = unsafeIRDirty_0_N(0, "gfp_i_w",
                          VG_(fnptr_to_fnentry)( &gfp_i_w ),
                          mkIRExprVec_2(IRExpr_GSPTR(), inf));

   di->mFx = Ifx_None;
   di->nFxState = 1;
   VG_(memset)(&di->fxState, 0, sizeof(di->fxState));
   di->fxState[0].fx = Ifx_Read;
   di->fxState[0].offset = W_OFFSET;
   di->fxState[0].size = REGLEN;
   if (clo_verbose) {
     VG_(umsg)("\r\nDI@%lu: ", st->Ist.IMark.addr);
     ppIRDirty(di);
     VG_(umsg)("\r\n");
   }
   /* Insert our call */
   addStmtToIRSB( sbOut,  IRStmt_Dirty(di));

}


static void gfp_insert(IRSB* sbOut, IRStmt* st)
{
   ULong offset = st->Ist.IMark.addr - info.pc_base;
   Bool fprog = (info.marked && (info.pc_base > 0));

   if (fprog) {
      info.marked[offset]++;
   }

   gfp_insert_pc(sbOut, st);

   if (fprog) {
      switch (info.op[offset]) {
      case OP_NEXT:
         gfp_insert_ip(sbOut, st);
         break;
      case OP_W:
         gfp_insert_w(sbOut, st);
         break;
      default:
         /* no insertions needed */
         break;
      }
   }
}

static
IRSB* gfp_instrument ( VgCallbackClosure* closure,
                       IRSB* sbIn,
                       const VexGuestLayout* layout,
                       const VexGuestExtents* vge,
                       const VexArchInfo* archinfo_host,
                       IRType gWordTy, IRType hWordTy )
{
   Int        i = 0;
   IRSB*      sbOut;
   IRStmt*    st = sbIn->stmts[i];

   if (gWordTy != hWordTy) {
      /* We don't currently support this case. */
      VG_(tool_panic)("host/guest word size mismatch");
   }

   /* Set up SB */
   sbOut = deepCopyIRSBExceptStmts(sbIn);

   // Copy verbatim any IR preamble preceding the first IMark
   i = 0;
   while ((i < sbIn->stmts_used) && (sbIn->stmts[i]->tag != Ist_IMark)) {
      addStmtToIRSB( sbOut, sbIn->stmts[i] );
      i++;
   }

   /* sequence cribbed from bbv_main.c */
   /* Get the first statement */
   tl_assert(sbIn->stmts_used > 0);
   st = sbIn->stmts[i];

   /* double check we are at a Mark statement */
   tl_assert(Ist_IMark == st->tag);

   while(i < sbIn->stmts_used) {
      st=sbIn->stmts[i];
      if (st->tag == Ist_IMark) {
         gfp_insert(sbOut, st);
      }
      /* Insert the original instruction */
      addStmtToIRSB( sbOut, st );

      i++;
   }

   return sbOut;
}

static void gfp_fini(Int exitcode)
{
   (void)gfp_report();
   if (info.pc.oor) {
      VG_(umsg)("pc.oor:       %d\n", info.pc.oor);
   }
   if (info.ip.oor) {
      VG_(umsg)("ip.oor:       %d\n", info.ip.oor);
   }
   if (info.w.oor) {
      VG_(umsg)("w.oor:       %d\n", info.w.oor);
   }
   VG_(umsg)("Exit code:       %d\n", exitcode);
}

static void gfp_pre_clo_init(void)
{
   VG_(details_name)            ("GFP");
   VG_(details_version)         (NULL);
   VG_(details_description)     ("GMP Forth profiler");
   VG_(details_copyright_author)(
      "Copyright (C) 2014, and GNU GPL'd, by Daniel Kelley.");
   VG_(details_bug_reports_to)  ("dkelley@gmp.san-jose.ca.us");
   VG_(details_avg_translation_sizeB) ( 200 );

   VG_(basic_tool_funcs)          (gfp_post_clo_init,
                                   gfp_instrument,
                                   gfp_fini);
   VG_(needs_command_line_options)(gfp_process_cmd_line_option,
                                   gfp_print_usage,
                                   gfp_print_debug_usage);
}

VG_DETERMINE_INTERFACE_VERSION(gfp_pre_clo_init)

/*--------------------------------------------------------------------*/
/*--- end                                               gfp_main.c ---*/
/*--------------------------------------------------------------------*/
