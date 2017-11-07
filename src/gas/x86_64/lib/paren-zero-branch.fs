CODE (0branch)
        popq    %rbx
        lodsq
        cmpq    $0, %rbx
        jne     1f
        movq    %rax, %rsi
1:
        $NEXT
END-CODE
COMPILE-ONLY

