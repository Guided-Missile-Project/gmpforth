\ Beiman "Double Precision Math Words" Forth Dimensions Volume 5 Number 1 p.16

\ multiply unsigned double by unsigned single
\ yielding an unsigned triple product

: UT* ( ud un -- ut )
   dup rot um* 2>r um* 0 2r> d+ ;
