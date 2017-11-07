CODE UM* ( u1 u2 -- ud ...u1*u2 )
        $SET    t1, pp1
        $PNOS   t2                  /* u2 */
        umull   pp2, pp1, t2, t1    /* pp1: ud low; in regs != out regs */
        $S_PNOS pp2
        $NEXT
END-CODE
