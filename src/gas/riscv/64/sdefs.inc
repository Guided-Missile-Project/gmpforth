/* RV64 specific definitions */

        /* Store a 64 bit word in 'e' to register 'f' offset k */
        .macro $XST e f k
        $XOP sd, \e, \f, \k, ofs
        .endm

        /* Load a 64 bit word in 'e' from register 'f' offset k */
        .macro $XLD e f k
        $XOP ld, \e, \f, \k, ofs
        .endm

        /* DODOES needs to occupy one cell */
        .macro $DODOES
        .set _NEED_DOES, 1
        $TRANSFER
        jal  does_handler
        nop
        .endm

        /* Set IP to the start of the cell aligned DOES> list */
        .macro $DOES_TARGET
        $MOV    ipp, ra
        $ADDI   ipp, ipp, _SZ/2
        .endm
