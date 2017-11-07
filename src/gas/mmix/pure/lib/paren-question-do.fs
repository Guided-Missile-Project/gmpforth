CODE (?do) ( n1 n2 -- ... get loop start,limit,leave addr and save to rstack )
        $LIT    t1              % get branch address compiled after (do)
        $PTOS   p1              % get start
        $PNOS   p2              % get limit
        cmp     t2, p1, p2
        bz      t2, 1f          % do not loop if index equals limit
        $RPUSH  t1              % branch
        $RPUSH  p2              % limit
        $RPUSH  p1              % start=index
        jmp     2f
1:
        set     ip, t1          % done looping
2:
        $PDIS   2               % discard n1 n2
        $NEXT
END-CODE
COMPILE-ONLY
