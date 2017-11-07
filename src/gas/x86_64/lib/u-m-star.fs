CODE UM*
        popq    %rbx
        popq    %rax
        mulq    %rbx
        pushq   %rax
        pushq   %rdx
        $NEXT
END-CODE
