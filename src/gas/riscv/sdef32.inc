/* RV32 specific definitions */

        /* Store a 32 bit word in 'e' to register 'f' offset k */
        .macro $XST e f k
        $XOP sw, \e, \f, \k, ofs
        .endm

        /* Load a 32 bit word in 'e' from register 'f' offset k */
        .macro $XLD e f k
        $XOP lw, \e, \f, \k, ofs
        .endm

        .macro $DODOES
        .set _NEED_DOES, 1
        $TRANSFER
        jal  does_handler
        .endm

        /* Set IP to the start of the DOES> list */
        .macro $DOES_TARGET
        $MOV    ipp, ra
        .endm

        /* CSR ops */

        .macro $RDCYCLEH e
        $XOP    rdcycleh, \e
        .endm
