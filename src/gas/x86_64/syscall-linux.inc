        .macro  $SYS sys
        mov     $\sys, %rax
        syscall
        .endm

        .macro  $SYS1 sys, p1
        mov     \p1, %rdi
        $SYS    \sys
        .endm

        .macro  $SYS2 sys, p1, p2
        mov     \p2, %rsi
        $SYS1   \sys, \p1
        .endm

        .macro  $SYS3 sys, p1, p2, p3
        mov     \p3, %rdx
        $SYS2   \sys, \p1, \p2
        .endm

        .macro  $SYS4 sys, p1, p2, p3, p4
        mov     \p4, %r10
        $SYS3   \sys, \p1, \p2, \p3
        .endm

        .macro  $SYS5 sys, p1, p2, p3, p4, p5
        mov     \p5, %r8
        $SYS4   \sys, \p1, \p2, \p3, \p4
        .endm

        .macro  $SYS6 sys, p1, p2, p3, p4, p5, p6
        mov     \p6, %r9
        $SYS5   \sys, \p1, \p2, \p3, \p4, \p5
        .endm

