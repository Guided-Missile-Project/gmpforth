/*
   cvm.c

   Copyright (c) 2011 by Daniel Kelley

   GMP Forth 'C' virtual machine

   Requires GNU extensions (getopt) and C99 (lldiv)

   $Id:$
*/

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <endian.h>
#include <unistd.h>
#include <signal.h>
#include <setjmp.h>
#include "ioconstants.h"
#include "stack.h"
#include "vmem.h"

#define DATABYTES sizeof(unsigned int)
#define __SIGNED(x) ((int)(x))
#define DEFAULT_STACK_SIZE 256
#define DEFAULT_MEM_SIZE 256*1024

#if __BYTE_ORDER != __LITTLE_ENDIAN
#define IMAGE "image32be"
#else
#define IMAGE "image32le"
#endif

struct cvm {
  sigjmp_buf env;
  struct stack p;
  struct stack r;
  unsigned int mem_size;
  unsigned int *mem;
  unsigned int entry;
  unsigned int pc;
  unsigned int ip;
  unsigned int w;
  unsigned int u;
  unsigned int opcache;
  int          opc_idx;
  int          running;
  int          verbose;
  int          debug;
  int          test;
  int          tty;
  int          step_idx;
  int          err;
};

#define  OPBITS  8
#define  NBITS   6
#define  OP_T    0x80 /* Opcode type (0,1) */
#define  OP_R    0x40 /* Opcode 0:return 1:subtype */
#define  OP_N    0x3F /* Opcode 0 idx */
#define COUNT(a) (sizeof((a))/sizeof((a)[0]))

enum trace_t {
  TRACE_TYPE0,
  TRACE_PUSHS
};

enum reg_t {
  REG_SP,
  REG_RP,
  REG_UP
};

/* signals to trap */
static int trappable[] = {
  SIGHUP,
  SIGINT,
  SIGILL,
  SIGTRAP,
  SIGBUS,
  SIGFPE,
  SIGUSR1,
  SIGSEGV,
  SIGUSR2,
  SIGSTKFLT
};

typedef void (*op_f)(struct cvm *vm);

static void vm_nop(struct cvm *vm);
static void vm_reset(struct cvm *vm);
static void vm_store(struct cvm *vm);
static void vm_star(struct cvm *vm);
static void vm_star_slash(struct cvm *vm);
static void vm_star_slash_mod(struct cvm *vm);
static void vm_plus(struct cvm *vm);
static void vm_minus(struct cvm *vm);
static void vm_slash(struct cvm *vm);
static void vm_slash_mod(struct cvm *vm);
static void vm_n_to_r(struct cvm *vm);
static void vm_fetch(struct cvm *vm);
static void vm_and(struct cvm *vm);
static void vm_c_store(struct cvm *vm);
static void vm_c_fetch(struct cvm *vm);
static void vm_depth(struct cvm *vm);
static void vm_drop(struct cvm *vm);
static void vm_dup(struct cvm *vm);
static void vm_execute(struct cvm *vm);
static void vm_j(struct cvm *vm);
static void vm_or(struct cvm *vm);
static void vm_over(struct cvm *vm);
static void vm_n_r_from(struct cvm *vm);
static void vm_r_fetch(struct cvm *vm);
static void vm_rot(struct cvm *vm);
static void vm_swap(struct cvm *vm);
static void vm_uless(struct cvm *vm);
static void vm_um_star(struct cvm *vm);
static void vm_um_slash_mod(struct cvm *vm);
static void vm_xor(struct cvm *vm);
static void vm_plus_loop(struct cvm *vm);
static void vm_question_do(struct cvm *vm);
static void vm_do(struct cvm *vm);
static void vm_docol(struct cvm *vm);
static void vm_does(struct cvm *vm);
static void vm_dovar(struct cvm *vm);
static void vm_dolit(struct cvm *vm);
static void vm_leave(struct cvm *vm);
static void vm_loop(struct cvm *vm);
static void vm_reg_fetch(struct cvm *vm);
static void vm_reg_store(struct cvm *vm);
static void vm_s_quote(struct cvm *vm);
static void vm_dash_rot(struct cvm *vm);
static void vm_pick(struct cvm *vm);
static void vm_roll(struct cvm *vm);
static void vm_io(struct cvm *vm);
static void vm_exit(struct cvm *vm);
static void vm_branch(struct cvm *vm);
static void vm_zero_branch_no_pop(struct cvm *vm);
static void vm_zero_branch(struct cvm *vm);
static void vm_zero_equal(struct cvm *vm);
static void vm_zero_less(struct cvm *vm);
static void vm_less(struct cvm *vm);
static void vm_two_star(struct cvm *vm);
static void vm_two_slash(struct cvm *vm);
static void vm_m_star_slash(struct cvm *vm);
static void vm_d_plus(struct cvm *vm);
static void vm_d_minus(struct cvm *vm);
static void vm_u_two_slash(struct cvm *vm);
static void vm_to_r(struct cvm *vm);
static void vm_r_from(struct cvm *vm);
static void vm_unsupported(struct cvm *vm);

