CODE R@ ( -- x ...get top of rstack )
        $S_PTOS p1      
        $PPND
        $SET    p1, r1
        $NEXT
END-CODE
COMPILE-ONLY

