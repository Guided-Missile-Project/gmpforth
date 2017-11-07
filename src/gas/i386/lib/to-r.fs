CODE >R
        popl    %eax
        subl    $_SZ, %ebp
        movl    %eax, (%ebp)
        $NEXT
END-CODE
COMPILE-ONLY

