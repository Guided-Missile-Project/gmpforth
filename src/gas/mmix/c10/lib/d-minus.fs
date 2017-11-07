CODE D- ( d1 d2 -- d3 ... double subtract d1-d2 )
        $SET    t1, p1          % d2 upper
        $PNOS   p2              % d2 lower
        $PDIS   2
        $PNOS   p1              % d1 lower
        subu    p2, p1, p2      % d3l = d1l - d2l
        cmpu    t2, p2, p1      % check for borrow (d3l u< d1l)
        zsp     t2, t2, 1       % borrow > 0 ? 1 : 0
        $PTOS   p1              % d1 upper
        subu    p1, p1, t1      % d3u' = d1u - d2u
        subu    p1, p1, t2      % d3u = d3u' - borrow
        $S_PNOS p2
        $NEXT
END-CODE
