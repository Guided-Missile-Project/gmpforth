CODE R@ ( -- x ...get top of rstack )
        $RTOS   p1
        $PPUSH  p1
        $NEXT
END-CODE
COMPILE-ONLY

