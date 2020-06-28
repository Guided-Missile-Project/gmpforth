CODE (leave) ( -- ...immediately exit the current do-loop )
        $RPICK  ipp, 2
        $RDIS   3
        $NEXT
END-CODE
COMPILE-ONLY

