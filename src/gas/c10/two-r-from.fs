CODE 2R> ( -- x1 x2 ...pop two items from rstack )
        $S_PTOS pp1
        $RTOS   pp1
        $RNOS   pp2
        $PPND   2
        $S_PNOS pp2
        $RDIS   2
        $NEXT
END-CODE
COMPILE-ONLY

