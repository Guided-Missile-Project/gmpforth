CODE 0<
        xor     %rax, %rax
        cmp     %rax, (%rsp)
        setl    %al
        neg     %rax
        mov     %rax, (%rsp)
        $NEXT
END-CODE
