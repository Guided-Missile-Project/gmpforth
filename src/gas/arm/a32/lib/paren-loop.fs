CODE (loop) ( -- ...incr loop index and exit if index equals limit )
        $RTOS   t1              /* index */
        $RNOS   t2              /* limit */
        add     t1, t1, 1       /* incr index */
        cmp     t1, t2
        beq     1f              /* exit if index=limit */
        $S_RTOS t1              /* save new index */
        $BRANCH
        $JMP    2f
1:
        $RDIS   3               /* discard loop parameters from rstack */
        $SKIP
2:
        $NEXT
END-CODE
COMPILE-ONLY