struct op {
  op_f op;
  const char *name;
};

static struct op type0[64] = {
  { vm_nop, "nop" },
  { vm_reset, "reset" },
  { vm_store, "store" },
  { vm_star, "star" },
  { vm_star_slash, "star_slash" },
  { vm_star_slash_mod, "star_slash_mod" },
  { vm_plus, "plus" },
  { vm_minus, "minus" },
  { vm_slash, "slash" },
  { vm_slash_mod, "slash_mod" },
  { vm_n_to_r, "n_to_r" },
  { vm_fetch, "fetch" },
  { vm_and, "and" },
  { vm_c_store, "c_store" },
  { vm_c_fetch, "c_fetch" },
  { vm_depth, "depth" },
  { vm_drop, "drop" },
  { vm_dup, "dup" },
  { vm_execute, "execute" },
  { vm_unsupported, "old-i" },
  { vm_j, "j" },
  { vm_or, "or" },
  { vm_over, "over" },
  { vm_n_r_from, "n_r_from" },
  { vm_r_fetch, "r_fetch" },
  { vm_rot, "rot" },
  { vm_swap, "swap" },
  { vm_uless, "uless" },
  { vm_um_star, "um_star" },
  { vm_um_slash_mod, "um_slash_mod" },
  { vm_xor, "xor" },
  { vm_plus_loop, "plus_loop" },
  { vm_question_do, "question_do" },
  { vm_do, "do" },
  { vm_docol, "docol" },
  { vm_does, "does" },
  { vm_dovar, "dovar" },
  { vm_dolit, "dolit" },
  { vm_leave, "leave" },
  { vm_loop, "loop" },
  { vm_reg_fetch, "reg_fetch" },
  { vm_reg_store, "reg_store" },
  { vm_s_quote, "s_quote" },
  { vm_unsupported, "sp_fetch" },
  { vm_unsupported, "sp_store" },
  { vm_dash_rot, "dash_rot" },
  { vm_pick, "pick" },
  { vm_roll, "roll" },
  { vm_io, "io" },
  { vm_exit, "exit" },
  { vm_branch, "branch" },
  { vm_zero_branch_no_pop, "zero_branch_no_pop" },
  { vm_zero_branch, "zero_branch" },
  { vm_zero_equal, "zero_equal" },
  { vm_zero_less, "zero_less" },
  { vm_less, "less" },
  { vm_two_star, "two_star" },
  { vm_two_slash, "two_slash" },
  { vm_m_star_slash, "m_star_slash" },
  { vm_d_plus, "d_plus" },
  { vm_d_minus, "d_minus" },
  { vm_u_two_slash, "u_two_slash" },
  { vm_to_r, "to_r" },
  { vm_r_from, "r_from" },
};

static struct cvm vm;

/* general stack ops */

static void trace(struct cvm *vm, enum trace_t kind, unsigned int value, unsigned int r)
{
  if (vm->debug) {
    int i,depth;
    const char *opstr;
    char optmp[32];

    if (vm->test) {
      fprintf(stderr, "TRACE ");
    } else if (vm->step_idx == 0) {
      fprintf(stderr, "\r\n");
      fprintf(stderr, "idx    pc   ip   w    rp@ op             stack\r\n");
      fprintf(stderr, "------ ---- ---- ---- --- -------------- ---------------\r\n");

    }
    switch (kind) {
    case TRACE_TYPE0:
      if (r) {
        strcpy(optmp, type0[value].name);
        strcat(optmp, "*");
        opstr = optmp;
      } else {
        opstr = type0[value].name;
      }
      break;
    case TRACE_PUSHS:
      sprintf(optmp, "push(%08x)", value);
      opstr = optmp;
      break;
    }

    fprintf(stderr, "%6d %04x %04x %04x %3d %-14s ",
            vm->step_idx, vm->pc, vm->ip, vm->w, stack_depth(&vm->r), opstr);

    depth = stack_depth(&vm->p);
    fprintf(stderr, "[%d]", depth);
    for (i=depth - 1; i>=0; i--) {
      fprintf(stderr, " %x", stack_pick(&vm->p, i));
    }
    fprintf(stderr, "\r\n");
    vm->step_idx += 1;
  }
}

