CODE 2R@ ( -- x1 x2 ... copy top two items from rstack )
        $S_PTOS p1      
        $SET    p1, r1
        $RNOS   p2
        $PPND   2
        $S_PNOS p2
        $NEXT
END-CODE
COMPILE-ONLY

