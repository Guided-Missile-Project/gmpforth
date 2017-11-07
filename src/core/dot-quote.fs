: ." ( -- )
    state @ if
        \ one thing if compile
        postpone (s") [char] " parse (",) postpone type
    else
        \ other if not
        [char] " parse type
    then ; immediate

