: ' ( "w" -- xt )
    parse-name (find)
    0= if (error-undef) throw then ;

