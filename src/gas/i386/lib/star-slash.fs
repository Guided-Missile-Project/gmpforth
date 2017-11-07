CODE */
        popl    %ecx
        popl    %eax
        popl    %ebx
        imul    %ebx
        idiv    %ecx
        pushl   %eax
        $NEXT
END-CODE
