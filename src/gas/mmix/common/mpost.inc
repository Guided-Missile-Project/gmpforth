
        % give rDoes something even if no does handling
        .ifndef _NEED_DOES
        .text
does_handler:
        .endif

        % give __iotbl something even if no IO
        .ifndef _HAS_PAREN_IO
        .data
iotbl:
        .endif

        .text
_colon_show_w:
        .if _TRACE_COLON
        $SHOW_W
        go      t1, t1
        .endif
