: (SEE) ( xt -- )
  >body begin
    dup @
    2dup swap cr . .name swap cell+ swap
    case
    ['] (branch) of dup space ? cell+ endof
    ['] (dolit) of dup space ? cell+ endof
    ['] (do) of dup space ? cell+ endof
    ['] (?do) of dup space ? cell+ endof
    ['] (loop) of  dup space ? cell+ endof
    ['] (+loop) of  dup space ? cell+ endof
    ['] (s") of count 2dup space type + aligned endof
    ['] (0branch) of  dup space ? cell+ endof
    ['] exit of cr drop exit endof
    endcase
  again ;
