: REFILL ( -- flag )
    source-id 0< 0= dup if \ not evaluate
      query
    then ;

