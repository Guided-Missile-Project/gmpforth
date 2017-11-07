        .macro $TRACE point
        $TRACE_LABEL kernel, \point
        .endm

        .macro  $ENDCODE
        $TRACE  endcode
        .align  _ALIGN
        .endm

        .long   cold
        .long   _USER
