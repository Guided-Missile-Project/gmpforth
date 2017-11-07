CODE (+loop) ( n --- ...incr loop index by n and exit if boundry condition met)
        $RTOS   t1              /* idx */
        $RNOS   t2              /* lim */
        $ADD    t3, t1, pp1     /* idxp = idx + incr */
        $S_RTOS t3              /* proactively update idx */
        $SUB    t1, t2          /* idx -= lim */
        $SUB    t3, t2          /* idxp -= lim */
        sltu    t2, t3, t1      /* t2=1 if t1 u< t3 */
        negu    t2, t2          /* t2=-1 if t1 u< t3 */
        xor     t2, t2, pp1     /* combine with sign of incr */
        bltz    t2, 1f          /* done if t2 < 0 */
        $PDIS                   /* delay slot: discard increment */
        $BRANCH                 /* continue looping */
        $JMP    2f
1:
        $RDIS   3               /* done - discard loop parameters from rstack */
        $SKIP                   /* skip branch address */
2:
        $PTOS   pp1             /* refresh TOS */
        $NEXT
END-CODE
COMPILE-ONLY
