CODE (s")
        /* get string storage address and length byte */
        movl    %esi, %eax
        movzbl  (%esi), %ebx
        /* point to the first character of the string and push to stack */
        incl    %eax
        pushl   %eax
        /* push the length byte and increment for storage length of string */
        pushl   %ebx
        incl    %ebx
        /* align storage length (%ebx) to word boundary */
        $RALIGN %ebx
        /* point %esi to word following the string */
        addl    %ebx, %esi
        $NEXT
END-CODE
COMPILE-ONLY

