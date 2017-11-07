CODE *
        popq    %rbx
        popq    %rax
        imul    %rbx
        pushq   %rax
        $NEXT
END-CODE
