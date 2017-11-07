% MMIX stack model independent machine definitions
%
% parameter stack pushes down
% return stack pushes down

rDoes   GREG % (does,) depends on rDoes being $254
sp      GREG % test suite depends on sp being $253
             % order doesn't matter for the rest
ip      GREG
rp      GREG
w       GREG
u       GREG

p1      GREG
p2      GREG
p3      GREG

r1      GREG % only needed for c11; can otherwise alias for p2

        % alias t1,t2 to $255, w
        .set t1, $255
        .set t2, w

        % alias r2 to p3
        .set r2, p3

        % aliases to avoid arch neutral GAS register clashes
        .set pp1, p1
        .set pp2, p2
        .set pp3, p3
        .set ipp, ip
        .set spp, sp

        .include "const.inc"

        .set _NO_BSS, 1 % MMIX apparently doesn't support .bss segment
        .set _DICT_TEXT, 1      % MMIX dictionary needs to be in .text for does>/code

        .set BITS_PER_BYTE, 8

        .set SIGN_BIT, ((WORD_SIZE*BITS_PER_BYTE) - 1)

        .set _LINK, 0
        .set _ALIGN, WORD_SIZE
        .set _SZ, WORD_SIZE

        .set SIGNEXT_SR, ((_SZ*BITS_PER_BYTE)-1)


        % push entity 'e' to stack 'x'
        .macro $XPUSH x e
        subu    \x, \x, _SZ
        sto     \e, \x
        .endm

        % discard 'n' items from stack 'x'
        .macro $XDISCARD x n=1
        addu    \x, \x, _SZ*\n
        .endm

        % append 'n' items to stack 'x'
        .macro $XAPPEND x n=1
        subu    \x, \x, _SZ*\n
        .endm

        % set entity 'e' to 'n'th element from stack 'x'
        .macro $XPICK x e n
        ldo     \e, \x, \n*_SZ
        .endm

        % set 'n'th element of stack 'x' to 'e'
        .macro $XSET x e n
        sto     \e, \x, \n*_SZ
        .endm

        % set entity 'e' to TOS (first element) from stack 'x'
        .macro $XTOS x e
        $XPICK  \x, \e, 0
        .endm

        % set entity 'e' to NOS (second element) from stack 'x'
        .macro $XNOS x e
        $XPICK  \x, \e, 1
        .endm

        % set entity 'e' to the third element from stack 'x'
        .macro $X3OS x e
        $XPICK  \x, \e, 2
        .endm

        % set entity 'e' to TOS (first element) from stack 'x'
        .macro $X_S_TOS x e
        $XSET   \x, \e, 0
        .endm

        % set entity 'e' to NOS (second element) from stack 'x'
        .macro $X_S_NOS x e
        $XSET   \x, \e, 1
        .endm

        % set entity 'e' to the third element from stack 'x'
        .macro $X_S_3OS x e
        $XSET   \x, \e, 2
        .endm

        % pop into entity 'e' from stack 'x'
        .macro $XPOP x e
        $XTOS     \x, \e
        $XDISCARD \x
        .endm

        % include stack operations for this machine model
        .include "stack.inc"
        %
        % Simple Unary Operations
        %

        % invert bits of entity e
        .macro $INV e
        nxor    \e, \e, 0
        .endm

        % arithmetic right left of entity e (sign propagated)
        .macro $SAR e
        sr    \e, \e, 1
        .endm

        % logical right left of entity e (sign zeroed)
        .macro $SHR e
        sru   \e, \e, 1
        .endm

        % logical left left of entity e
        .macro $SHL e
        slu   \e, \e, 1
        .endm

        %
        % Simple binary operations
        %

        % logical AND  e=e&f
        .macro $AND e f
        and   \e, \e, \f
        .endm

        % logical OR  e=e|f
        .macro $OR e f
        or    \e, \e, \f
        .endm

        % logical XOR  e=e^f
        .macro $XOR e f
        xor   \e, \e, \f
        .endm


        % addition e=e+f or e=f+g
        .macro $ADD e f g
        .ifb \g
        add   \e, \e, \f
        .else
        add   \e, \f, \g
        .endif
        .endm


        % subtraction e=e-f or e=f-g
        .macro $SUB e f g
        .ifb \g
        sub   \e, \e, \f
        .else
        sub   \e, \f, \g
        .endif
        .endm

        % set e=f where f is a constant
        .macro $SET e f
        set   \e, \f
        .endm

        % set e=f where f is a register
        .macro $MOV e f
        $SET   \e, \f
        .endm


        %
        % Load and Store
        %

        % load byte e at address f
        .macro $LDB e f
        ldbu   \e, \f, 0
        .endm

        % load _SZ byte word e at address f
        .macro $LD e f
        ldou   \e, \f, 0
        .endm

        % store byte e at address f
        .macro $STB e f
        stbu   \e, \f, 0
        .endm

        % store _SZ byte word e at address f
        .macro $ST e f
        stou   \e, \f, 0
        .endm

        %
        % Transfer
        %

        % branch to address in 'f' and save return address in 'e'
        .macro $BAL e f
        go      \e, \f
        .endm


        % Jump to address 'a'
        .macro $JMP a
        jmp     \a
        .endm

        %
        % Other Operations
        %

        % advance ip by 'n' (default _SZ)
        .macro $SKIP n=_SZ
        addu    ip, ip, \n
        .endm

        % set IP to the address IP is pointing to
        .macro $BRANCH
        ldo     ip, ip
        .endm

        % set entity 'e' to inline literal at 'i' and increment i
        .macro $LIT e
        $LD     \e, ip
        $SKIP
        .endm

        % mark end of a code word
        .macro  $ENDCODE
        $TRACE  endcode
        .endm

        % execute the code word that 'w' points to
        .macro $EXECUTE
        $LD     t1, w           % get code interpreter addr
        $TRANSFER_CFA
        $BAL    t1, t1          % branch to interpreter
        .endm

        % load the next code word into 'w' and advance 'ip'
        .macro $NEXT
        $TRACE next
        $LIT    w
        .if _TRACE_COLON
        go      t1, __colon_show_w
        .else
        .if _TRACE_COLON_NOP
        swym
        .endif
        .endif
        $EXECUTE
        .endm

        .set _DOES_LINK_REG, $255

        .macro $DODOES
        .set _NEED_DOES, 1
        $BLOCK
        swym
        $TRANSFER
        $BAL _DOES_LINK_REG, rDoes
        .endm

        .macro  $RALIGN x
        $BLOCK
        set     w, _ALIGN
        subu    w, w, \x
        and     w, w, _SZ-1
        addu    \x, \x, w
        .endm

        .macro  $SHOW_W
        stbu    __colon_sp, __iobuf
        set     __colon_count, __colon_indent
        bz      __colon_count, 2f
