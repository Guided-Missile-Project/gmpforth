        .globl  _SP0
        .globl  _RP0
        .globl  __text
        .text
__text:

        .macro $TRACE point
        $TRACE_LABEL kernel, \point
        .endm

