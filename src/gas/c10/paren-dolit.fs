CODE (dolit) ( -- x ... push contents of cell following to pstack )
        $S_PTOS pp1      
        $PPND
        $LIT    pp1
        $NEXT
END-CODE
COMPILE-ONLY

