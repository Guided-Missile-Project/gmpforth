CODE N>R ( i*x n -- ...push n and n cells on pstack to rstack )
        $PDIS
        $SET    t1, pp1
1:
        $PPOP   t2
        $RPUSH  t2
        subs    t1, t1, 1
        bne     1b
        $RPUSH  pp1
        $PTOS   pp1             /* refresh pp1 */
        $NEXT
END-CODE
COMPILE-ONLY
