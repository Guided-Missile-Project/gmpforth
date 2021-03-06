\
\ Divide unsigned double ud by u1 leaving quotient u2 and remainder u3
\
\ This prototypes the non-restoring division algorithm described in
\ Hennessey and Patterson Computer Architecture Appendix I
\
\ The divider uses four abstact registers:
\
\   Register Length Function  Implementation
\                             64     63..32 31..0
\   -------- ------ --------  -------------------
\   P        65     remainder carry, pp3    t1
\   A        64     quotient         pp2    pp1
\   B        64     divisor          --     t2
\   X        64     temp             t4     t3
\   C        32     counter          --     w
\
\ Instead of restoring P, this does a trial subtract to X
\ and conditional move to P to eliminate branches in the
\ divide loop.
\
\ see $GMPFORTH/lib/binary-long-division.rb div_h_p_r

CODE UM/MOD ( ud u1 -- u2 u3 ...ud/u1 -> rem:u2 quo:u3 )
        $SET    t2, pp1        /* set B=u1 */
        $PDIS
        $PTOS   pp2            /* set A=ud */
        $PNOS   pp1
        $SET    t1, 0          /* clear P */
        $SET    pp3, 0
        $SET    w, BITS_PER_WORD*2     /* w is loop counter */
1:
        /* division loop */
        /* (i) shift A left with carry out */
        adds    pp1, pp1, pp1
        adcs    pp2, pp2, pp2
        /* shift P left with carry in from A */
        adcs    t1, t1, t1
        adc     pp3, pp3, pp3

        /* (ii) X=P-B */
        subs    t3, t1, t2
        sbcs    t4, pp3, 0

        /* (iii) X>=0: A |= 1 */
        ittt    pl
        orrpl   pp1, pp1, 1

        /* (iv)  X>=0: P=X */
        movpl   t1, t3
        movpl   pp3, t4

        /* handle loop counter */
        subs    w, w, 1
        bne     1b
        $S_PNOS t1
        $NEXT
END-CODE
