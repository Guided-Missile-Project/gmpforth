\
\ Tiny Mersenne Twister 32
\
\ For native 32 bit GMP Forth
\
\ http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/TINYMT/index.html
\
\ See $GMPFORTH/tinymt/tmt32.c for C reference implementation

hex
7fffffff constant TMT32-MASK
decimal

: TMT32-PERIOD-CERTIFICATION ( addr -- )
  >r
  r@           @ tmt32-mask and 0=
  r@ 1 cells + @ 0=
  r@ 2 cells + @ 0=
  r@ 3 cells + @ 0= and and and if
    [char] T r@           !
    [char] I r@ 1 cells + !
    [char] N r@ 2 cells + !
    [char] Y r@ 3 cells + !
  then r> drop ;

: TMT32-TEMPER ( addr -- u )
   >r
   r@ 3 cells + @
   r@           @
   r@ 2 cells + @ 8 rshift + ( -- t0 t1 )
   dup rot xor swap ( -- t0^t1 t1 )
   1 and negate r> 6 cells + @ and xor ;

: TMT32-NEXT-STATE ( addr -- )
  >r
  r@           @ tmt32-mask and
  r@ 1 cells + @
  r@ 2 cells + @ xor xor
  dup 2* xor ( -- x )
  r@ 3 cells + @ dup 1 rshift xor ( -- x y )
  over xor ( -- x y )
  r@ 1 cells + r@ 2 cells move \ status[0] = status[1];status[1] = status[2]

  swap over ( -- y x y )
         10 lshift xor r@ 2 cells + ! \ update status[2]
         ( -- y )
  dup r@ 3 cells + !                  \ update status[3]
  1 and negate dup ( -- y' y' )
  r@ 4 cells + @ and r@ 1 cells + dup >r @ xor r> !
  r@ 5 cells + @ and r> 2 cells + dup >r @ xor r> ! ;

: TMT32-INIT-STATE ( addr idx -- )
   swap >r
   dup 1- 3 and ( -- idx idx-1&3 )
   cells r@ + @ dup 30 rshift xor ( -- idx q )
   1812433253 * ( -- idx q*1812433253 ) over + ( -- idx q*1812433253+idx)
   swap 3 and cells r> + dup @ rot xor swap ! ;

: TMT32-INIT-SEED ( seed addr -- )
   >r r@ !
   r@ 4 cells + r> cell+ 3 cells move ;

: TMT32-INIT ( seed addr -- )
  dup >r tmt32-init-seed r>
  8 1 do dup I tmt32-init-state loop
  dup tmt32-period-certification
  8 0 do dup tmt32-next-state loop drop ;

: TMT32-GENERATE ( addr -- u )
   dup tmt32-next-state tmt32-temper ;

( create: tmat mat2 mat1 --   run: -- addr )

: TMT32
  create
    1 ,       ( -- tmat mat2 mat1        r: -- here )
    dup >r ,  ( -- tmat mat2             r: -- here mat1 )
    dup >r ,  ( -- tmat                  r: -- here mat1 mat2 )
    dup    ,  ( -- tmat                  r: -- here mat1 mat2 )
    r> r>     ( -- tmat mat2 mat1        r: -- here )
    , , ,     ( --                       r: -- here )
    ;

: .TMT32 ( addr -- )
   7 0 do dup i cells + @ u. loop drop ;
