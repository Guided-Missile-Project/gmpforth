decimal
: (s\") ( a1 n1 -- a2 n2) \ modify a1 n2 translating backslash escapes in place
  2dup 2>r ( save a1 n1 )
  0 0 2swap ( -- offset state a1 n2 )
  bounds ?do
    ( -- offset state )
    ( cr ." [" I c@ emit ." ] " .s debug)
    case
    0 of \ regular character copy
        I c@ [char] \ = if
          I 1+ c@ case
          
            \ \m is special because the two character input sequence
            \ results in two output characters, exactly replacing the
            \ escape sequence
            [char] m of dup I + 13 swap c! ( state) 2 endof \ \m sequence
            
            \ \x is special because a three character input sequence
            \ becomes one output character. The output character is
            \ built in place, first with the high nibble and then
            \ the stored high nibble is combined with the low nibble
            [char] x of 1- ( state) 3 endof \ \x## sequence
            
            \ all other escapes are two input characters to one output
            \ character
            drop ( special char) ( state) 1
            
          endcase
        else \ copy input to output
          dup I + I c@ swap c! 0
        then
      endof
    1 of \ single char backslash escape
        1- ( skip  input char)
        I c@ case
          [char] a of  7 endof
          [char] b of  8 endof
          [char] e of 27 endof
          [char] f of 12 endof
          [char] l of 10 endof
          [char] n of 10 endof
          [char] q of 34 endof
          [char] r of 13 endof
          [char] t of  9 endof
          [char] v of 11 endof
          [char] z of  0 endof
\          [char] " of 34 endof
\          [char] \ of 92 endof
          ( default - just copy escaped char out)
        endcase
        ( -- offset char )
        over I + ( cr ." %1 " .s debug) c! ( state) 0
      endof
    2 of \ second output char of \m sequence
        dup I + 10 swap ( cr ." %2 " .s debug) c! ( state) 0
      endof
    3 of \ 'x' of \x sequence - skip 'x'; next state 4
        1- ( state) 4 
      endof
    4 of \ first input char of \x sequence
        dup I + ( output addr)
        I c@ 16 digit 0= if 0 then 16 * ( convert digit )
        swap  ( cr ." %4 " .s debug) c! ( store upper nibble)
        1- ( state) 5 \ skip upper nibble; next state 5
      endof
    5 of \ second input char of \x sequence
        dup I + ( output addr)  dup c@ ( get upper nibble)
        I c@ 16 digit 0= if 0 then or ( convert digit and combine )
        swap  ( cr ." %5 " .s debug) c! ( store combined upper and lower nibble)
        ( state) 0 \ skip lower nibble; next state 0
      endof
      drop ( probably should throw an error here )
    endcase
  loop
  ( cr ." done " .s debug)
  drop ( state)
  2r> rot + ;

\ dot
\ 0 -> 0
\ 0 -> 1
\ 0 -> 2
\ 0 -> 3
\ 1 -> 0
\ 2 -> 0
\ 3 -> 4
\ 4 -> 5
\ 5 -> 0
\ end-dot
\ \a => 7
\ \b => 8
\ \e => 27
\ \f => 12
\ \l => 10
\ \m => 13,10
\ \n => 10
\ \q => 34
\ \r => 13
\ \t => 9
\ \v => 11
\ \z => 0
\ \" => 34
\ \\ => 92
\ \x## => hex conversion
