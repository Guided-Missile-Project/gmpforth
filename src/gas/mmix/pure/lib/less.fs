CODE < ( n1 n2 -- flag ...true if n1<n2 )
        $PTOS   p1              % n2
        $PNOS   p2              % n1
        $PDIS
        cmp     p1, p2, p1      % -1:n1<n1 0:n1=n2 +1:n1>n2
        sr      p1, p1, SIGNEXT_SR % extend sign of p1 into all of p1
        $S_PTOS p1
        $NEXT
END-CODE
