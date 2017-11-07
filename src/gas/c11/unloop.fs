CODE UNLOOP ( -- ...discard loop params )
        $RDIS   3
        $RTOS   r1
        $NEXT
END-CODE
COMPILE-ONLY

