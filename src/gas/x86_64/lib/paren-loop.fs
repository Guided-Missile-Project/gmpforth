CODE (loop)
        /* get index and increment */
        movq    (%rbp), %rax
        incq    %rax
        /* test index against limit */
        cmpq    _SZ(%rbp), %rax
        je      1f
        /* keep going - move new index to return stack */
        movq    %rax, (%rbp)
        movq    (%rsi), %rsi
        $NEXT
1:      /* done looping */
        addq    $_SZ, %rsi
        addq    $_SZ*3, %rbp
        $NEXT
END-CODE
COMPILE-ONLY