static void exec(struct cvm *vm, op_f op)
{
  assert (op != NULL);
  op(vm);
}

static void push(struct cvm *vm, unsigned int value)
{
  stack_push(&vm->p, value);
}

static void invalidate_opcache(struct cvm *vm)
{
  vm->opcache = 0;
  vm->opc_idx = -1;
}

static void jmp(struct cvm *vm, unsigned int loc)
{
  invalidate_opcache(vm);
  vm->pc = loc;
}

static unsigned int byte_at(unsigned int value, unsigned int idx)
{
#if __BYTE_ORDER != __LITTLE_ENDIAN
  idx = DATABYTES - idx - 1;
#endif

  return (value >> (idx*8)) & 0xff;
}

static int _signed(unsigned int n, int width)
{
  int i, sign_bit;

  sign_bit = width - 1;
  i = n & 0xffffffff;
  return (n & (1<<sign_bit)) ? -((1<<width) - i) : i;
}

static int small(unsigned int n)
{
  return _signed(n, NBITS);
}

static unsigned int word_addr(unsigned int addr)
{
  return addr/DATABYTES;
}

static unsigned int aligned_word_addr(unsigned int addr)
{
  assert((addr % DATABYTES) == 0);
  return word_addr(addr);
}

static void mem_store(struct cvm *vm, unsigned int waddr, unsigned int value)
{
  vm->mem[waddr] = value;
}

static unsigned int mem_fetch(struct cvm *vm, unsigned int waddr)
{
  return vm->mem[waddr];
}

static void store(struct cvm *vm, unsigned int addr, unsigned int value)
{
  mem_store(vm, aligned_word_addr(addr), value);
}

static unsigned int fetch(struct cvm *vm, unsigned int addr)
{
  return mem_fetch(vm, aligned_word_addr(addr));
}

static void c_store(struct cvm *vm, unsigned int addr, unsigned int c_value)
{
  int byte_offset, waddr, shift;
  unsigned int value;
  unsigned int mask;

  byte_offset = addr % DATABYTES;
  waddr = word_addr(addr);
  value = vm->mem[waddr];
  shift = byte_offset*8;
  mask = 0xff<<shift;
  c_value <<= shift;
  value &= ~mask;
  value |= c_value;
  vm->mem[waddr] = value;
}

static unsigned int c_fetch(struct cvm *vm, unsigned int addr)
{
  int byte_offset, shift;
  unsigned int value;

  byte_offset = addr % DATABYTES;
  shift = byte_offset*8;
  value = vm->mem[word_addr(addr)];
  value >>= shift;
  return value & 0xff;
}

static void next_ip(struct cvm *vm)
{
  vm->ip += DATABYTES;
}

static void next_op(struct cvm *vm)
{
  if (vm->opc_idx >= 0) {
    vm->pc += 1;
    vm->opc_idx += 1;
    if (vm->opc_idx == DATABYTES) {
      /* done; invalidate opcache */
      invalidate_opcache(vm);
    }
  }
}

static void xfer_w(struct cvm *vm, unsigned int cfa)
{
  unsigned int addr;

  vm->w = cfa + DATABYTES;
  addr = fetch(vm, cfa);
  jmp(vm, addr);
}

static void sp_store(struct cvm *vm, unsigned int n)
{
  stack_set_idx(&vm->p, n);
}

static void rp_store(struct cvm *vm, unsigned int n)
{
  stack_set_idx(&vm->r, n);
}

static unsigned int depth(struct cvm *vm)
{
  return stack_depth(&vm->p);
}

static void set_tos(struct cvm *vm, unsigned int value)
{
  stack_set_tos(&vm->p, value);
}

static void set_nos(struct cvm *vm, unsigned int value)
{
  stack_set_nos(&vm->p, value);
}

static unsigned int pick(struct cvm *vm, unsigned int offset)
{
  unsigned int value;

  value = stack_pick(&vm->p, offset);

  return value;
}

static void roll(struct cvm *vm, int offset)
{
  stack_roll(&vm->p, offset);
}

static void rot(struct cvm *vm)
{
  stack_rot(&vm->p);
}

static void dash_rot(struct cvm *vm)
{
  stack_dash_rot(&vm->p);
}

static void swap(struct cvm *vm)
{
  stack_swap(&vm->p);
}

static unsigned int tos(struct cvm *vm)
{
  unsigned int value;

  value = stack_tos(&vm->p);

  return value;
}

static unsigned int nos(struct cvm *vm)
{
  unsigned int value;

  value = stack_nos(&vm->p);

  return value;
}

