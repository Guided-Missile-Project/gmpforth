CODE 2R@ ( -- x1 x2 ... copy top two items from rstack )
        $RTOS   p1
        $RNOS   p2
        $PPND   2
        $S_PNOS p2
        $S_PTOS p1
        $NEXT
END-CODE
COMPILE-ONLY

