CODE 2>R ( x1 x2 -- ...push x1 x2 to rstack )
        $S_RTOS r1
        $PNOS   r2
        $RPND   2
        $S_RNOS r2
        $SET    r1, p1
        $PDIS   2
        $PTOS   p1
        $NEXT
END-CODE
COMPILE-ONLY

