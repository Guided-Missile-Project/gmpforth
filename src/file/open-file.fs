: open-file ( c-addr u fam -- fd ior )
   >r c-str r> IO_OPEN_FILE (io) dup (ior) ;
