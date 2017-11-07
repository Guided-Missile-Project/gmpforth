CODE C@
        popq    %rbx
        movzbq  (%rbx), %rax
        pushq   %rax
        $NEXT
END-CODE
