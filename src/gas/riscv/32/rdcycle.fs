CODE RDCYCLE ( -- cyclel cycleh )
     $S_PTOS    pp1
     $PPND      2
1:
     $RDCYCLEH  t0
     $RDCYCLE   pp2
     $RDCYCLEH  pp1
     $BNE       t0, pp1, 1b
     $S_PNOS    pp2
     $NEXT
END-CODE
