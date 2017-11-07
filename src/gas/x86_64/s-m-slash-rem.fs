CODE SM/REM
        popq    %rbx
        popq    %rdx
        popq    %rax
        idivq   %rbx
        pushq   %rdx
        pushq   %rax
        $NEXT
END-CODE
