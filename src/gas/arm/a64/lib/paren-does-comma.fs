
: (does,) ( -- )
    $94000000D503201F               ( NOP + a64 bl opcode )
    $does_handler$                  ( address of does handler )
      ( relative offset to does handler )
      here 4 + - 30 lshift $03ffffff00000000 and
      or ,  ;

\ decoder:
\ : da ( cfa -- does_handler )
\   @ >r r@ @ $20 rshift $3ffffff and 4 * $-4000000 or r> + 4 + ;
