CODE 0=
        xor     %rax, %rax
        cmp     %rax, (%rsp)
        setz    %al
        neg     %rax
        mov     %rax, (%rsp)
        $NEXT
END-CODE
