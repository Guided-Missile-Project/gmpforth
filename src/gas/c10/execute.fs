CODE EXECUTE ( i*x xt -- j*x )
        $MOV    w, pp1
        $PDIS
        $PTOS   pp1
        $EXECUTE
END-CODE
