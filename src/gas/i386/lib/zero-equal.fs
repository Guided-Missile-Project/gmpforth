CODE 0=
        xorl    %eax, %eax
        cmpl    %eax, (%esp)
        setz    %al
        negl    %eax
        movl    %eax, (%esp)
        $NEXT
END-CODE
