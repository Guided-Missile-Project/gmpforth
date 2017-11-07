\ This is not as space efficient as it could be, as immediate words
\ could be compiled directly, but this matches the strategy used in
\ the cross-compiler.

: POSTPONE ( "w" -- )
    parse-name (find) ?dup 0= if (error-undef) throw then (lex-immediate) and
    swap postpone literal if postpone execute else postpone compile, then ;
    immediate compile-only

