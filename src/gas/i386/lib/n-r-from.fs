CODE NR>
        movl    (%ebp), %ebx
        movl    %ebx, %ecx
        addl    $_SZ, %ebp
1:      pushl   (%ebp)
        addl    $_SZ, %ebp
        decl    %ecx
        jne     1b
        pushl   %ebx
        $NEXT
END-CODE
COMPILE-ONLY

