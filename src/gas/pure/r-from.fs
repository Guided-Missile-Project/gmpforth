CODE R> ( -- x ...pop x from rstack )
        $RPOP   p1
        $PPUSH  p1
        $NEXT
END-CODE
COMPILE-ONLY

