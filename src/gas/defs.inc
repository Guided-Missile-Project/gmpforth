/*
  GMP Forth GAS macros and definitions common to all targets
        
*/


        .macro $ALIGN fill=0
        .balign _ALIGN, \fill
        .endm

        .macro  $WORD value
        .ifeq   _SZ-2
        .short  \value
        .endif
        .ifeq   _SZ-4
        .long   \value
        .endif
        .ifeq   _SZ-8
        .quad   \value
        .endif
        .endm

        /* base 2 log of word size for shifting */
        .ifeq   _SZ-2
        .set    _LGSZ, 1
        .endif
        .ifeq   _SZ-4
        .set    _LGSZ, 2
        .endif
        .ifeq   _SZ-8
        .set    _LGSZ, 3
        .endif

        .ifndef HAS_MACH_FUNC_MARK
        /* empty macro if not already defined */
        .macro $MACH_FUNC_MARK x
        .endm
        .endif

        .macro $HEAD     lex, name, interp, label
        .ifdef DICT_IN_DATA
        .data
        .else
        .text
        .endif
        .ifndef _HEADLESS
        $ALIGN
        .set    _LFA, .
        .globl \label\()_lfa
\label\()_lfa:
        $WORD   _LINK
        .set    _LINK, _LFA
        .globl \label\()_nfa
\label\()_nfa:
        .byte   \lex
        .ascii "\name"
        .endif
        $ALIGN
        .globl \label
\label\():
        .ifnb \interp
        $WORD   \interp
        .else
        $WORD   \label\()_pfa
        $MACH_FUNC_MARK \label\()_pfa
        .endif
        .globl \label\()_pfa
\label\()_pfa:
        .endm

        .macro $TRACE_LABEL subsys point
__trace_\point\()_\subsys\()_\@:
        .endm

        .macro $BLOCK
        $TRACE block
        .endm

        .macro $TRANSFER
        $TRACE transfer
        .endm

        .macro $TRANSFER_CFA
        $TRACE transfer_cfa
        .endm

        .macro  $CODE lex, name, label
        $HEAD    \lex, \name, "", \label
        $BLOCK
        .endm

        .macro  $COLON lex, name, label
        .set    _NEED_DOCOL, 1 
        $HEAD    \lex, \name, DOCOL, \label
        .endm

        .macro  $CONSTANT lex, name, label
        .set    _NEED_DOCON, 1 
        $HEAD    \lex, \name, DOCON, \label
        .endm

        .macro  $USER    lex, name, label
        .set    _NEED_DOUSE, 1 
        $HEAD    \lex, \name, DOUSE, \label
        .endm

        .macro  $VARIABLE   lex, name, label
        .set    _NEED_DOVAR, 1 
        $HEAD    \lex, \name, DOVAR, \label
        .endm
        
        .macro  $VOCABULARY   lex, name, label
        $HEAD    \lex, \name, DOVOC, \label
        .endm
