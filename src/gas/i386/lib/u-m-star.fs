CODE UM*
        popl    %ebx
        popl    %eax
        mull    %ebx
        pushl   %eax
        pushl   %edx
        $NEXT
END-CODE
