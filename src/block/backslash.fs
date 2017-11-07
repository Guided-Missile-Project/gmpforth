: \ ( -- )
  blk @ if
    \ 64 char lines in a block
    >in @ 63 and 64 + >in !
  else
    \ if the lf char is present, parse to that point, otherwise it's
    \ not present at all in line-oriented envionments so the whole line
    \ will be skipped anyway
    (=lf) parse 2drop
  then ; immediate