static unsigned int pop(struct cvm *vm)
{
  unsigned int value;

  value = stack_pop(&vm->p);

  return value;
}

static unsigned int rdepth(struct cvm *vm)
{
  unsigned int value;

  value = stack_depth(&vm->r);

  return value;
}

static unsigned int rpick(struct cvm *vm, unsigned int offset)
{
  unsigned int value;

  value = stack_pick(&vm->r, offset);

  return value;
}

static unsigned int rtos(struct cvm *vm)
{
  return stack_tos(&vm->r);
}

static unsigned int rnos(struct cvm *vm)
{
  unsigned int value;

  value = stack_nos(&vm->r);

  return value;
}

static void rpush(struct cvm *vm, unsigned int value)
{
  stack_push(&vm->r, value);
}

static unsigned int rpop(struct cvm *vm)
{
  unsigned int value;

  value = stack_pop(&vm->r);

  return value;
}

static void set_rtos(struct cvm *vm, unsigned int value)
{
  stack_set_tos(&vm->r, value);
}

static unsigned int integer(int value)
{
  return (unsigned int)value;
}

static unsigned int _unsigned(int value)
{
  return value;
}

static unsigned int hi(unsigned long long uu)
{
  return uu>>32;
}

static unsigned int lo(unsigned long long uu)
{
  return uu & 0xffffffff;
}

static unsigned long long udouble(unsigned int ulow, unsigned int uhigh)
{
  return (((unsigned long long)uhigh<<32) | ulow);
}

static unsigned int boolean(unsigned int u)
{
  return u ? -1 : 0;
}

static unsigned int word_align(unsigned int byte_addr)
{
  unsigned int byte_offset;

  byte_offset = byte_addr % DATABYTES;

  if (byte_offset != 0) {
    byte_addr += (DATABYTES - byte_offset);
  }

  return byte_addr;
}

/* support */

static void unloop(struct cvm *vm)
{
  rpop(vm); /* limit */
  rpop(vm); /* start */
  rpop(vm); /* dest */
}

static void reset(struct cvm *vm)
{
  stack_reset(&vm->r);
  stack_reset(&vm->p);
  vm->pc = 0;
  vm->ip = 0;
  vm->w = 0;
  invalidate_opcache(vm);
}

static void io(struct cvm *vm, int op)
{
  int c;

  switch (op) {
  case IO_TX_STORE:
    (void)pop(vm); /* opcode */
    c = pop(vm);
    putchar(c);
    break;
  case IO_TX_QUESTION:
    set_tos(vm, -1);
    break;
  case IO_RX_FETCH:
    c = getchar();
    /* convert lf to cr for non-tty input */
    if (!vm->tty && c == '\n') {
      c = '\r';
    }
    set_tos(vm, c);
    break;
  case IO_RX_QUESTION:
    set_tos(vm, -1);
    break;
  case IO_MEM_LIMIT:
    set_tos(vm, DEFAULT_MEM_SIZE);
    break;
  case IO_HALT:
  default:
    (void)pop(vm); /* opcode */
    if (vm->verbose) {
      fprintf(stderr, "Stopping (%d)...\r\n", op);
    }
    vm->running = 0;
    break;
  }
}

static void step(struct cvm *vm)
{
  int op;
  int n;
  int r;

  if (vm->opc_idx < 0) {
    vm->opcache = fetch(vm, vm->pc);
    vm->opc_idx = 0;
  }
  op = byte_at(vm->opcache, vm->opc_idx);
  r = (op & OP_R);
  n = (op & OP_N);
  if (op & OP_T) {
    unsigned int data;
    /* small push */

    data = small(n);
    trace(vm, TRACE_PUSHS, data, 0);
    push(vm, data);
  } else {
    /* type0 */
    trace(vm, TRACE_TYPE0, n, r);
    exec(vm, type0[n].op);
  }
  if (r) {
    xfer_w(vm, fetch(vm, vm->ip));
    next_ip(vm);
  }
  next_op(vm);
}

static int boot(struct cvm *vm)
{
  push(vm, vm->entry);
  vm->ip = vm->entry;
  next_ip(vm);
  exec(vm, vm_execute);
  vm->running = 1;
  if (sigsetjmp(vm->env, 1) && vm->verbose) {
    fprintf(stderr, "Returned from trap (%d)\n\r", vm->running);
  }
  while(vm->running) {
    step(vm);
  }

  return vm->err;
}

static void tty_ctl(struct cvm *vm, int dir)
{
  if (dir) {
    if (isatty(0)) {
      vm->tty = 1;
      system("stty raw -echo");
    }
  } else {
    if (vm->tty) {
      system("stty sane");
    }
  }
}

