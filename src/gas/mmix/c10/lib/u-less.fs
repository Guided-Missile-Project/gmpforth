CODE U< ( u1 u2 -- flag ...flag true if u1<u2 )
        $PNOS   p2              % u1
        $PDIS
        cmpu    p1, p2, p1      % u1<u2
        csnn    p1, p1, 0       % p1=0 if p1 != -1
        $NEXT
END-CODE
