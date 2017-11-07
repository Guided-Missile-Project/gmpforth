CODE (+loop) ( n --- ...incr loop index by n and exit if boundry condition met)
        $RTOS   t1              /* t1: idx */
        $RNOS   t2              /* t2: lim */
        $ADD    t3, t1, pp1     /* t3: idxp = idx + incr */
        $S_RTOS t3              /* proactively save new index */
        $SUB    t1, t2          /* t1: idx-lim */
        $SUB    t3, t2          /* t3: idxp-lim */
        $SET    t2, 0
        cmp     t3, t1
        sbc     t2, t2, t2      /* t2: -1 if t1 u< t3 */
        .ifdef _A64
        eor     t2, t2, pp1     /* no EORS in AARCH64 */
        cmp     t2, 0
        .else
        eors    t2, t2, pp1
        .endif
        bmi     1f
        $BRANCH                 /* continue looping */
        $JMP    2f
1:
        $RDIS   3               /* done - discard loop parameters from rstack */
        $SKIP                   /* skip branch address */
2:
        $PDIS                   /* discard incr */
        $PTOS   pp1             /* refresh TOS */
        $NEXT
END-CODE
COMPILE-ONLY
