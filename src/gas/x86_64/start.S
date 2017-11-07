#include        "asm/unistd.h"
#include        "asm/ioctls.h"
#include        "syscall-linux.inc"
#include        "mdefs.inc"
#include        "defs.inc"

        .globl  _start
        .globl  _restart
        .globl  _arm
        .globl  _exit
        .globl  aelist
        .globl  _ENTRY
        .globl  _USER

        .macro $TRACE point
        $TRACE_LABEL start, \point
        .endm

        .text

        .align  16
_start:
        $BLOCK
        call    _init
        call    _arm
_restart:       
        movq    $_SP0, %rsp
        movq    $_RP0, %rbp

        /* set %rsi to _exit0, _ENTRY's DOCOL will push to return stack */
        movq    $_exit0, %rsi

        /* set USER area */
        movq    $_USER, %r13

        /* execute from _ENTRY */
        movq    $_ENTRY, %rax
        $TRANSFER_CFA
        jmp     *(%rax)
        $ENDCODE

        .align  16
_exit:  $BLOCK
        xchg    sp_save, %rsp

_atexit_begin:
        /* call any atexit registered functions */
        movq    aelist, %rax
1:
        cmpq    $0, %rax
        $TRANSFER
        je      _atexit_end
        $BLOCK
        addq    $_SZ, %rax
        call    *(%rax)
        $TRANSFER
        jmp     1b
_atexit_end:
        $BLOCK
        $SYS1   __NR_exit, $0
        ret
        $ENDCODE

        .align 16
_init:          $BLOCK
        cld
        movq    %rsp, sp_save
        $TRANSFER
        ret
        $ENDCODE

        .data

        /* colon def fragment pushed on return stack to exit after
          _ENTRY returns. */
_exit0: .quad   _exit1
        /* code def to _exit */
_exit1: .quad   _exit

        .bss
sp_save:
        .space  _SZ
aelist: .quad   0
