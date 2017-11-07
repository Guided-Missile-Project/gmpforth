CODE 2>R ( x1 x2 -- ...push x1 x2 to rstack )
        $PTOS   p1
        $PNOS   p2
        $RPND   2
        $S_RNOS p2
        $S_RTOS p1
        $PDIS   2
        $NEXT
END-CODE
COMPILE-ONLY

