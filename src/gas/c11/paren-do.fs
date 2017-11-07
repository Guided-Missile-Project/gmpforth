CODE (do) ( n1 n2 -- ... get loop start,limit,leave addr and save to rstack )
        $LIT    w       % get branch address compiled after (do)
        $PNOS   p2      % get limit
        $S_RTOS r1      % flush current RTOS
        $RPND   3       % prep rstack
        $S_R3OS w       % branch
        $S_RNOS p2      % limit
        $SET    r1, p1  % start=index
        $PDIS   2       % discard
        $PTOS   p1      % refresh TOS
        $NEXT
END-CODE
COMPILE-ONLY

