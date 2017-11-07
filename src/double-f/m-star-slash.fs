\ multiply d1 by ratio n1/n2 (floored division)

: M*/ ( d1 n1 n2 -- d2 )
   2dup xor >r             \ save xor of signs of ratio
   abs swap abs swap       \ take absolute value of ratio
   2swap dup r> xor >r     \ mix in sign of dividend
   dabs 2swap              \ take absolute value of dividend
   >r ut* r> ut/mod        \ multiply, divide
   drop rot                \ drop the high order result and get modulus
   0<> r@ 0< and           \ if there is a modulus and eventual result negative
   if 1. d+ then           \ "floor" result
   r> d+- ;                \ fix up the sign of the result
