CODE 2>R
        popq    %rbx
        popq    %rax
        subq    $_SZ*2, %rbp
        movq    %rbx, (%rbp)
        movq    %rax, _SZ(%rbp)
        $NEXT
END-CODE
COMPILE-ONLY

