: [CHAR] ( "c" -- c )
    parse-name drop c@ postpone literal ; immediate compile-only

