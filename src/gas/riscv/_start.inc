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
        .globl  _gp             /* Defined in linker script */

        .set SP_SLACK, 1        /* need one word of slack space in pstack */
        .set DICT_IN_DATA, 1
        .set _NO_DOT_END, 1     /* mips .end is different... */
        .set    noreorder

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
        $LA     $gp, _gp
        $ST     $v0, $gp, %gp_rel(__fini)
        $ST     spp, $gp, %gp_rel(__args)
        $LD     spp, $gp, %gp_rel(__sp0)
        $LD     rp,  $gp, %gp_rel(__rp0)

        /* set ipp to _exit0, _ENTRY's DOCOL will push to return stack */
        $LD     ipp, $gp, %gp_rel(__ex0)

        /* set USER area */
        $LD     u, $gp, %gp_rel(__user)

        xor     pp1, pp1, pp1   /* clear cached ptos */

        /* execute from _ENTRY */
        $LD     w, $gp, %gp_rel(__entry)
        $EXECUTE
        $ENDCODE

        $ALIGN
_exit:  $BLOCK
        /* for test purposes: */
        /*  flush TOS to memory */
        /*  save final stack pointer */
        $S_PTOS pp1
        $ST     spp, $gp, %gp_rel(_spsave)

        /* return to OS */
_sysret:                /* testing breakpoint */
        $LD     t2, $gp, %gp_rel(__fini)
        beqz    t2, 1f
        nop
        jal     t2      /* OS fini */
        nop
1:
        $SET    $a0, 0
        $SYS    SYS_EXIT /* sys_exit(0) */
1:
        b       1b
        nop
        $ENDCODE

        .sdata
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


        .data
        /* colon def fragment pushed on return stack to exit after
          _ENTRY returns. */
_exit0: $WORD   _exit1
        /* code def to _exit */
_exit1: $WORD   _exit
