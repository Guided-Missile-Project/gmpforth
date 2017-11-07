CODE /
        popq    %rbx
        popq    %rax
        cqo
        idivq   %rbx
        pushq   %rax
        $NEXT
END-CODE
