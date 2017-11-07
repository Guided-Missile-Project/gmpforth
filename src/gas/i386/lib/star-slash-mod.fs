CODE */MOD
        popl    %ecx
        popl    %eax
        popl    %ebx
        imul    %ebx
        idiv    %ecx
        pushl   %edx
        pushl   %eax
        $NEXT
END-CODE
