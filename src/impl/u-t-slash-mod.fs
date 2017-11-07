\ divide unsigned triple dividend by unsigned divisor yielding unsigned
\ triple quotient and single remainder.
\
\ See
\   Knuth
\   The Art Of Computer Programming 2nd ed. vol. 2 p. 582
\   sect. 4.3.1 answer to exercise 16 
\
\ Notation follows Knuth, where u1 is the most significant word of the
\ dividend, v is the single word divisor, w is the quotient and r the
\ remainder.
\
\ Division is in three stages going from most significant word to least,
\ which is the opposite order from how division by hand is usually done.
\ The dividend of each sub-division is r*b+u, where b is the "base", which,
\ in this case is 2^(wordbits) or 2^32 for a 32 bit system - this has nothing
\ to do with the Forth notion of base. The remainder (r) being placed in the
\ high word serves as the multiply by base. Each sub-dividend is divided by
\ the divisor (v), yielding a quotient digit (w), and a remainder (r), which
\ then feeds into the next sub-division.
\
\ r1 u1        w1       r3=0  u(n+1)=un/v r(n+1)=un%
\    r2 u2     w2
\       r3 u3  w3
\          r4
\ As an example in base 10, 175 div 4 = quotient 43 remainder 3
\
\  0  1         0     1 div 4 = quotient 0 remainder 1
\     1  7      4    17 div 4 = quotient 4 remainder 1
\        1  5   3    15 div 4 = quotient 3 remainder 3
\           3
\
: UT/MOD ( u3 u2 u1 v -- r w3 w2 w1 )
   >r        \ -- u3 u2 u1       r: -- v
   0 r@      \ -- u3 u2 u1  0 v  r: -- v
   um/mod    \ -- u3 u2  r w1    r: -- v
   -rot r@   \ -- u3 w1 u2  r v  r: -- v
   um/mod    \ -- u3 w1  r w2    r: -- v
   rot       \ -- u3 r  w2 w1    r: -- v  
   2swap     \ -- w2 w1 u3 r     r: -- v
   r>        \ -- w2 w1 u3 r  v  r: --
   um/mod    \ -- w2 w1  r w3
   2swap ;   \ --  r w3 w2 w1
