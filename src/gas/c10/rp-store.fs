CODE RP! ( n -- ...Set the return stack index to n )
        $MOV    rp, pp1
        $PDIS
        $PTOS   pp1
        $NEXT
END-CODE
