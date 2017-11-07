CODE (do)
        lodsq           /* %rax: branch addr */
        popq    %rbx    /* start */
        popq    %rcx    /* limit */
        subq    $_SZ*3, %rbp
        movq    %rbx, (%rbp)
        movq    %rcx, _SZ(%rbp)
        movq    %rax, _SZ*2(%rbp)
        $NEXT
END-CODE
COMPILE-ONLY

