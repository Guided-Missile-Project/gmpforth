CODE RP! ( n -- ...Set the return stack index to n )
        $SET    rp, p1
        $PDIS
        $PTOS   p1
        $RTOS   r1
        $NEXT
END-CODE
