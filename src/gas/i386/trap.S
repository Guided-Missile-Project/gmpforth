#include        "asm/unistd.h"
#include        "asm/ioctls.h"
#include        "asm/signal.h"
#include        "syscall-linux.inc"
#include        "mdefs.inc"
#include        "defs.inc"

#define SIGNUM_ARG 4
#define SIGINFO_ARG 8
#define UCONTEXT_ARG 12
#define THROW_OFFSET 1000

        .globl  _arm
        .globl  _restart

        .macro $TRACE point
        $TRACE_LABEL trap, \point
        .endm

        .text

        .align  16
_arm:
        $BLOCK
        /* TODO: iterate across sa_mask */
        $SYS4   __NR_rt_sigaction, $1, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $2, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $4, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $5, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $6, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $7, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $8, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $10, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $11, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $12, $sa_info, $0, $8
        $SYS4   __NR_rt_sigaction, $16, $sa_info, $0, $8
        $TRANSFER
        ret
        
        .align  16
_trap:
        /* uses 1268 bytes of stack as of Linux 3.10 (SA_INFO no difference) */
        $BLOCK
        /* save signum */
        movl    SIGNUM_ARG(%esp), %eax
        subl    $THROW_OFFSET, %eax
        movl    USER_ERF*_SZ(%edi), %ebx
        cmp     $0, %ebx
        $TRANSFER
        jne     1f
        /* no error frame */
        $BLOCK
        $SYS4   __NR_rt_sigprocmask, $SIG_UNBLOCK, $sa_mask, $0, $8
        $TRANSFER
        jmp     _restart
1:      $BLOCK
        movl    %ebx, %ebp              /* reset return stack */
        movl    (%ebp), %esp            /* reset parameter stack */
        movl    _SZ(%ebp), %ecx
        movl    %ecx,USER_ERF*_SZ(%edi) /* set ERF */
        addl    $_SZ*2, %ebp
        movl    %eax, (%esp)            /* set throw code */
                                        /* restore blocked signals */
        $SYS4   __NR_rt_sigprocmask, $SIG_UNBLOCK, $sa_mask, $0, $8
        movl    (%ebp), %esi
        addl    $_SZ, %ebp              /* point IP to word after catch */
        $NEXT
        $ENDCODE

        .data
sa_info:
sa_sigaction:
        .long   _trap
sa_flags:
        .long   0x00000004 /* SA_INFO - header file broken */
sa_restorer:
        .long   0x00000000
sa_mask:
        .long   0x00008efb
        .long   0x00000000
        .end
