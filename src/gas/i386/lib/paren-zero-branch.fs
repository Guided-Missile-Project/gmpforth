CODE (0branch)
        popl    %ebx
        lodsl
        cmpl    $0, %ebx
        $TRANSFER
        jne     1f
        $BLOCK
        movl    %eax, %esi
1:      $BLOCK
        $NEXT
END-CODE
COMPILE-ONLY

