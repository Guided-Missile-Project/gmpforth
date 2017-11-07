CODE D+
        popq    %rdx
        popq    %rax
        addq    %rax, _SZ(%rsp)
        adcq    %rdx, (%rsp)
        $NEXT
END-CODE
