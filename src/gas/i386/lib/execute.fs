CODE EXECUTE
        popl    %eax
        $TRANSFER_CFA
        jmp     *(%eax)
END-CODE
