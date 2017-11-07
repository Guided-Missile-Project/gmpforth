CODE M+
        popl    %eax
        cdq
        addl    %eax, _SZ(%esp)
        adcl    %edx, (%esp)
        $NEXT
END-CODE
