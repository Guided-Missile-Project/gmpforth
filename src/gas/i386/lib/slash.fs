CODE /
        popl    %ebx
        popl    %eax
        cdq
        idivl   %ebx
        pushl   %eax
        $NEXT
END-CODE
