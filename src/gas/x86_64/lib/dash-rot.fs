CODE -ROT
        popq    %rax
        popq    %rbx
        popq    %rcx
        pushq   %rax
        pushq   %rcx
        pushq   %rbx
        $NEXT
END-CODE
