CODE UM/MOD
        popl    %ebx
        popl    %edx
        popl    %eax
        divl    %ebx
        pushl   %edx
        pushl   %eax
        $NEXT
END-CODE
