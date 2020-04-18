CODE (0branch) ( x -- )
        $LIT    pp2             /* branch address */
        $BNEZ   pp1, 1f
        $MOV    ipp, pp2        /* branch if 'pp1' zero */
1:
        $PDIS
        $PTOS   pp1             /* refresh TOS */
        $NEXT
END-CODE
COMPILE-ONLY
