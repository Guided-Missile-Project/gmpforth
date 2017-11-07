CODE -
        popq    %rbx
        popq    %rax
        subq    %rbx, %rax
        pushq   %rax
        $NEXT
END-CODE
