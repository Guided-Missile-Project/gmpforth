: D2/ ( d1 -- d2 )
   \ needs to preserve all the bits when shifting a negative number
   \ which is why "1 2 M*/" doesn't work in all cases
   dup 1 and 1 cells 8 * 1- lshift >r \ save lsb of high word
   2/ swap u2/ r> or swap ; \ shift high and low, or in lsb of high
