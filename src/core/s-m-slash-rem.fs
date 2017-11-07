\ symmetric division
\  d    n              q  r  x=hi(d)^n
\  13.  4 sm/rem . .   3  1  4 
\  13. -4 sm/rem . .  -3  1 -4  
\ -13.  4 sm/rem . .  -3 -1 -5
\ -13. -4 sm/rem . .   3 -1  3
\ symmetric:
\   sign(q) = sign(x)
\   sign(r) = sign(d)

: sm/rem ( d n -- r q )
   over >r 2dup xor >r ( save d, d^n )
   >r dabs r> abs um/mod  ( do division on positive arguments )
        r> +- ( signs of divisor and dividend differ, quotient is negative )
   swap r> +- ( divisor is negative, so is the remainder )
   swap ;

