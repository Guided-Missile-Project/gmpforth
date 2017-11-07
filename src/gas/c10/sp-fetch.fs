CODE SP@ ( -- n ...get pstack index )
        $S_PTOS pp1
        $MOV    pp1, spp
        $PPND
        $NEXT
END-CODE
