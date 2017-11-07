        .globl  _SP0
        .globl  _RP0

        .macro $TRACE point
        $TRACE_LABEL kernel, \point
        .endm

