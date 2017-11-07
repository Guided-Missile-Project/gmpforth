CODE /MOD
        popl    %ebx
        popl    %eax
        cdq
        idivl   %ebx
        pushl   %edx
        pushl   %eax
        $NEXT
END-CODE
