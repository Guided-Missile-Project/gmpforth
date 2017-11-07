CODE N>R
        popl    %ebx
        movl    %ebx, %ecx
1:      subl    $_SZ, %ebp
        popl    (%ebp)
        decl    %ecx
        jne     1b
        subl    $_SZ, %ebp
        movl    %ebx, (%ebp)
        $NEXT
END-CODE
COMPILE-ONLY

