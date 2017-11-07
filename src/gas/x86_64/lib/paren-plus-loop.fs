CODE (+loop)
        movq    (%rbp), %rbx
        popq    %rax
        movq    %rax, %rcx
        addq    %rbx, %rax
        movq    %rax, (%rbp) /* proactively update idx */
        subq    _SZ(%rbp), %rbx
        subq    _SZ(%rbp), %rax
        xorq    %rdx, %rdx
        cmpq    %rbx, %rax      /* idx-lim u< idx'-lim */
        sbbq    %rdx, %rdx      /* %rdx: -1 if u< */
        xorq    %rcx, %rdx      /* combine with sign */
        $TRANSFER
        jl      1f
        /* keep going */
        $BLOCK
        movq    (%rsi), %rsi
        $TRANSFER
        jmp     2f
1:      /* done looping */
        $BLOCK
        addq    $_SZ, %rsi
        addq    $_SZ*3, %rbp
2:
        $NEXT
END-CODE
COMPILE-ONLY
