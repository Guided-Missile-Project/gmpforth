CODE (?do)
        lodsl           /* %eax: branch addr */
        popl    %ebx    /* start */
        popl    %ecx    /* limit */
        cmpl    %ebx, %ecx
        $TRANSFER
        je      1f
        $BLOCK
        subl    $_SZ*3, %ebp
        movl    %ebx, (%ebp)
        movl    %ecx, _SZ(%ebp)
        movl    %eax, _SZ*2(%ebp)
        $TRANSFER
        jmp     2f
1:      $BLOCK
        movl    %eax, %esi
2:      $BLOCK
        $NEXT
END-CODE
COMPILE-ONLY

