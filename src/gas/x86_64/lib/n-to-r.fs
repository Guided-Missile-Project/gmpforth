CODE N>R
        popq    %rbx
        movq    %rbx, %rcx
1:      subq    $_SZ, %rbp
        popq    (%rbp)
        decq    %rcx
        jne     1b
        subq    $_SZ, %rbp
        movq    %rbx, (%rbp)
        $NEXT
END-CODE
COMPILE-ONLY

