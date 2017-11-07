CODE RP@ ( -- n ...get current return stack index )
        $S_PTOS pp1      
        $PPND
        $MOV    pp1, rp
        $NEXT
END-CODE
