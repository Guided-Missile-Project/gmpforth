CODE R@ ( -- x ...get top of rstack )
        $S_PTOS pp1      
        $PPND
        $RTOS   pp1
        $NEXT
END-CODE
COMPILE-ONLY

