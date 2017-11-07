: RESTORE-INPUT ( buf buf-end inp inp-end s-id #line in- blk in 9 -- tf )
   dup (#i) = if
     drop
     (src0) >in do I ! (cell) negate +loop
     false ( ok)
   else 
     true ( error )
   then ;
