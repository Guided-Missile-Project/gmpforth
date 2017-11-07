CODE <
        xor     %rax, %rax
        popq    %rbx
        cmpq    %rbx, (%rsp)
        setl    %al
        negq    %rax
        movq    %rax, (%rsp)
        $NEXT
END-CODE
