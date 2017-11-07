: keyloop ( -- )
   ['] (urx@) (rx@) !
   ['] (utx!) (tx!) !
   begin key dup 4 <> while emit repeat drop cr ;
