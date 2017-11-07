CODE (s") ( -- c-addr u )
        $S_PTOS p1
        ldbu    p1, ip          % read count byte
        addu    w, ip, 1        % point to characters following count
        $PPUSH  w               %  and push
        $PPND                   % push string length
        addu    t1, p1, 1       %  add 1 for the length byte itself
        $RALIGN t1              % align to cell boundry
        $SKIP   t1              % move ip to cell following string
        $NEXT
END-CODE
COMPILE-ONLY

