CODE FM/MOD
        popq    %rbx
        movq    %rbx, %rcx /* save divisor in rcx */
        popq    %rdx
        popq    %rax
        idivq   %rbx
        cmpq    $0, %rdx
        je      1f         /* no fixup if remainder is zero */
        movq    %rdx, %rbx /* check if signs of remainder and divisor */
        xorq    %rcx, %rbx
        jge     1f
                           /* if signs of divisor and remainder differ */
        decq    %rax       /*   decrement quotient */
        addq    %rcx, %rdx /*   increment remainder by divisor */
1:
        pushq   %rdx /* remainder */
        pushq   %rax /* quotient */
        $NEXT
END-CODE
