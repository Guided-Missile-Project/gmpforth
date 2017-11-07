: [MARKER] ( "name" -- )
  >in @
  parse-name (find) if
    execute
  then
  >in !
  postpone marker ;
\
\ If a marker called "name" is found, execute it, then create the marker
\
