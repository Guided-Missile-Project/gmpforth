CODE /MOD
        popq    %rbx
        popq    %rax
        cqo
        idivq   %rbx
        pushq   %rdx
        pushq   %rax
        $NEXT
END-CODE
