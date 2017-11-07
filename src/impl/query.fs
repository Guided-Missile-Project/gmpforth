\ accept a line of input into the current source buffer, updating (src@), >in, >in-
: query ( -- )
   (src) @ (srcend) @ over - accept (src) @ + (src@) ! 0 >in !  0 >in- ! ;
