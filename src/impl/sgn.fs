\ signum function
: SGN ( n -- -1|0|+1 )
   dup 0< if drop -1 else dup 0<> if drop 1 then then ;

