        .globl  _start
        .globl  _restart
        .globl  _exit
        .globl  _ENTRY
        .globl  _USER
        .globl  _SP0
        .globl  does_handler

        % FIXME - all these are working around my misunderstanding
        % of how LDA is supposed to work. On the other hand MMIX has
        % a ton of registers - may as well use them.

__SP0   GREG    _SP0
__RP0   GREG    _RP0
__ENTRY GREG    _ENTRY
__exit0 GREG    _exit0

        .ifndef _TRACE_COLON
        .set _TRACE_COLON, 0           % true if tracing colon defs
        .endif
        .set _TRACE_COLON_NOP, 0       % true if not tracing colon but
                                       % want to use the same amount of code
                                       % so one can compare machine traces

        .if _TRACE_COLON
        .ifdef _HEADLESS
        .error "tracing is unsupported if headless"
        .endif
        .globl  _colon_show_w

__colon_indent  GREG
__colon_count   GREG
__colon_sp      GREG '.'
__colon_nl      GREG 10
__colon_ch      GREG
__colon_ptr     GREG
__colon_show_w  GREG _colon_show_w
        .endif
        .text

        .set SP_SLACK, 1                % need one word of slack space in pstack
        .set RP_SLACK, 1                % need one word of slack space in rstack

        LOC     #100

Main:
_start:
        $BLOCK
_restart:
        lda     sp, _SP0
        lda     rp, _RP0

        xor     p1, p1, p1              % clear cached ptos

        /* set ip to _exit0, _ENTRY's DOCOL will push to return stack */
        lda     ip, _exit0

        /* set USER area */
        lda     u, _USER

        /* does handler */
        lda     rDoes, does_handler
        /* execute from _ENTRY */
        lda     w, _ENTRY
        ldo     t1, w
        $TRANSFER_CFA
        go      t1, t1
        $ENDCODE

        $ALIGN
_exit:  $BLOCK
        $S_PTOS p1      % for test purposes; flush TOS to memory
        TRAP 0,Halt,0

        .data

        /* colon def fragment pushed on return stack to exit after
          _ENTRY returns. */
_exit0: .quad   _exit1
        /* code def to _exit */
_exit1: .quad   _exit
