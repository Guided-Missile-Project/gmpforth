CODE U<
        xor     %eax, %eax
        popl    %ebx
        cmpl    %ebx, (%esp)
        sbbl    %eax, %eax
        movl    %eax, (%esp)
        $NEXT
END-CODE
