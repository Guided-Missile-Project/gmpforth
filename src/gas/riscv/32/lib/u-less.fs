CODE U< ( u1 u2 -- flag ...flag true if u1<u2 )
        $PNOS   pp2
        $PDIS
        sltu    pp1, pp2, pp1
        neg     pp1, pp1
        $NEXT
END-CODE
