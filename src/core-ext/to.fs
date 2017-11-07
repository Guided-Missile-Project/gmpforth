: TO ( x... "name" -- )
  ' >body dup cell+ swap @ ( -- data store-xt )
  state @ if
    swap postpone literal compile,
  else
    execute
  then ; immediate
