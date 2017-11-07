CODE 2>R
        popl    %ebx
        popl    %eax
        subl    $_SZ*2, %ebp
        movl    %ebx, (%ebp)
        movl    %eax, _SZ(%ebp)
        $NEXT
END-CODE
COMPILE-ONLY

