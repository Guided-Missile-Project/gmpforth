        .macro  $SYS sys
        movl    $\sys, %eax
        int     $0x80
        .endm

        .macro  $SYS1 sys, p1
        movl    \p1, %ebx
        $SYS    \sys
        .endm

        .macro  $SYS2 sys, p1, p2
        movl    \p2, %ecx
        $SYS1   \sys, \p1
        .endm

        .macro  $SYS3 sys, p1, p2, p3
        movl    \p3, %edx
        $SYS2   \sys, \p1, \p2
        .endm

        .macro  $SYS4 sys, p1, p2, p3, p4
        mov     \p4, %esi
        $SYS3   \sys, \p1, \p2, \p3
        .endm

        .macro  $SYS5 sys, p1, p2, p3, p4, p5
        mov     \p5, %edi
        $SYS4   \sys, \p1, \p2, \p3, \p4
        .endm

        .macro  $SYS6 sys, p1, p2, p3, p4, p5, p6
        mov     \p6, %ebp
        $SYS5   \sys, \p1, \p2, \p3, \p4, \p5
        .endm


