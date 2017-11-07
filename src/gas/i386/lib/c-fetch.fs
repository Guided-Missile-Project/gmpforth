CODE C@
        popl    %ebx
        movzbl  (%ebx), %eax
        pushl   %eax
        $NEXT
END-CODE
