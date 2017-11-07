CODE (loop) ( -- ...incr loop index and exit if index equals limit )
                                % index in r1
        $RNOS   r2              % limit
        addu    r1, r1, 1       % incr index
        cmp     t1, r1, r2
        bz      t1, 1f          % exit if index=limit
        $BRANCH
        jmp     2f
1:
        $RDIS   3               % discard loop parameters from rstack
        $RTOS   r1
        $SKIP
2:
        $NEXT
END-CODE
COMPILE-ONLY

