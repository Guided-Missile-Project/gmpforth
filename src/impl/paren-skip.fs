: (SKIP) ( -- ... advance >in while skipping whitespace )
  (input) ?do
    I c@ bl > ?leave  1 >in +!
  loop ;
