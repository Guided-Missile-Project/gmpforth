CODE C!
        popq    %rbx
        popq    %rax
        movb    %al, (%rbx)
        $NEXT
END-CODE
