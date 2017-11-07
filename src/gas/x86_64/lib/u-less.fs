CODE U<
        xor     %rax, %rax
        popq    %rbx
        cmpq    %rbx, (%rsp)
        sbbq    %rax, %rax
        movq    %rax, (%rsp)
        $NEXT
END-CODE
