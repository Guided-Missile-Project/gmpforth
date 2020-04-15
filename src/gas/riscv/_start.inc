        .globl  _start
        .globl  __start
        .globl  _restart
        .globl  _exit
        .globl  _ENTRY
        .globl  _USER
        .globl  _SP0
        .globl  _END_DICT
        .globl  __edict
        .globl  does_handler
        .globl  _spsave
        .globl  _sysret
        .globl  _osdata
        .globl  _pool
        .globl  __global_pointer$ /* Defined in linker script */
        .globl  __fini
        .globl  __args
        .globl  __sp0
        .globl  __rp0
        .globl  __ex0
        .globl  __user
        .globl  __entry

        .set SP_SLACK, 1        /* need one word of slack space in pstack */
        .set DICT_IN_DATA, 1

        .text
        $BLOCK
_start:
__start:
        /* FIXME save OS process context
           From uclibc crt1.S:
             v0: atexit function
             sp: argc, argv[0], ..., NULL, envp[0], ..., NULL
        */
_restart:
        .option push
        .option norelax
        $LA gp, __global_pointer$
        .option pop

        $STA    a0, __fini
        $STA    sp, __args

        $LDA    sp, __sp0
        $LDA    rp, __rp0

        /* set ipp to _exit0, _ENTRY's DOCOL will push to return stack */
        $LDA    ipp, __ex0

        /* set USER area */
        $LDA    u, __user

        $LI     pp1, 0  /* clear cached ptos */

        /* execute from _ENTRY */
        $LDA    w, __entry
        $EXECUTE
        $ENDCODE

        $ALIGN
_exit:  $BLOCK
        /* for test purposes: */
        /*  flush TOS to memory */
        /*  save final stack pointer */
        $S_PTOS pp1
        $STA    sp, _spsave
        /* return to OS */
_sysret:                /* testing breakpoint */
        $LDA    t2, __fini
        beqz    t2, 1f
        jalr    t2      /* OS fini */
1:
        $SET    a0, 0
        $SYS    SYS_EXIT
1:
        j       1b
        $ENDCODE

        .data
        /*.section .sdata - doesn't work because data is uninitialized...*/

__sp0:  $WORD   _SP0
__rp0:  $WORD   _RP0
__ex0:  $WORD   _exit0
__user: $WORD   _USER
__entry:$WORD   _ENTRY
__edict:$WORD   _END_DICT

_osdata:
__fini: $WORD   0       /* r0  platform finalization */
__args: $WORD   0       /* sp  argc/argv, etc. */
_spsave:
        $WORD   0


        .section .data
        /* colon def fragment pushed on return stack to exit after
          _ENTRY returns. */
_exit0: $WORD   _exit1
        /* code def to _exit */
_exit1: $WORD   _exit
