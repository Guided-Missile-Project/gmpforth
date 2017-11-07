CODE ROLL
        popl    %ecx
        cmpl    $0, %ecx
        $TRANSFER
        jns     2f
        /* non-standard inverse roll */
        $BLOCK
        negl    %ecx
        movl    (%esp), %ebx
        movl    $1, %eax
1:      $BLOCK
        movl    (%esp,%eax,_SZ), %edx
        dec     %eax
        movl    %edx, (%esp,%eax,_SZ)
        inc     %eax
        inc     %eax
        loopnz  1b
        dec     %eax
        movl    %ebx, (%esp,%eax,_SZ)
        $NEXT
2:      $TRANSFER
        jz      4f
        /* standard roll */
        $BLOCK
        movl    %ecx, %eax
        movl    (%esp,%ecx,_SZ), %ebx
3:
        dec     %eax
        movl    (%esp,%eax,_SZ), %edx
        movl    %edx, (%esp,%ecx,_SZ)
        loopnz  3b
        movl    %ebx, (%esp)
4:      $BLOCK
        $NEXT
END-CODE
