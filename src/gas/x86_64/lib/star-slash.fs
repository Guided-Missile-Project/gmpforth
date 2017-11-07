CODE */
        popq    %rcx
        popq    %rax
        popq    %rbx
        imul    %rbx
        idiv    %rcx
        pushq   %rax
        $NEXT
END-CODE
