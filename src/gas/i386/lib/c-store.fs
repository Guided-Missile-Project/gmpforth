CODE C!
        popl    %ebx
        popl    %eax
        movb    %al, (%ebx)
        $NEXT
END-CODE
