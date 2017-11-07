CODE (leave)
        movq    _SZ*2(%rbp), %rsi
        addq    $_SZ*3, %rbp
        $NEXT
END-CODE
COMPILE-ONLY

