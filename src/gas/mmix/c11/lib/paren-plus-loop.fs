CODE (+loop) ( n --- ...incr loop index by n and exit if boundry condition met)
                                % r1: idx
        $RNOS   r2              % r2: lim
        add     t2, r1, p1      % t2: idxp = idx + incr
        sub     t1, r1, r2      % t1: idx-lim
        $MOV    r1, t2          % proactively save new index
        sub     t2, t2, r2      % t2: idxp-lim
        cmpu    t1, t2, t1      % t1: -1:uidxp u< uidx 1:uidxp u> uidx
        xor     t1, t1, p1      % combine with incr sign
        bn      t1, 1f          % stop looping if incr^cmpu < 0
        $BRANCH                 % continue looping
        jmp     2f
1:
        $RDIS   3               % done - discard loop parameters from rstack
        $RTOS   r1              % refresh RTOS
        $SKIP                   % skip branch address
2:
        $PDIS                   % discard incr
        $PTOS   p1              % refresh TOS
        $NEXT
END-CODE
COMPILE-ONLY
