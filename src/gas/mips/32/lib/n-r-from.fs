CODE NR> ( -- i*x n ... get data from most recent n>r )
        $S_PTOS pp1      
        $RPOP   pp1
        $MOV    t1, pp1
1:
        $RPOP   t2
        $PPUSH  t2

        $SUB    t1, t1, 1
        bnez    t1, 1b
        nop
        $PPND
        $NEXT
END-CODE
COMPILE-ONLY

