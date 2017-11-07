CODE (do)
        lodsl           /* %eax: branch addr */
        popl    %ebx    /* start */
        popl    %ecx    /* limit */
        subl    $_SZ*3, %ebp
        movl    %ebx, (%ebp)
        movl    %ecx, _SZ(%ebp)
        movl    %eax, _SZ*2(%ebp)
        $NEXT
END-CODE
COMPILE-ONLY

