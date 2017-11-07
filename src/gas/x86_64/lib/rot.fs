CODE ROT
        popq    %rax
        popq    %rbx
        popq    %rcx
        pushq   %rbx
        pushq   %rax
        pushq   %rcx
        $NEXT
END-CODE
