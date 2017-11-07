CODE UM/MOD
        popq    %rbx
        popq    %rdx
        popq    %rax
        divq    %rbx
        pushq   %rdx
        pushq   %rax
        $NEXT
END-CODE
