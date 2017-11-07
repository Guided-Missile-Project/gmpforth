CODE AND
        popq    %rbx
        popq    %rax
        andq    %rbx, %rax
        pushq   %rax
        $NEXT
END-CODE