/* interrupt handling */
#define ERF (22*sizeof(int)) /* FIXME: needs to come from generated header */
static void trap(int signal, siginfo_t *info, void *context)
{
  int throw_code = signal - 1000;
  unsigned int erf;
  unsigned int sp;
  unsigned int rp;

  if (vm.verbose) {
    fprintf(stderr, "\r\nTrap on %d\r\n", signal);
  }
  rp = fetch(&vm, vm.u + ERF);
  if (rp) {
    /* set R */
    rp_store(&vm, rp);
    sp  = rpop(&vm);
    erf = rpop(&vm);
    /* store erf */
    store(&vm,  vm.u + ERF, erf);
    /* set sp */
    sp_store(&vm, sp);
    /* replace catch xt with throw code */
    set_tos(&vm, throw_code);

    if (vm.verbose) {
      fprintf(stderr, "Trap returning %d (%d) to %x\n\r",
              tos(&vm), depth(&vm), rtos(&vm));
    }
    /* point IP to word after catch */
    vm.ip = rpop(&vm);
  } else {
    if (vm.verbose) {
      fprintf(stderr, "No catch frame found\n");
    }
    vm.ip = vm.entry; /* back to the beginning... */
  }

  /* transfer to IP and restart instruction loop */
  xfer_w(&vm, fetch(&vm, vm.ip));
  next_ip(&vm);
  siglongjmp(vm.env, 1);
}

static int arm(struct cvm *vm)
{
  struct sigaction sa;
  int i;
  int rc = 0;

  memset(&sa, 0, sizeof(sa));
  sa.sa_sigaction = trap;
  sa.sa_flags = SA_SIGINFO;
  do {
    rc = sigemptyset(&sa.sa_mask);
    if (rc < 0) {
      break;
    }

    for (i=0; i<COUNT(trappable); i++) {
      rc = sigaddset(&sa.sa_mask, trappable[i]);
      if (rc < 0) {
        break;
      }
    }
    if (rc < 0) {
      break;
    }

    for (i=0; i<COUNT(trappable); i++) {
      rc = sigaction(trappable[i], &sa, NULL);
      if (rc < 0) {
        break;
      }
    }
  } while (0);

  return rc;
}


static int init(struct cvm *vm)
{
  int rc;

  memset(vm, 0, sizeof(*vm));
  tty_ctl(vm, 1);
  do {
    rc = stack_alloc(&vm->p, DEFAULT_STACK_SIZE);
    if (rc < 0) {
      break;
    }

    rc = stack_alloc(&vm->r, DEFAULT_STACK_SIZE);
    if (rc < 0) {
      break;
    }

    vm->mem_size = DEFAULT_MEM_SIZE;
    vm->mem = calloc(vm->mem_size, sizeof(vm->mem[0]));
    if (vm->mem == NULL) {
      rc = -1;
      break;
    }

    reset(vm);

    rc = arm(vm);
    if (rc < 0) {
      break;
    }
  } while (0);

  return rc;
}

static void deinit(struct cvm *vm)
{
  tty_ctl(vm, 0);
  stack_free(&vm->p);
  stack_free(&vm->r);
  free(vm->mem);
  vm->mem_size = 0;
}

static int bmem(struct cvm *vm, const char *file)
{
  FILE *f;
  size_t size;

  f = fopen(file, "r");
  if (f == NULL) {
    return -1;
  }
  size = fread(vm->mem, sizeof(vm->mem[0]), vm->mem_size, f);

  fclose(f);

  return (size > 0 ? 0 : -1);
}

static int vmwr(unsigned int addr, unsigned int value, void *data)
{
  struct cvm *vm = (struct cvm *)data;
  mem_store(vm, addr, value);

  return 0;
}

static int load(struct cvm *vm, const char *file, int binary)
{
  int rc;

  if (binary) {
    rc = bmem(vm, file);
  } else {
    rc = vmem(file, vmwr, vm);
  }
  if (!rc) {
    vm->entry = fetch(vm, 0);
    vm->u     = fetch(vm, DATABYTES);
  }
  return rc;
}


/* opcodes */

static void vm_nop(struct cvm *vm)
{
}

static void vm_reset(struct cvm *vm)
{
  reset(vm);
}

static void vm_store(struct cvm *vm)
{
  unsigned int addr = pop(vm);
  unsigned int value = pop(vm);

  store(vm, addr, value);
}

static void vm_star(struct cvm *vm)
{
  int n = __SIGNED(pop(vm));
  int m = __SIGNED(tos(vm));
  set_tos(vm, m * n);
}

