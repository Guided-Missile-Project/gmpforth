CODE NR> ( -- i*x n ... get data from most recent n>r )
        $S_PTOS p1
        set     t1, r1
        $RDIS
1:
        $RPOP   p1
        $PPUSH  p1
	sub     t1, t1, 1
        bnz     t1, 1b
        $PPND
        set     p1, r1
        $RTOS   r1
        $NEXT
END-CODE
COMPILE-ONLY

