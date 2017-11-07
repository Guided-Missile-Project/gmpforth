\ word lists may have a name associated which may be a
\ dictionary name field or a counted string
\ if not, just print the wid number
: .WID ( wid -- )
   dup cell+ cell+ @ ?dup if (name$) type drop else . then ;
