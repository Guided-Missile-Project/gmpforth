CODE 0<
        xorl    %eax, %eax
        cmpl    %eax, (%esp)
        setl    %al
        negl    %eax
        movl    %eax, (%esp)
        $NEXT
END-CODE
