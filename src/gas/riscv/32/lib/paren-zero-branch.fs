CODE (0branch) ( x -- )
        $LIT    t1              /* branch address */
        bnez    pp1, 1f
        nop
        $MOV    ipp, t1         /* branch if 'pp1' zero */
1:
        $PDIS
        $PTOS   pp1             /* refresh TOS */
        $NEXT
END-CODE
COMPILE-ONLY
