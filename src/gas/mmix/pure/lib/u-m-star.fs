CODE UM* ( u1 u2 -- ud ...u1*u2 )
        $PTOS   p1              % u1
        $PNOS   p2              % u2
        mulu    p2, p1, p2      % p1: ud low
        get     p1, rH          % p2: ud high
        $S_PNOS p2
        $S_PTOS p1
        $NEXT
END-CODE
