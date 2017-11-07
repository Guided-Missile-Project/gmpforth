CODE UM* ( u1 u2 -- ud ...u1*u2 )
        $PNOS   pp2     /* pp1=u1 pp2=u2; out: pp1=high, pp2=low*/
        mul     t1, pp1, pp2    /* low part */
        umulh   pp1, pp1, pp2   /* high part */
        $S_PNOS t1
        $NEXT
END-CODE
