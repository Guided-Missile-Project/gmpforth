CODE XOR
        popq    %rbx
        popq    %rax
        xorq    %rbx, %rax
        pushq   %rax
        $NEXT
END-CODE
