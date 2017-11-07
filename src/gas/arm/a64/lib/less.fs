CODE < ( n1 n2 -- flag ...true if n1<n2 )
        $PNOS   pp2             /* n1 */
        $PDIS
        cmp     pp2, pp1
        mov     pp1, -1         /* n1 <  n2 */
        blt     1f
        mvn     pp1, pp1        /* n1 >= n2 */
1:
        $NEXT
END-CODE
