CODE >R ( x -- ...push x to rstack )
        $S_RTOS r1
        $RPND
        $SET    r1, p1
        $PDIS
        $PTOS   p1
        $NEXT
END-CODE
COMPILE-ONLY

