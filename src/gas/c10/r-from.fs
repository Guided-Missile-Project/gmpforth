CODE R> ( -- x ...pop x from rstack )
        $S_PTOS pp1      
        $PPND
        $RPOP   pp1
        $NEXT
END-CODE
COMPILE-ONLY

