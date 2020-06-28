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
\                   carry            t6     t5
\
\ Instead of restoring P, this does a trial subtract to X
\ and conditional move to P to minimize branches in the
\ divide loop.
\
\ see $GMPFORTH/lib/binary-long-division.rb div_h_p_r

CODE UM/MOD ( ud u1 -- u2 u3 ...ud/u1 -> rem:u2 quo:u3 )
        $MOV    t2, pp1        /* set B=u1 */
        $PDIS
        $PTOS   pp2            /* set A=ud */
        $PNOS   pp1
        $SET    t1, 0          /* clear P */
        $SET    pp3, 0
        $SET    w, BITS_PER_WORD*2    /* w is loop counter */
1:
        /* division loop */
        /* (i) shift A left with carry out */
        $SHR    t5, pp1, BITS_PER_WORD-1  /* t5 is carry-out from A low */
        $ADD    pp1, pp1, pp1

        $SHR    t6, pp2, BITS_PER_WORD-1  /* t6 is carry-out from A high */
        $ADD    pp2, pp2, pp2
        $ADD    pp2, pp2, t5    /* A-low carry-in */
        /* shift P left with carry in from A */
        $SHR    t5, t1, BITS_PER_WORD-1   /* t5 is carry-out from P low */
        $ADD    t1, t1, t1
        $ADD    t1, t1, t6      /* A-high carry-in */
        $ADD    pp3, pp3, pp3
        $ADD    pp3, pp3, t5      /* P-low carry-in */

        /* (ii) X=P-B */
        $SUB    t3, t1, t2
        sltu    t5, t1, t2      /* from d-minus;if that's broken this is too */
        $SUB    t4, pp3, t5

        /* (iii) X>=0: A |= 1 */
        bltz    t4, 2f
        $OR     pp1, pp1, 1

        /* (iv)  X>=0: P=X */
        $MOV    t1, t3
        $MOV    pp3, t4
2:
        /* handle loop counter */
        $ADDI   w, w, -1
        $BNEZ   w, 1b
        $S_PNOS t1
        $NEXT
END-CODE
