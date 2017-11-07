CODE D-
        popl    %edx
        popl    %eax
        subl    %eax, _SZ(%esp)
        sbbl    %edx, (%esp)
        $NEXT
END-CODE
