CODE SP@ ( -- n ...get pstack index )
        $SET   p1, sp
        $PPUSH p1
        $NEXT
END-CODE