1:
        lda     $255, _ioarg    % write via MMIX system call
        trap    0, Fwrite, 1
        bn      $255, 9f
        sub     __colon_count, __colon_count, 1
        bnn      __colon_count, 1b
2:
        set     __colon_ptr, w  % get word CFA
3:
        sub     __colon_ptr, __colon_ptr, 1 %
        ldb     __colon_ch, __colon_ptr % get char (sign extended)
        bnn     __colon_ch, 3b % search for beginning of name
        % found it
        set     __colon_count, __colon_ch
        and     __colon_count, __colon_count, 31 % mask off other bits
        % write name
4:      addu    __colon_ptr, __colon_ptr, 1 % advance
        ldbu    __colon_ch, __colon_ptr % get char (not sign extended)
        stbu    __colon_ch, __iobuf
        lda     $255, _ioarg    % write via MMIX system call
        trap    0, Fwrite, 1
        bn      $255, 9f
        sub     __colon_count, __colon_count, 1
        bnz     __colon_count, 4b
        % stack - just show a '.' for each item instead of printing it
        set     __colon_ptr, sp
5:
        cmpu    $255, __colon_ptr, __SP0
        bnn     $255, 6f
        stbu    __colon_sp, __iobuf
        lda     $255, _ioarg    % write via MMIX system call
        trap    0, Fwrite, 1
        bn      $255, 9f
        add     __colon_ptr, __colon_ptr, _SZ
        jmp     5b
6:
        % done
        add     __colon_nl, __colon_nl, 3
        stbu    __colon_nl, __iobuf
        lda     $255, _ioarg    % write via MMIX system call
        trap    0, Fwrite, 1
        sub     __colon_nl, __colon_nl, 3
        stbu    __colon_nl, __iobuf
        lda     $255, _ioarg    % write via MMIX system call
        trap    0, Fwrite, 1
9:
        .endm
