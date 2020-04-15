        .macro  $SYS sys
        $SET    a7, \sys
        ecall
        .endm

        /* argument order a0 a1 a2 a3 a4 a5 */
