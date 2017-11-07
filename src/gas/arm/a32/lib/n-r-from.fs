CODE NR> ( -- i*x n ... get data from most recent n>r )
        $S_PTOS pp1      
        $RPOP   pp1
        $SET    t1, pp1
1:
        $RPOP   t2
        $PPUSH  t2

        subs    t1, t1, 1
        bne     1b
        $PPND
        $NEXT
END-CODE
COMPILE-ONLY

