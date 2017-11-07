\ begin parsing by returning the start of the parse area
: (PARSE-BEGIN) ( -- a n )
    source >in @ /string ;

