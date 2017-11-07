: [DEFINED] ( "name" -- flag )
  parse-name (find) if
    drop ( xt) true
  else
    2drop ( $ ) false
  then ; immediate
  