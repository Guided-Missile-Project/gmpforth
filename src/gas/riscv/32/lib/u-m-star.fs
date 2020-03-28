CODE UM* ( u1 u2 -- ud ...u1*u2 )
        $PNOS   pp2
        $MULU   pp1, pp2
        mfhi    pp1
        mflo    pp2
        $S_PNOS pp2
        $NEXT
END-CODE
