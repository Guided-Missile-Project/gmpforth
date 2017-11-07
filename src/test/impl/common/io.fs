\ Hayes test for common (io)
\ Copyright (c) 2016 by Daniel Kelley

TESTING common IO

DECIMAL

\ --------------------------------------------------------------------

TESTING anonymous memory map

1000 CELLS CONSTANT A-MMAP-SIZE
-1 A-MMAP-SIZE MMAP
(  ior )  CONSTANT A-MMAP-IOR
( addr )  CONSTANT A-MMAP-ADDR
       10 CONSTANT A-MMAP-V1
      -10 CONSTANT A-MMAP-V2

\ manipulate region at boundries
: A-MMAP-ACCESS ( -- A-MMAP-V1 A-MMAP-V2 )
   A-MMAP-V1 A-MMAP-ADDR DUP >R !
   A-MMAP-V2 A-MMAP-ADDR A-MMAP-SIZE -1 CELLS + + DUP >R !
   2R> @ SWAP @ SWAP ;

T{ A-MMAP-IOR -> 0 }T
T{ A-MMAP-ADDR 0= -> 0 }T
T{ ' A-MMAP-ACCESS CATCH -> A-MMAP-V1 A-MMAP-V2 0 }T
T{ A-MMAP-ADDR A-MMAP-SIZE MUNMAP -> 0 }T

CR .( End of common IO tests) CR


