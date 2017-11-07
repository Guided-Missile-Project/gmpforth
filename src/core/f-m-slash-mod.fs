\ floored division
\  d   n               q  r
\  13.  4 fm/mod . .   3  1
\  13. -4 fm/mod . .  -4 -3
\ -13.  4 fm/mod . .  -4  3
\ -13. -4 fm/mod . .   3 -1
\ floored:
\   First, perform signed truncated (symmetric) division
\   If there is a remainder and the signs of the remainder and divisor differ
\     then decrement the quotient and add the divisor to the remainder

: fm/mod ( d n -- r q )
  dup >r sm/rem over if ( non zero remainder )
    over r@ xor 0< if ( remainder and divisor sign differs )
      1- swap r@ + swap
    then
  then r> drop ( divisor ) ;

