CODE <
        xorl    %eax, %eax
        popl    %ebx
        cmpl    %ebx, (%esp)
        setl    %al
        negl    %eax
        movl    %eax, (%esp)
        $NEXT
END-CODE
