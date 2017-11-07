CODE D+
        popl    %edx
        popl    %eax
        addl    %eax, _SZ(%esp)
        adcl    %edx, (%esp)
        $NEXT
END-CODE
