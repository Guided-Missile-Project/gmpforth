CODE 2R>
        pushl   _SZ(%ebp)
        pushl   (%ebp)
        addl    $_SZ*2, %ebp
        $NEXT
END-CODE
COMPILE-ONLY

