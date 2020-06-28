\ protoype add/shift UM*
\ pp1: in: u2 out: ud.high [TOS]
\ pp2: in: u1 out: ud.low  [NOS]
\ t1: u1d.high
\ t2: u1d.low
\ t3: tmp
\ t4: u2
\ algorithm:
\ t4 = pp1
\ (t1,t2) = (0,pp2)
\ (pp1,pp2) = (0,0)
\ if (pp2 != 0)
\   while (t4 != 0)
\     if (t4 & 1) {
\       (pp1,pp2) += (t1,t2)
\     }
\     t4 >>= 1
\     (t1,t2) <<= 1
\   end
\ end
\ flush pp2

CODE UM* ( u1 u2 -- ud <udl=pp2,udh=pp1> ...u1*u2 )
        $MOV    t4, pp1         /* t4 = TOS/u2 */
        $PNOS   t2              /* t2 = NOS/u1d.low */
        $SET    pp2, 0          /* clear product low */
        $SET    pp1, 0          /* clear product high */
        beqz    t2, 3f          /* short circuit: output 0 if NOS == 0 */
        $SET    t1, 0           /* clear upper extended u1d.high */
1:
        beqz    t4, 3f          /* done when t4 == 0 */
        andi    t3, t4, 1       /* test LSB of u2 */
        beqz    t3, 2f          /* skip if bit was zero */
        /* (pp2,pp1) += (t1,t2) */
        $ADD    pp2, pp2, t2    /* accumulate low */
        $SLTU   t3, pp2, t2     /* carry if pp2 u< t2 */
        $ADD    pp1, pp1, t1    /* accumulate high */
        $ADD    pp1, pp1, t3    /* add carry */
2:
        /* (t1,t2) <<= 1 */
        slti    t3, t2, 0       /* t3=t2[31] */
        $SHL    t2, t2, 1       /* shift t2 */
        $SHL    t1, t1, 1       /* shift t1 */
        or      t1, t1, t3      /*   +t2[31] */
        srli    t4, t4, 1       /* shift next bit to LSB */
        j 1b                    /* op on next bit */
3:
        /* result is already in [NOS,TOS] */
        $S_PNOS pp2
        $NEXT
END-CODE
