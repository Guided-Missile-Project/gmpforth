CODE */MOD
        popq    %rcx
        popq    %rax
        popq    %rbx
        imul    %rbx
        idiv    %rcx
        pushq   %rdx
        pushq   %rax
        $NEXT
END-CODE
