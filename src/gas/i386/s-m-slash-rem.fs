CODE SM/REM
        popl    %ebx
        popl    %edx
        popl    %eax
        idivl   %ebx
        pushl   %edx
        pushl   %eax
        $NEXT
END-CODE
