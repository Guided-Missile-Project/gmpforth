CODE +
        popl    %eax
        add     (%esp), %eax
        movl    %eax, (%esp)
        $NEXT
END-CODE
