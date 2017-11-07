\ Beiman "Double Precision Math Words" Forth Dimensions Volume 5 Number 1 p.16

\ scale unsigned double ud1 by the ratio of u1/u2
: UM*/ ( ud1 u1 u2 -- ud2 )
   >r ut* r> ut/ ;
