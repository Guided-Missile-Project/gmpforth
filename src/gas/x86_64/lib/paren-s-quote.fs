CODE (s")
        /* get string storage address and length byte */
        movq    %rsi, %rax
        movzbq  (%rsi), %rbx
        /* point to the first character of the string and push to stack */
        incq    %rax
        pushq   %rax
        /* push the length byte and increment for storage length of string */
        pushq   %rbx
        incq    %rbx
        /* align storage length (%rbx) to word boundary */
        $RALIGN %rbx
        /* point %rsi to word following the string */
        addq    %rbx, %rsi
        $NEXT
END-CODE
COMPILE-ONLY

