CODE < ( n1 n2 -- flag ...true if n1<n2 )
        $PNOS   pp2             /* n1 */
        $PDIS
        cmp     pp2, pp1
        mov     pp1, -1         /* n1 <  n2 */
        it      ge
        mvnge   pp1, pp1        /* n1 >= n2 */
        $NEXT
END-CODE
