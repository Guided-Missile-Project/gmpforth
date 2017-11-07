\ Beiman "Double Precision Math Words" Forth Dimensions Volume 5 Number 1 p.16

\ divide unsigned triple dividend by unsigned divisor yielding unsigned
\ double quotient.

: UT/ ( ut un -- ud )
   dup >r   um/mod swap
   rot 0 r@ um/mod swap
   rot r>   um/mod swap drop
   0 2swap swap d+ ;
