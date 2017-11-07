CODE XOR
        popl    %ebx
        popl    %eax
        xorl    %ebx, %eax
        pushl   %eax
        $NEXT
END-CODE
