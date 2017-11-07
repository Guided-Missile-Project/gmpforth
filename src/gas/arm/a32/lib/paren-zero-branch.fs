CODE (0branch) ( x -- )
        $LIT    t1              /* branch address */
        cmp     pp1, 0
        it      eq
        moveq   ipp, t1         /* branch if 'pp1' zero */
        $PDIS
        $PTOS   pp1             /* refresh TOS */
        $NEXT
END-CODE
COMPILE-ONLY
