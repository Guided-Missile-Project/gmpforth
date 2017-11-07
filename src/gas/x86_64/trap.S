#include        "asm/unistd.h"
#include        "asm/ioctls.h"
#include        "asm/signal.h"
#include        "syscall-linux.inc"
#include        "mdefs.inc"
#include        "defs.inc"

#define THROW_OFFSET 1000
#define UCONTEXT_EDI 13

        .globl  _arm
        .globl  _restart

        .macro $TRACE point
        $TRACE_LABEL trap, \point
        .endm

        .text

        .align  16
_arm:
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
        ret
        
        .align  16
_trap:
        /* %rdi:signum %rsi:*siginfo_t %rdx:*ucontext_t  */
        /* uses 1432 bytes of stack as of Linux 3.10 (SA_INFO no difference) */
        /* convert signum */
        movq    %rdi, %rax
        subq    $THROW_OFFSET, %rax
        movq    USER_ERF*_SZ(%r13), %rbx
        cmp     $0, %rbx
        jne     1f
        /* no error frame */
        $SYS4   __NR_rt_sigprocmask, $SIG_UNBLOCK, $sa_mask, $0, $8
        jmp     _restart
1:      movq    %rbx, %rbp              /* reset return stack */
        movq    (%rbp), %rsp            /* reset parameter stack */
        movq    _SZ(%rbp), %rcx
        movq    %rcx,USER_ERF*_SZ(%r13) /* set ERF */
        addq    $_SZ*2, %rbp
        movq    %rax, (%rsp)            /* set throw code */
        movq    (%rbp), %rsi
        addq    $_SZ, %rbp              /* point IP to word after catch */
        push    %rsi
        $SYS4   __NR_rt_sigprocmask, $SIG_UNBLOCK, $sa_mask, $0, $8
        pop     %rsi
        $NEXT
        $ENDCODE

        .data
sa_info:
sa_sigaction:
        .quad   _trap
sa_flags:
        /*
           Note:
            (1) Hard coded constants are used instead of the header symbols
                because the header symbols (from asm-generic) do not work
                with gas. True as of 2.6.32; may be fixed in later versions.

            (2) Even though the C library struct sigaction.sa_restorer field is 
                obsolete, the Linux x86_64 architecture requires the
                SA_RESTORER flag to be set even though we never return from a
                signal handler. If the flag is not set, a SEGV will be
                delivered to the application. True as of Linux version 3.17.

                Because we never return, a restorer function will never be
                called, so it can be set to 0.

                See $LINUX_SRC/arch/x86/kernel/signal.c for details of
                SA_RESTORER flag handling.
        */
        .quad   0x0000000004000004 /* SA_RESTORER|SA_INFO */
sa_restorer:
        .quad   0
sa_mask:
        .quad   0x0000000000008efb
        .end
