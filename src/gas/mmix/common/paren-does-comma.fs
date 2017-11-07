\ memory layout, where abcd is a 32 bit relative offset from
\ the cell following this 8 byte code fragment to the does handler
\
\ does:
\ ...
\ create blah does>
\ (here)
\ nop
\ nop
\ nop
\ call
\ d
\ c
\ b
\ a
\ relative offset to does: from this address

: (does,) ( -- )
  \ $does$ in register $254, return in scratch $255
  $fd0000009ffffe00 , ;      ( swym;go $255, $254, 0 )
