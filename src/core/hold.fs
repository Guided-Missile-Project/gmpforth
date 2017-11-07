: HOLD ( c -- )
    -1 (hld) +!                 \ decrement hold pointer
    (hld) @ here u< if (error-num-o) throw then \ bounds check
    (hld) @ c! ;                \ save character

