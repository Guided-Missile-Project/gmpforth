CODE M+
        popq    %rax
        cqo
        addq    %rax, _SZ(%rsp)
        adcq    %rdx, (%rsp)
        $NEXT
END-CODE
