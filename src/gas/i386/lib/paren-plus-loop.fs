CODE (+loop)
        movl    (%ebp), %ebx    /* %ebx: idx */
        popl    %eax            /* %eax: incr */
        movl    %eax, %ecx      /* %ecx: incr */
        addl    %ebx, %eax      /* %eax: idx+incr = idx' */
        movl    %eax, (%ebp)    /* proactively update idx */
        subl    _SZ(%ebp), %ebx /* %ebx: idx-lim */
        subl    _SZ(%ebp), %eax /* %eax: idx'-lim */
        xorl    %edx, %edx
        cmpl    %ebx, %eax      /* idx-lim u< idx'-lim */
        sbbl    %edx, %edx      /* %edx: -1 if u< */
        xorl    %ecx, %edx      /* combine with sign */
        jl      1f
        /* keep going */
        $BLOCK
        movl    (%esi), %esi
        jmp     2f
1:      /* done looping */
        $BLOCK
        addl    $_SZ, %esi
        addl    $_SZ*3, %ebp
2:
        $NEXT
END-CODE
COMPILE-ONLY
