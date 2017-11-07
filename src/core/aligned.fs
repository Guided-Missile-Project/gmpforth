: ALIGNED ( u -- u' )
   dup (cell) 1- and ?dup if ( unaligned ) - (cell) + then ;

