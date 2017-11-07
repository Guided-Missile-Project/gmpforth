CODE 2R>
        pushq   _SZ(%rbp)
        pushq   (%rbp)
        addq    $_SZ*2, %rbp
        $NEXT
END-CODE
COMPILE-ONLY

