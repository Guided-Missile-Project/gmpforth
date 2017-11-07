CODE (?do)
        lodsq           /* %rax: branch addr */
        popq    %rbx    /* start */
        popq    %rcx    /* limit */
        cmpq    %rbx, %rcx
        je      1f
        subq    $_SZ*3, %rbp
        movq    %rbx, (%rbp)
        movq    %rcx, _SZ(%rbp)
        movq    %rax, _SZ*2(%rbp)
        jmp     2f
1:      movq    %rax, %rsi
2:
        $NEXT
END-CODE
COMPILE-ONLY

