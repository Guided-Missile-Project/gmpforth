CODE (leave) ( -- ...immediately exit the current do-loop )
        $RPICK  ip, 2
        $RDIS   3
        $RTOS   r1
        $NEXT
END-CODE
COMPILE-ONLY

