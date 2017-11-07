        .globl  _start
        .globl  _restart
        .globl  _exit
        .globl  _ENTRY
        .globl  _USER
        .globl  _SP0
        .globl  does_handler
        .globl  _spsave
        .globl  _sysret
        .globl  _osdata

        .set SP_SLACK, 1                @ need one word of slack space in pstack
        .set DICT_IN_DATA, 1

        .include "syscall-linux.inc"

        $BLOCK
_start:
        @ explicitly using OS trap to return so nothing to save here for return
        @ save OS process context
        adr     t1, __osdata
        ldr     t1, [t1]
        str     r0, [t1], _SZ   @ $LINUX ELF_PLAT_INIT
        str     r1, [t1], _SZ   @ $LINUX FIXME
        str     sp, [t1], _SZ   @ argc/argv/etc see $LINUX:fs/binfmt_elf.c
        str     r10, [t1], _SZ  @ $LINUX arm start_thread()
_restart:
        adr     t1, __pool
        ldr     spp, [t1], _SZ  @ _SP0
        ldr     rp, [t1], _SZ   @ _RP0

        /* set ipp to _exit0, _ENTRY's DOCOL will push to return stack */
        ldr     ipp, [t1], _SZ  @ _exit0

        /* set USER area */
        ldr    u, [t1], _SZ @ _USER

        $SET    pp1, 0          @ clear cached ptos

        /* execute from _ENTRY */
        ldr     w, [t1], _SZ @ _ENTRY
        $EXECUTE
        $ENDCODE

        $ALIGN
_exit:  $BLOCK
        @ for test purposes:
        @  flush TOS to memory
        @  save final stack pointer
        $S_PTOS pp1
        adr     t1, __spsave
        ldr     t1, [t1]
        str     spp, [t1]

        @ return to OS
_sysret:                @ testing breakpoint
        adr     t1, __osdata
        ldr     t1, [t1]        @ base of _osdata
        ldr     t1, [t1]        @ fini
        cmp     t1, 0
        blxne   t1
        $SYS1   248, 0          @ sys_group_exit
        $ENDCODE

        @ handle address literals explicitly
__spsave:
        $WORD   _spsave
__pool:
        $WORD   _SP0
        $WORD   _RP0
        $WORD   _exit0
        $WORD   _USER
        $WORD   _ENTRY
__osdata:
        $WORD   _osdata

        .data
_osdata:
        $WORD   0       @ r0  platform finalization
        $WORD   0       @ r1  FIXME where is this set?
        $WORD   0       @ sp  argc/argv, etc.
        $WORD   0       @ r10 current->mm->start_data
_spsave:
        $WORD   0
        /* colon def fragment pushed on return stack to exit after
          _ENTRY returns. */
_exit0: $WORD   _exit1
        /* code def to _exit */
_exit1: $WORD   _exit