static void vm_star_slash(struct cvm *vm)
{
  int c = __SIGNED(pop(vm));
  int b = __SIGNED(pop(vm));
  long long a = __SIGNED(tos(vm));
  long long n;
  lldiv_t qr;

  n = a * b;
  qr = lldiv(n,c);

  set_tos(vm, lo(qr.quot));
}

static void vm_star_slash_mod(struct cvm *vm)
{
  int c = __SIGNED(pop(vm));
  int b = __SIGNED(tos(vm));
  long long a = __SIGNED(nos(vm));
  long long n;
  lldiv_t qr;

  n = a * b;
  qr = lldiv(n,c);

  set_nos(vm, qr.rem);
  set_tos(vm, qr.quot);
}

static void vm_plus(struct cvm *vm)
{
  int n = __SIGNED(pop(vm));
  int m = __SIGNED(tos(vm));

  set_tos(vm, integer(m + n));
}

static void vm_minus(struct cvm *vm)
{
  int n = __SIGNED(pop(vm));
  int m = __SIGNED(tos(vm));

  set_tos(vm, m - n);
}

static void vm_slash(struct cvm *vm)
{
  int n = __SIGNED(pop(vm));
  int m = __SIGNED(tos(vm));
  ldiv_t qr;

  qr = ldiv(m,n);
  set_tos(vm, qr.quot);
}

static void vm_slash_mod(struct cvm *vm)
{
  int b = __SIGNED(tos(vm));
  int a = __SIGNED(nos(vm));
  ldiv_t qr;

  qr = ldiv(a,b);

  set_nos(vm, qr.rem);
  set_tos(vm, qr.quot);
}

static void vm_n_to_r(struct cvm *vm)
{
  unsigned int n = pop(vm);
  unsigned int i = n;

  while (i-- > 0) {
    rpush(vm, pop(vm));
  }
  rpush(vm, n);
}

static void vm_fetch(struct cvm *vm)
{
  set_tos(vm, fetch(vm, tos(vm)));
}

static void vm_and(struct cvm *vm)
{
  unsigned int n = pop(vm);

  set_tos(vm, tos(vm) & n);
}

static void vm_c_store(struct cvm *vm)
{
  unsigned int addr = pop(vm);
  unsigned int value = pop(vm);

  c_store(vm, addr, value);
}

static void vm_c_fetch(struct cvm *vm)
{
  set_tos(vm, c_fetch(vm, tos(vm)));
}

static void vm_depth(struct cvm *vm)
{
  push(vm, depth(vm));
}

static void vm_drop(struct cvm *vm)
{
  pop(vm);
}

static void vm_dup(struct cvm *vm)
{
  push(vm, tos(vm));
}

static void vm_execute(struct cvm *vm)
{
  xfer_w(vm, pop(vm));
}

static void vm_j(struct cvm *vm)
{
  push(vm, rpick(vm, 3));
}

static void vm_or(struct cvm *vm)
{
  unsigned int n = pop(vm);
  set_tos(vm, tos(vm) | n);
}

static void vm_over(struct cvm *vm)
{
  push(vm, nos(vm));
}

static void vm_n_r_from(struct cvm *vm)
{
  unsigned int n = rpop(vm);
  unsigned int i = n;

  while (i-- > 0) {
    push(vm, rpop(vm));
  }
  push(vm, n);
}

static void vm_r_fetch(struct cvm *vm)
{
  push(vm, rtos(vm));
}

static void vm_rot(struct cvm *vm)
{
  rot(vm);
}

static void vm_swap(struct cvm *vm)
{
  swap(vm);
}

static void vm_uless(struct cvm *vm)
{
  unsigned int u2 = _unsigned(pop(vm));
  unsigned int u1 = _unsigned(tos(vm));

  set_tos(vm, boolean(u1 < u2));
}

static void vm_um_star(struct cvm *vm)
{
  unsigned int b = _unsigned(tos(vm));
  unsigned long long  a = _unsigned(nos(vm));
  unsigned long long u = a * b;

  set_nos(vm, lo(u));
  set_tos(vm, hi(u));
}

static void vm_um_slash_mod(struct cvm *vm)
{
  unsigned int u1 = _unsigned(pop(vm));
  unsigned long long ud = udouble(nos(vm), tos(vm));

  set_nos(vm, integer(ud % u1));
  set_tos(vm, integer(ud / u1));
}

static void vm_xor(struct cvm *vm)
{
  unsigned int n = pop(vm);
  set_tos(vm, tos(vm) ^ n);
}

