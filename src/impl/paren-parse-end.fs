\ end parsing by updating the new start of the parse area
\ by n+1 or n, whichever will fit
: (PARSE-END) ( n -- )
    >in @ + dup (src@) @ (src) @ - < if 1+ then >in ! ;

