CODE !
        popq    %rbx
        popq    %rax
        movq    %rax, (%rbx)
        $NEXT
END-CODE
