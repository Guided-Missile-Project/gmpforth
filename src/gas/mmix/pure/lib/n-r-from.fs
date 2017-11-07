CODE NR> ( -- i*x n ... get data from most recent n>r )
        $RPOP   p1
        set     t1, p1
1:
        $RPOP   r1
        $PPUSH  r1
	sub     t1, t1, 1
        bnz     t1, 1b
        $PPUSH  p1
        $NEXT
END-CODE
COMPILE-ONLY

