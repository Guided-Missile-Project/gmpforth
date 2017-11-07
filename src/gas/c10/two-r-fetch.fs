CODE 2R@ ( -- x1 x2 ... copy top two items from rstack )
        $S_PTOS pp1      
        $RTOS   pp1
        $RNOS   pp2
        $PPND   2
        $S_PNOS pp2
        $NEXT
END-CODE
COMPILE-ONLY

