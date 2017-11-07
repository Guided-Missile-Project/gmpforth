CODE (loop) ( -- ...incr loop index and exit if index equals limit )
        $RTOS   r1              % index
        $RNOS   r2              % limit
        addu    r1, r1, 1       % incr index
        cmp     t1, r1, r2
        bz      t1, 1f          % exit if index=limit
        $S_RTOS r1              % save new index
        $BRANCH
        jmp     2f
1:
        $RDIS   3               % discard loop parameters from rstack
        $SKIP
2:
        $NEXT
END-CODE
COMPILE-ONLY

