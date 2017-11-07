CODE (do) ( n1 n2 -- ... get loop start,limit,leave addr and save to rstack )
        $LIT    w       % get branch address compiled after (do)
        $PTOS   p1      % get start
        $PNOS   p2      % get limit
        $RPUSH  w       % branch
        $RPUSH  p2      % limit
        $RPUSH  p1      % start=index
        $PDIS   2       % discard
        $NEXT
END-CODE
COMPILE-ONLY

