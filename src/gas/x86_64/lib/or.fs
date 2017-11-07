CODE OR
        popq    %rbx
        popq    %rax
        orq     %rbx, %rax
        pushq   %rax
        $NEXT
END-CODE
