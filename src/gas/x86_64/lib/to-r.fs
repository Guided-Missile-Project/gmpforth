CODE >R
        popq    %rax
        subq    $_SZ, %rbp
        movq    %rax, (%rbp)
        $NEXT
END-CODE
COMPILE-ONLY

