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
   $does$                ( address of does handler )
   here cell+ -          ( relative offset to does handler just after call op )
   32 lshift             ( move to upper word )
   $e8909090 or , ;      ( mix in with nop/call )
