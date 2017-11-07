: SYNONYM ( "new" "old" -- ) \ create new definition with same semantics as old
  create smudge ' dup ,
  >name c@ (lex-max-name) invert and latest c@ or latest c! ( copy lex bits)
  does> @ execute ;
