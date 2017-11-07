CODE FM/MOD
        popl    %ebx
        movl    %ebx, %ecx /* save divisor in ecx */
        popl    %edx
        popl    %eax
        idivl   %ebx
        cmpl    $0, %edx
        $TRANSFER
        je      1f         /* no fixup if remainder is zero */
        $BLOCK
        movl    %edx, %ebx /* check if signs of remainder and divisor */
        xorl    %ecx, %ebx
        $TRANSFER
        jge     1f
                           /* if signs of divisor and remainder differ */
        $BLOCK
        decl    %eax       /*   decrement quotient */
        addl    %ecx, %edx /*   increment remainder by divisor */
1:
        $BLOCK
        pushl   %edx /* remainder */
        pushl   %eax /* quotient */
        $NEXT
END-CODE
