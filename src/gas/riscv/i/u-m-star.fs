\ protoype add/shift UM*
\ pp1: in: u2 out: ud.high [TOS]
\ pp2: in: u1 out: ud.low  [NOS]
\ t1: u1d.high
\ t2: u1d.low
\ t3: u2 bit mask
\ t4: u2
\ t5: tmp
\ algorithm:
\ t4 = pp1
\ (t1,t2) = (0,pp2)
\ (pp1,pp2) = (0,0)
\ t3 = 1
\ do
\   if (t3 & t4) {
\     (pp1,pp2) += (t1,t2)
\   }
\   t3 <<= 1
\   (t1,t2) <<= 1
\ while t3 != 0
\ $PNOS
CODE UM* ( u1 u2 -- ud <udl=pp2,udh=pp1> ...u1*u2 )
        $MOV    t4, pp1         /* t4 = TOS/u2 */
        $PNOS   t2              /* t2 = NOS/u1d.low */
        $SET    pp2, 0          /* clear product low */
        $SET    pp1, 0          /* clear product high */
        beqz    t4, 3f          /* short circuit: output 0 if TOS == 0 */
        beqz    t2, 3f          /* short circuit: output 0 if NOS == 0 */
        $SET    t1, 0           /* clear upper extended u1d.high */
        $SET    t3, 1           /* multiplicand bit test */
1:
        and     t5, t4, t3      /* test bit of u2 */
        beqz    t5, 2f          /* skip if bit was zero */
        /* (pp2,pp1) += (t1,t2) */
        $ADD    pp2, pp2, t2    /* accumulate low */
        $SLTU   t5, pp2, t2     /* carry if pp2 u< t2 */
        $ADD    pp1, pp1, t1    /* accumulate high */
        $ADD    pp1, pp1, t5    /* add carry */
2:
        /* (t1,t2) <<= 1 */
        slti    t5, t2, 0       /* t5=t2[31] */
        $SHL    t2, t2, 1       /* shift t2 */
        $SHL    t1, t1, 1       /* shift t1 */
        or      t1, t1, t5      /*   +t2[31] */
        $SHL    t3, t3, 1       /* shift bit to test */
        bnez    t3, 1b          /* keep going if more bits */
3:
        /* result is already in [NOS,TOS] */
        $S_PNOS pp2
        $NEXT
END-CODE
