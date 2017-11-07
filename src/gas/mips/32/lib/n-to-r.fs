CODE N>R ( i*x n -- ...push n and n cells on pstack to rstack )
        $PDIS
        $MOV    t1, pp1
1:
        $PPOP   t2
        $RPUSH  t2
        $SUB    t1, t1, 1
        bnez    t1, 1b
        nop
        $RPUSH  pp1
        $PTOS   pp1             /* refresh pp1 */
        $NEXT
END-CODE
COMPILE-ONLY