static void vm_plus_loop(struct cvm *vm)
{
  int incr = __SIGNED(pop(vm));
  int idx  = __SIGNED(rtos(vm));
  int idxp = idx + incr;
  int lim  = __SIGNED(rnos(vm));
  int terminate = _unsigned(idxp-lim) < _unsigned(idx-lim);

  if (incr < 0) {
    terminate = !terminate;
  }

  if (terminate) {
    unloop(vm);
    next_ip(vm);
  } else {
    set_rtos(vm, idxp);
    vm->ip = fetch(vm, vm->ip); /* branch back */
  }
}

static void vm_question_do(struct cvm *vm)
{
  unsigned int dest  = vm->ip;
  unsigned int start;
  unsigned int limit;

  next_ip(vm);

  start = pop(vm);
  limit = pop(vm);

  if (start == limit) {
    vm->ip = fetch(vm, dest); /* branch */
  } else {
    rpush(vm, dest);
    rpush(vm, limit);
    rpush(vm, start);
  }
}

static void vm_do(struct cvm *vm)
{
  unsigned int start;

  rpush(vm, vm->ip);
  next_ip(vm);
  start = pop(vm); /* start */
  rpush(vm, pop(vm)); /* limit */
  rpush(vm, start);
}

static void vm_docol(struct cvm *vm)
{
  rpush(vm, vm->ip);
  vm->ip = vm->w;
}

static void vm_does(struct cvm *vm)
{
  int offset;

  offset = vm->pc % DATABYTES;
  rpush(vm, vm->ip);
  vm->ip = vm->pc + (DATABYTES - offset);
  push(vm, vm->w);
}

static void vm_dovar(struct cvm *vm)
{
  push(vm, vm->w);
}

static void vm_dolit(struct cvm *vm)
{
  push(vm, fetch(vm, vm->ip));
  next_ip(vm);
}

static void vm_leave(struct cvm *vm)
{
  rpop(vm); /* index */
  rpop(vm); /* limit */
  vm->ip = fetch(vm, rpop(vm)); /* branch to end of loop */
}

static void vm_loop(struct cvm *vm)
{
  set_rtos(vm, rtos(vm) + 1);
  if (rnos(vm) != rtos(vm)) {
    vm->ip = fetch(vm, vm->ip); /* branch back */
  } else {
    unloop(vm);
    next_ip(vm);
  }
}

static void vm_reg_fetch(struct cvm *vm)
{
  enum reg_t reg;

  reg = (enum reg_t)pop(vm);

  switch (reg) {
  case REG_SP:
    push(vm, stack_depth(&vm->p));
    break;
  case REG_RP:
    push(vm, stack_depth(&vm->r));
    break;
  case REG_UP:
    push(vm, vm->u);
    break;
  default:
    vm_unsupported(vm);
    break;
  }
}

static void vm_reg_store(struct cvm *vm)
{
  enum reg_t reg;
  unsigned int val;

  reg = (enum reg_t)pop(vm);
  val = pop(vm);
  switch (reg) {
  case REG_SP:
    sp_store(vm, val);
    break;
  case REG_RP:
    rp_store(vm, val);
    break;
  case REG_UP:
    vm->u = val;
    break;
  default:
    vm_unsupported(vm);
    break;
  }
}

static void vm_s_quote(struct cvm *vm)
{
  unsigned int count;

  push(vm, vm->ip + 1);
  count = c_fetch(vm, vm->ip);
  push(vm, count);
  vm->ip = word_align(vm->ip + count + 1);
}

static void vm_dash_rot(struct cvm *vm)
{
  dash_rot(vm);
}

static void vm_pick(struct cvm *vm)
{
  set_tos(vm, pick(vm, tos(vm)+1));
}

static void vm_roll(struct cvm *vm)
{
  int n = __SIGNED(pop(vm));
  roll(vm, n);
}

static void vm_io(struct cvm *vm)
{
  io(vm, __SIGNED(tos(vm)));
}

static void vm_exit(struct cvm *vm)
{
  if (rdepth(vm) > 1) {
    vm->ip = rpop(vm);
  } else {
    if (vm->verbose) {
      fprintf(stderr, "Exiting because return stack is empty\n");
    }
    io(vm, IO_HALT);
  }
}

static void vm_branch(struct cvm *vm)
{
  vm->ip = fetch(vm, vm->ip);
}

static void vm_zero_branch_no_pop(struct cvm *vm)
{
  unsigned int ba = fetch(vm, vm->ip);
  if (tos(vm) == 0) {
    vm->ip = ba;
  } else {
    next_ip(vm);
  }
}

