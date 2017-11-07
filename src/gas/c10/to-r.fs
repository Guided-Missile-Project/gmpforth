CODE >R ( x -- ...push x to rstack )
        $RPUSH  pp1
        $PDIS
        $PTOS   pp1
        $NEXT
END-CODE
COMPILE-ONLY

