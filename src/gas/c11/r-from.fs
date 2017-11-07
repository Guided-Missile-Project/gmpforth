CODE R> ( -- x ...pop x from rstack )
        $S_PTOS p1      
        $PPND
        $SET    p1, r1
        $RDIS
        $RTOS   r1
        $NEXT
END-CODE
COMPILE-ONLY

