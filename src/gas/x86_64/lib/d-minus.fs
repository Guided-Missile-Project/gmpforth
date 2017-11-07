CODE D-
        popq    %rdx
        popq    %rax
        subq    %rax, _SZ(%rsp)
        sbbq    %rdx, (%rsp)
        $NEXT
END-CODE
