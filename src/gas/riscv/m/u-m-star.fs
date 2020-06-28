CODE UM* ( u1 u2 -- ud ...u1*u2 )
        $PNOS   t2              /* place operands in temp registers (NOS) */
        $MOV    t1, pp1         /*                                  (TOS) */
        $MULHU  pp1, t1, t2     /* source registers for mul* have to be the same */
        $MUL    pp2, t1, t2     /* and cannot be the same as mulhu dst */
        $S_PNOS pp2
        $NEXT
END-CODE
