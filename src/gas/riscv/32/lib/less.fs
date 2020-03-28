CODE < ( n1 n2 -- flag ...true if n1<n2 )
        $PNOS   pp2             /* n1 */
        $PDIS
        slt     pp1, pp2, pp1
        neg     pp1, pp1
        $NEXT
END-CODE
