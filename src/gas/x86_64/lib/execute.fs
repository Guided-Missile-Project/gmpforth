CODE EXECUTE
        popq    %rax
        $TRANSFER_CFA
        jmp     *(%rax)
END-CODE
