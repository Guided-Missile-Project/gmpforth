CODE +
        popq    %rax
        addq    (%rsp), %rax
        movq    %rax, (%rsp)
        $NEXT
END-CODE
