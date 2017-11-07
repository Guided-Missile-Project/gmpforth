CODE NR>
        movq    (%rbp), %rbx
        movq    %rbx, %rcx
        addq    $_SZ, %rbp
1:      pushq   (%rbp)
        addq    $_SZ, %rbp
        decq    %rcx
        jne     1b
        pushq   %rbx
        $NEXT
END-CODE
COMPILE-ONLY

