\ receive a line from the terminal
: ACCEPT ( a n1 -- n2 )
    dup >r
    begin
        key dup (=cr) <>
    while
        dup (=bs) = over (=rub) = or
        if \ erasing
            drop ( character)
            dup 0 r@ within if \ erasing char within bounds
                -1 /string
                (=bs) emit \ erase from screen
                space
                (=bs) emit
            then
        else
            over 0 > if \ room in buffer
                dup emit \ show character
                >r over r> swap c! \ store character
                1 /string \ update buffer pointer: a++ n--
            else
                drop \ char
            then
        then
    repeat
    space drop ( key) swap drop ( a) r> swap - ;

