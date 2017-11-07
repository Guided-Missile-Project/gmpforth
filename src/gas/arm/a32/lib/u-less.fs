CODE U< ( u1 u2 -- flag ...flag true if u1<u2 )
        $PNOS   pp2
        $PDIS
        $SET    t1, 0
        cmp     pp2, pp1        /* carry set if pp2 u< pp1 */
        sbc     pp1, t1, t1     /* pp1 = 0 - carry */
        $NEXT
END-CODE
