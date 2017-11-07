CODE >R ( x -- ...push x to rstack )
        $PPOP   r1
        $RPUSH  r1
        $NEXT
END-CODE
COMPILE-ONLY