static void vm_zero_branch(struct cvm *vm)
{
  unsigned int ba = fetch(vm, vm->ip);
  if (pop(vm) == 0) {
    vm->ip = ba;
  } else {
    next_ip(vm);
  }
}

static void vm_zero_equal(struct cvm *vm)
{
  int n = __SIGNED(tos(vm));

  set_tos(vm, boolean(n == 0));
}

static void vm_zero_less(struct cvm *vm)
{
  int n = __SIGNED(tos(vm));

  set_tos(vm, boolean(n < 0));
}

static void vm_less(struct cvm *vm)
{
  int n = __SIGNED(pop(vm));
  int m = __SIGNED(tos(vm));

  set_tos(vm, boolean(m < n));
}

static void vm_two_star(struct cvm *vm)
{
  unsigned int u = tos(vm);

  set_tos(vm, u << 1);
}

static void vm_two_slash(struct cvm *vm)
{
  int n = tos(vm);

  set_tos(vm, n >> 1);
}

static void vm_u_two_slash(struct cvm *vm)
{
  unsigned int u = tos(vm);

  set_tos(vm, u >> 1);
}

static void vm_m_star_slash(struct cvm *vm)
{
  int d = __SIGNED(pop(vm));
  int m = __SIGNED(pop(vm));
  unsigned long long n = udouble(nos(vm),tos(vm));

  n *= m;
  n /= d;
  set_tos(vm, hi(n));
  set_nos(vm, lo(n));
}

static void vm_d_plus(struct cvm *vm)
{
  unsigned int _hi = pop(vm);
  unsigned int _lo = pop(vm);
  unsigned long long a = udouble(_lo, _hi);
  unsigned long long n = udouble(nos(vm), tos(vm));

  n += a;
  set_tos(vm, hi(n));
  set_nos(vm, lo(n));
}

static void vm_d_minus(struct cvm *vm)
{
  unsigned int _hi = pop(vm);
  unsigned int _lo = pop(vm);
  unsigned long long a = udouble(_lo, _hi);
  unsigned long long n = udouble(nos(vm), tos(vm));
  n -= a;

  set_tos(vm, hi(n));
  set_nos(vm, lo(n));
}

static void vm_to_r(struct cvm *vm)
{
  rpush(vm, pop(vm));
}

static void vm_r_from(struct cvm *vm)
{
  push(vm, rpop(vm));
}

static void vm_unsupported(struct cvm *vm)
{
  int supported = 0;
  assert(supported);
}

static void dump(struct cvm *vm, const char *file)
{
  FILE *fd;

  fd = fopen(file, "w");
  if (fd != NULL) {
    fwrite(vm->mem, vm->mem_size, sizeof(vm->mem[0]), fd);
    fclose(fd);
  } else {
    fprintf(stderr, "Cannot open %s: %s\n", file, strerror(errno));
  }
}

static void usage(void)
{
  fprintf(stderr,"cvm [-h] [-d] [-t] [-b] [-D] [image]\n");
  fprintf(stderr,"  -h        Print this message\n");
  fprintf(stderr,"  -d        Debug mode\n");
  fprintf(stderr,"  -t        Test mode\n");
  fprintf(stderr,"  -b        image is binary\n");
  fprintf(stderr,"  -D file   Dump memory to file\n");
}


int main(int argc, char *argv[])
{
  int debug = 0;
  int test = 0;
  int binary = 0;
  int verbose = 0;
  int c;
  int rc;
  const char *image = IMAGE;
  const char *dumpfile = NULL;

  while ((c = getopt(argc, argv, "dhtbvD:")) != EOF) {
    switch (c) {
    case 'd':
      debug = 1;
      break;
    case 't':
      test = 1;
      break;
    case 'b':
      binary = 1;
      break;
    case 'v':
      verbose = 1;
      break;
    case 'D':
      dumpfile = optarg;
      break;
    case 'h':
    default:
      usage();
      exit(0);
    }
  }


  if (optind < argc) {
    image = argv[optind];
  }

  /* no output buffering */
  setvbuf(stdout, NULL, _IONBF, 0);

  do {
    rc = init(&vm);
    if (rc < 0) {
      break;
    }

    vm.debug = debug;
    vm.test = test;
    vm.verbose = verbose;

    rc = load(&vm, image, binary);
    if (!rc) {
      if (dumpfile != NULL) {
        dump(&vm, dumpfile);
      } else {
        rc = boot(&vm);
      }
    }

    deinit(&vm);
    if (test) {
      fprintf(stderr, "===DONE===\n");
    }
  } while (0);

  return !!rc;
}
