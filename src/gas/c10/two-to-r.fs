CODE 2>R ( x1 x2 -- ...push x1 x2 to rstack )
        $PNOS   pp2
        $RPND   2
        $S_RNOS pp2
        $S_RTOS pp1
        $PDIS   2
        $PTOS   pp1
        $NEXT
END-CODE
COMPILE-ONLY

