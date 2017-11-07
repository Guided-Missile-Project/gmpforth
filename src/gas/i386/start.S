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
        movl    $_SP0, %esp
        movl    $_RP0, %ebp

        /* set %esi to _exit0, _ENTRY's DOCOL will push to return stack */
        movl    $_exit0, %esi

        /* set USER area */
        movl    $_USER, %edi

        /* execute from _ENTRY */
        movl    $_ENTRY, %eax
        $TRANSFER_CFA
        jmp     *(%eax)
        $ENDCODE

        .align  16
_exit:  $BLOCK
        xchg    sp_save, %esp

_atexit_begin:
        /* call any atexit registered functions */
        movl    aelist, %eax
1:
        cmpl    $0, %eax
        $TRANSFER
        je      _atexit_end
        $BLOCK
        addl    $_SZ, %eax
        call    *(%eax)
        $TRANSFER
        jmp     1b
_atexit_end:
        $BLOCK
        $SYS1   __NR_exit, $0
        $TRANSFER
        ret
        $ENDCODE

        .align 16
_init:  $BLOCK
        cld
        movl    %esp, sp_save
        $TRANSFER
        ret
        $ENDCODE
                
        .data

        /* colon def fragment pushed on return stack to exit after
          _ENTRY returns. */
_exit0: .long   _exit1
        /* code def to _exit */
_exit1: .long   _exit

        .bss
sp_save:
        .space  4
aelist: .word   0
