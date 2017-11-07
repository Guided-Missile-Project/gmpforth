CODE (loop)
        /* get index and increment */
        movl    (%ebp), %eax
        incl    %eax
        /* test index against limit */
        cmpl    _SZ(%ebp), %eax
        $TRANSFER
        je      1f
        /* keep going - move new index to return stack */
        $BLOCK
        movl    %eax, (%ebp)
        movl    (%esi), %esi
        $NEXT
1:      /* done looping */
        $BLOCK
        addl    $_SZ, %esi
        addl    $_SZ*3, %ebp
        $NEXT
END-CODE
COMPILE-ONLY

