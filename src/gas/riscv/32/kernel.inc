
        $CODE 129, "\x21", store
                $PNOS   pp2
                $ST     pp2, pp1
                $PDIS   2
                $PTOS   pp1
                $NEXT
        $ENDCODE

        $CODE 129, "\x40", fetch
                $LD     pp1, pp1
                $NEXT
        $ENDCODE

        $CODE 130, "\x63\x21", c_store
                $PNOS   pp2
                $STB    pp2, pp1
                $PDIS   2
                $PTOS   pp1
                $NEXT
        $ENDCODE

        $CODE 130, "\x63\x40", c_fetch
                $LDB    pp1, pp1
                $NEXT
        $ENDCODE

        $CODE 131, "\x72\x70\x21", rp_store
                $MOV    rp, pp1
                $PDIS
                $PTOS   pp1
                $NEXT
        $ENDCODE

        $CODE 131, "\x73\x70\x21", sp_store
                $MOV  spp, pp1
                $PTOS pp1
                $NEXT
        $ENDCODE

        $CODE 131, "\x72\x70\x40", rp_fetch
                $S_PTOS pp1
                $PPND
                $MOV    pp1, rp
                $NEXT
        $ENDCODE

        $CODE 131, "\x73\x70\x40", sp_fetch
                $S_PTOS pp1
                $MOV    pp1, spp
                $PPND
                $NEXT
        $ENDCODE

        $CODE 132, "\x2d\x72\x6f\x74", minus_rot
                $MOV    pp3, pp1
                $PNOS   pp1
                $P3OS   pp2
                $S_P3OS pp3
                $S_PNOS pp2
                $NEXT
        $ENDCODE

        $CODE 162, "\x3e\x72", greater_r
                $RPUSH  pp1
                $PDIS
                $PTOS   pp1
                $NEXT
        $ENDCODE

        $CODE 132, "\x64\x72\x6f\x70", drop
                $PDIS
                $PTOS   pp1
                $NEXT
        $ENDCODE

        $CODE 131, "\x64\x75\x70", dup
                $S_PTOS pp1
                $PPND
                $NEXT
        $ENDCODE

        $CODE 132, "\x6f\x76\x65\x72", over
                $S_PTOS pp1
                $PNOS   pp1
                $PPND
                $NEXT
        $ENDCODE

        $CODE 132, "\x70\x69\x63\x6b", pick
                $ADDI   t1 , pp1, 1                     /* start index at NOS */
                $SHL    t1, t1, _LGSZ                   /* assumes stack grows down */
                $ADD    t1, t1, spp
                $LD     pp1, t1
                $NEXT
        $ENDCODE

        $CODE 162, "\x72\x3e", r_greater
                $S_PTOS pp1
                $PPND
                $RPOP   pp1
                $NEXT
        $ENDCODE

        $CODE 162, "\x72\x40", r_fetch
                $S_PTOS pp1
                $PPND
                $RTOS   pp1
                $NEXT
        $ENDCODE

        $CODE 131, "\x72\x6f\x74", rot
                $MOV    pp2, pp1
                $PNOS   pp3
                $P3OS   pp1
                $S_PNOS pp2
                $S_P3OS pp3
                $NEXT
        $ENDCODE

        $CODE 132, "\x73\x77\x61\x70", swap
                $MOV    pp2, pp1
                $PNOS   pp1
                $S_PNOS pp2
                $NEXT
        $ENDCODE

        $CODE 169, "\x28\x30\x62\x72\x61\x6e\x63\x68\x29", paren_zero_branch
                $LIT    t1              /* branch address */
                bnez    pp1, 1f
                nop
                $MOV    ipp, t1         /* branch if 'pp1' zero */
1:
                $PDIS
                $PTOS   pp1             /* refresh TOS */
                $NEXT
        $ENDCODE

        $CODE 168, "\x28\x62\x72\x61\x6e\x63\x68\x29", paren_branch
                $BRANCH
                $NEXT
        $ENDCODE

        $CODE 167, "\x28\x64\x6f\x6c\x69\x74\x29", paren_dolit
                $S_PTOS pp1
                $PPND
                $LIT    pp1
                $NEXT
        $ENDCODE

        $CODE 164, "\x28\x73\x22\x29", paren_s_quote
                $S_PTOS pp1
                $LDB    pp1, ipp        /* read count byte */
                $ADD    w, ipp, 1       /* point to characters following count */
                $PPUSH  w               /*  and push */
                $PPND                   /* push string length */
                $ADD    t1, pp1, 1      /*  add 1 for the length byte itself */
                $RALIGN t1              /* align to cell boundry */
                $SKIP   t1              /* move ip to cell following string */
                $NEXT
        $ENDCODE

        $CODE 135, "\x65\x78\x65\x63\x75\x74\x65", execute
                $MOV    w, pp1
                $PDIS
                $PTOS   pp1
                $EXECUTE
        $ENDCODE

        $CODE 164, "\x65\x78\x69\x74", exit
                $UNNEST
                $NEXT
        $ENDCODE

        $CODE 165, "\x28\x3f\x64\x6f\x29", paren_question_do
                $LIT    t1              /* get branch address compiled after (do) */
                $PNOS   pp2             /* get limit */
                beq     pp1, pp2, 1f    /* do not loop if index equals limit */
                nop
                $RPUSH  t1              /* branch */
                $RPUSH  pp2             /* limit */
                $RPUSH  pp1             /* start=index */
                $JMP    2f
1:
                $MOV    ipp, t1         /* done looping */
2:
                $PDIS   2               /* discard n1 n2 */
                $PTOS   pp1             /* refresh TOS */
                $NEXT
        $ENDCODE

        $CODE 167, "\x28\x2b\x6c\x6f\x6f\x70\x29", paren_plus_loop
                $RTOS   t1              /* idx */
                $RNOS   t2              /* lim */
                $ADD    t3, t1, pp1     /* idxp = idx + incr */
                $S_RTOS t3              /* proactively update idx */
                $SUB    t1, t2          /* idx -= lim */
                $SUB    t3, t2          /* idxp -= lim */
                sltu    t2, t3, t1      /* t2=1 if t1 u< t3 */
                negu    t2, t2          /* t2=-1 if t1 u< t3 */
                xor     t2, t2, pp1     /* combine with sign of incr */
                bltz    t2, 1f          /* done if t2 < 0 */
                $PDIS                   /* delay slot: discard increment */
                $BRANCH                 /* continue looping */
                $JMP    2f
1:
                $RDIS   3               /* done - discard loop parameters from rstack */
                $SKIP                   /* skip branch address */
2:
                $PTOS   pp1             /* refresh TOS */
                $NEXT
        $ENDCODE

        $CODE 164, "\x28\x64\x6f\x29", paren_do
                $LIT    w       /* get branch address compiled after (do) */
                $PNOS   pp2     /* get limit */
                $RPUSH  w       /* branch */
                $RPUSH  pp2     /* limit */
                $RPUSH  pp1     /* start=index */
                $PDIS   2       /* discard */
                $PTOS   pp1     /* refresh TOS */
                $NEXT
        $ENDCODE

        $CODE 167, "\x28\x6c\x65\x61\x76\x65\x29", paren_leave
                $RPICK  ipp, 2
                $RDIS   3
                $NEXT
        $ENDCODE

        $CODE 166, "\x28\x6c\x6f\x6f\x70\x29", paren_loop
                $RTOS   t1              /* index */
                $RNOS   t2              /* limit */
                $ADDI   t1, t1, 1       /* incr index */
                beq     t1, t2, 1f      /* exit if index=limit */
                nop
                $S_RTOS t1              /* save new index */
                $BRANCH
                $JMP    2f
1:
                $RDIS   3               /* discard loop parameters from rstack */
                $SKIP
2:
                $NEXT
        $ENDCODE

        $CODE 161, "\x69", i
                $S_PTOS pp1
                $PPND
                $RTOS   pp1
                $NEXT
        $ENDCODE

        $CODE 161, "\x6a", j
                $S_PTOS pp1
                $PPND
                $RPICK  pp1, 3
                $NEXT
        $ENDCODE

        $CODE 129, "\x2a", star
                $PNOS   pp2
                $PDIS
                $MULS   pp1, pp2, pp1
                $NEXT
        $ENDCODE

        $CODE 129, "\x2b", plus
                $PNOS   pp2
                $ADD    pp1, pp2
                $PDIS
                $NEXT
        $ENDCODE

        $CODE 129, "\x2d", minus
                $PNOS   pp2
                $SUB    pp1, pp2, pp1
                $PDIS
                $NEXT
        $ENDCODE

        $CODE 131, "\x61\x6e\x64", and
                $PNOS   pp2
                $AND    pp1, pp2
                $PDIS
                $NEXT
        $ENDCODE

        $CODE 134, "\x69\x6e\x76\x65\x72\x74", invert
                $INV    pp1
                $NEXT
        $ENDCODE

        $CODE 130, "\x6f\x72", or
                $PNOS   pp2
                $OR     pp1, pp2
                $PDIS
                $NEXT
        $ENDCODE

        $CODE 130, "\x75\x3c", u_less
                $PNOS   pp2
                $PDIS
                sltu    pp1, pp2, pp1
                neg     pp1, pp1
                $NEXT
        $ENDCODE

        $CODE 131, "\x75\x6d\x2a", um_star
                $PNOS   pp2
                $MULU   pp1, pp2
                mfhi    pp1
                mflo    pp2
                $S_PNOS pp2
                $NEXT
        $ENDCODE

        $CODE 134, "\x75\x6d\x2f\x6d\x6f\x64", um_slash_mod
                $MOV    t2, pp1        /* set B=u1 */
                $PDIS
                $PTOS   pp2            /* set A=ud */
                $PNOS   pp1
                $SET    t1, 0          /* clear P */
                $SET    pp3, 0
                $SET    w, BITS_PER_WORD*2     /* w is loop counter */
1:
                /* division loop */
                /* (i) shift A left with carry out */
                $SHR    t8, pp1, BITS_PER_WORD-1  /* t8 is carry-out from A low */
                $ADD    pp1, pp1, pp1

                $SHR    t9, pp2, BITS_PER_WORD-1  /* t9 is carry-out from A high */
                $ADD    pp2, pp2, pp2
                $ADD    pp2, pp2, t8    /* A-low carry-in */
                /* shift P left with carry in from A */
                $SHR    t8, t1, BITS_PER_WORD-1   /* t8 is carry-out from P low */
                $ADD    t1, t1, t1
                $ADD    t1, t1, t9      /* A-high carry-in */
                $ADD    pp3, pp3, pp3
                $ADD    pp3, pp3, t8    /* P-low carry-in */

                /* (ii) X=P-B */
                $SUB    t3, t1, t2
                sltu    t8, t1, t2      /* from d-minus;if that's broken this is too */
                $SUB    t4, pp3, t8

                /* (iii) X>=0: A |= 1 */
                bltz    t4, 2f
                nop
                or      pp1, pp1, 1

                /* (iv)  X>=0: P=X */
                $MOV    t1, t3
                $MOV    pp3, t4
2:
                /* handle loop counter */
                $SUB    w, w, 1
                bnez    w, 1b
                nop
                $S_PNOS t1
                $NEXT
        $ENDCODE

        $CODE 166, "\x75\x6e\x6c\x6f\x6f\x70", unloop
                $RDIS   3
                $NEXT
        $ENDCODE

        $CODE 131, "\x78\x6f\x72", xor
                $PNOS   pp2
                $XOR    pp1, pp2
                $PDIS
                $NEXT
        $ENDCODE

        $CODE 130, "\x30\x3d", zero_equals
                seq     pp1, pp1, 0
                neg     pp1, pp1
                $NEXT
        $ENDCODE

        $CODE 130, "\x30\x3c", zero_less
                slt     pp1, pp1, 0
                neg     pp1, pp1
                $NEXT
        $ENDCODE

        $CODE 129, "\x3c", less
                $PNOS   pp2             /* n1 */
                $PDIS
                slt     pp1, pp2, pp1
                neg     pp1, pp1
                $NEXT
        $ENDCODE

        $CODE 130, "\x32\x2a", two_star
                $SHL    pp1
                $NEXT
        $ENDCODE

        $CODE 130, "\x32\x2f", two_slash
                $SAR    pp1
                $NEXT
        $ENDCODE

        $CODE 131, "\x75\x32\x2f", u_two_slash
                $SHR    pp1
                $NEXT
        $ENDCODE

        $CODE 130, "\x6d\x2b", m_plus
                $SAR    t1, pp1,SIGNEXT_SR /* sign extend pp1 into t1 (n-upper) */
                $PDIS
                $PNOS   t2               /* d1-lower */
                $ADD    pp2, pp1, t2     /* d2l = d1l + n-lower */
                sltu    t2, pp2, pp1     /* t2 = (d2l u< n-lower) ? 1 : 0 (carry) */
                $PTOS   pp1              /* d1 upper */
                $ADD    pp1, pp1, t1     /* d2u' = d1u + n-upper */
                $ADD    pp1, pp1, t2     /* d2u = d1u' + carry */
                $S_PNOS pp2
                $NEXT
        $ENDCODE

        $CODE 163, "\x32\x3e\x72", two_greater_r
                $PNOS   pp2
                $RPND   2
                $S_RNOS pp2
                $S_RTOS pp1
                $PDIS   2
                $PTOS   pp1
                $NEXT
        $ENDCODE

        $CODE 163, "\x32\x72\x40", two_r_fetch
                $S_PTOS pp1
                $RTOS   pp1
                $RNOS   pp2
                $PPND   2
                $S_PNOS pp2
                $NEXT
        $ENDCODE

        $CODE 163, "\x32\x72\x3e", two_r_greater
                $S_PTOS pp1
                $RTOS   pp1
                $RNOS   pp2
                $PPND   2
                $S_PNOS pp2
                $RDIS   2
                $NEXT
        $ENDCODE

        $CODE 163, "\x6e\x3e\x72", n_greater_r
                $PDIS
                $MOV    t1, pp1
1:
                $PPOP   t2
                $RPUSH  t2
                $SUB    t1, t1, 1
                bnez    t1, 1b
                nop
                $RPUSH  pp1
                $PTOS   pp1             /* refresh pp1 */
                $NEXT
        $ENDCODE

        $CODE 163, "\x6e\x72\x3e", nr_greater
                $S_PTOS pp1
                $RPOP   pp1
                $MOV    t1, pp1
1:
                $RPOP   t2
                $PPUSH  t2

                $SUB    t1, t1, 1
                bnez    t1, 1b
                nop
                $PPND
                $NEXT
        $ENDCODE

        $CODE 130, "\x64\x2b", d_plus
                $MOV    t1, pp1          /* d2 upper */
                $PNOS   pp2              /* d2 lower */
                $PDIS   2
                $PNOS   pp1              /* d1 lower */
                $ADD    pp2, pp1, pp2    /* d3l = d1l + d2l */
                sltu    t2, pp2, pp1     /* t2 = (d3l u< d1l) ? 1 : 0 (carry) */
                $PTOS   pp1              /* d1 upper */
                $ADD    pp1, pp1, t1     /* d3u' = d1u + d2u */
                $ADD    pp1, pp1, t2     /* d3u = d3u' + carry */
                $S_PNOS pp2
                $NEXT
        $ENDCODE

        $CODE 130, "\x64\x2d", d_minus
                $MOV    t1, pp1          /* d2 upper */
                $PNOS   pp2              /* d2 lower */
                $PDIS   2
                $PNOS   pp1              /* d1 lower */
                $SUB    pp2, pp1, pp2    /* d3l = d1l - d2l */
                sltu    t2, pp1, pp2     /* t2 = (d1l u< d3l) ? 1 : 0 (borrow) */
                $PTOS   pp1              /* d1 upper */
                $SUB    pp1, pp1, t1     /* d3u' = d1u - d2u */
                $SUB    pp1, pp1, t2     /* d3u = d3u' - borrow */
                $S_PNOS pp2
                $NEXT
        $ENDCODE

        $COLON 132, "\x72\x6f\x6c\x6c", roll
        .long question_dup
        .long paren_zero_branch
        .long roll_9
        .long one_minus
        .long swap
        .long greater_r
        .long roll
        .long r_greater
        .long swap
roll_9:
        .long exit

        $COLON 167, "\x28\x3b\x63\x6f\x64\x65\x29", paren_semis_code
        .long r_greater
        .long latest
        .long name_greater
        .long store
        .long exit

        $COLON 134, "\x63\x72\x65\x61\x74\x65", create
        .long parse_minus_name
        .long paren_question_name
        .long paren_create
        .long paren_semis_code
        $MACH_FUNC_MARK DOCRE
DOCRE:
            $DOVAR

        $COLON 129, "\x3a", colon
        .long create
        .long smudge
        .long paren_dolit
        .long right_bracket
        .long execute
        .long paren_semis_code
        $MACH_FUNC_MARK DOCOL
DOCOL:
            $DOCOL

        $COLON 136, "\x76\x61\x72\x69\x61\x62\x6c\x65", variable
        .long create
        .long paren_dolit
        .long 0
        .long comma
        .long paren_semis_code
        $MACH_FUNC_MARK DOVAR
DOVAR:
            $DOVAR

        $COLON 136, "\x63\x6f\x6e\x73\x74\x61\x6e\x74", constant
        .long create
        .long comma
        .long paren_semis_code
        $MACH_FUNC_MARK DOCON
DOCON:
            $DOCON

        $COLON 135, "\x28\x64\x6f\x65\x73\x2c\x29", paren_does_comma
        .long paren_dolit
        .long 201326592
        .long paren_dolit
        .long does_handler
        .long paren_dolit
        .long 2
        .long rshift
        .long paren_dolit
        .long 67108863
        .long and
        .long or
        .long comma
        .long paren_dolit
        .long 0
        .long comma
        .long exit

        $CODE 132, "\x28\x69\x6f\x29", paren_io

                .globl  __edict
                .set _HAS_PAREN_IO, 1

                $BLOCK
                /* check (io) opcode */
                $TRANSFER
                bgez    pp1, ret_false  /* generalized syscall not supported */
                nop
1:
                $BLOCK
                slti    t1, pp1, -16
                $TRANSFER
                bnez    t1, ret_false   /* local IO call out of range */
                nop
1:
                $BLOCK
                $LD     t1, $gp, %gp_rel(_iotbl)
                $SHL    pp1, pp1, _LGSZ
                $ADD    t1, t1, pp1
                $XLD    t1, (t1)        /* get handler address */
                $TRANSFER
                jr      t1              /* branch to handler */
                nop
                $ENDCODE

                /* txstore ( c io -- ) */
txstore:
                $BLOCK
                $PDIS   1
                /* ENDIAN DEPENDENT */
                $SET    $a0, 1
                $ADDI   $a1, spp, (_SZ-1)
                $SET    $a2, 1
                $SYS    SYS_WRITE       /* sys_write(1,sp+_SZ-1,1) */
                $PDIS   1
                $PTOS   pp1
                $NEXT

                /* ret_true  */
ret_true:
                $BLOCK
                $SET    pp1, -1
                $NEXT

                /* ret_false */
ret_false:
                $BLOCK
                $SET    pp1, 0
                $NEXT

                /* rx_fetch ( io -- c ) */
rxfetch:
                $BLOCK
                $SET    pp1, 0
                $S_PTOS pp1
                /* ENDIAN DEPENDENT */
                $SET    $a0, 0
                $ADDI   $a1, spp, (_SZ-1)
                $SET    $a2, 1
                $SYS    SYS_READ        /* O32 sys_read(0,sp+_SZ-1,1) */
                $PTOS   pp1
                $NEXT

memlimit:
                $LD     pp1,  $gp, %gp_rel(__edict)
                $NEXT

io_mmap:
                $BLOCK
                /* io_mmap ( fd len -- addr' ior )  */
                $SET    pp1, 0
                $NEXT

io_munmap:
                $BLOCK
                /* io_munmap ( addr len -- ior )  */
                $SET    pp1, 0
                $NEXT

io_open_file:
                $BLOCK
                /* io_open_file  ( cstr flags -- ior )  */
                $SET    pp1, 0
                $NEXT

io_close_file:
                $BLOCK
                /* io_close_file  ( fd -- ior )  */
                $SET    pp1, 0
                $NEXT

io_size_file:
                $BLOCK
                /* io_size_file  ( fd -- ior )  */
                $SET    pp1, 0
                $NEXT

hlt:
                $TRANSFER
                $JMP    _exit

                .sdata
        _iotbl: $WORD   iotbl

                .data

iotbl_end:
                $WORD   ret_false       /* -16 unimplemented   */
                $WORD   ret_false       /* -15 unimplemented   */
                $WORD   ret_false       /* -14 unimplemented   */
                $WORD   io_size_file    /* -13 IO_SIZE_FILE    */
                $WORD   io_close_file   /* -12 IO_CLOSE_FIZE   */
                $WORD   io_open_file    /* -11 IO_OPEN_FILE    */
                $WORD   io_munmap       /* -10 IO_MUNMAP       */
                $WORD   io_mmap         /* -9  IO_MMAP         */
                $WORD   hlt             /* -8  IO_HALT         */
                $WORD   ret_true        /* -7  IO_RX_QUESTION  */
                $WORD   rxfetch         /* -6  IO_RX_FETCH     */
                $WORD   ret_true        /* -5  IO_TX_QUESTION  */
                $WORD   txstore         /* -4  IO_TX_STORE     */
                $WORD   memlimit        /* -3  IO_MEM_LIMIT    */
                $WORD   ret_false       /* -2  unimplemented   */
                $WORD   ret_false       /* -1  unimplemented   */
iotbl:

        $ENDCODE

        $COLON 132, "\x75\x73\x65\x72", user
        .long create
        .long cells
        .long comma
        .long paren_semis_code
        $MACH_FUNC_MARK DOUSE
DOUSE:
            $DOUSE

        $CONSTANT 134, "\x28\x63\x65\x6c\x6c\x29", paren_cell
        .long 4

        $CONSTANT 133, "\x28\x70\x61\x64\x29", paren_pad
        .long 68

        $COLON 134, "\x3f\x73\x74\x61\x63\x6b", question_stack
        .long sp_fetch
        .long paren_sp_zero
        .long fetch
        .long swap
        .long u_less
        .long paren_zero_branch
        .long question_stack_9
        .long paren_error_minus_stack_minus_u
        .long throw
question_stack_9:
        .long sp_fetch
        .long paren_sp_zero
        .long fetch
        .long paren_dolit
        .long 256
        .long cells
        .long minus
        .long u_less
        .long paren_zero_branch
        .long question_stack_21
        .long paren_error_minus_stack_minus_o
        .long throw
question_stack_21:
        .long exit

        $COLON 136, "\x77\x6f\x72\x64\x6c\x69\x73\x74", wordlist
        .long here
        .long dup
        .long paren_dolit
        .long 0
        .long comma
        .long paren_vocs
        .long dup
        .long fetch
        .long comma
        .long store
        .long paren_dolit
        .long 0
        .long comma
        .long exit

        $COLON 138, "\x76\x6f\x63\x61\x62\x75\x6c\x61\x72\x79", vocabulary
        .long create
        .long latest
        .long wordlist
        .long cell_plus
        .long cell_plus
        .long store
        .long paren_semis_code
        $MACH_FUNC_MARK DOVOC
DOVOC:
        $DODOES
        .long context
        .long store
        .long exit

        $VOCABULARY 133, "\x66\x6f\x72\x74\x68", forth
        .long forth_last
        .long 0
        .long forth_nfa

        $USER 135, "\x28\x23\x75\x73\x65\x72\x29", paren_number_user
        .long 0 * _SZ

        $USER 134, "\x28\x73\x72\x63\x30\x29", paren_src_zero
        .long 1 * _SZ

        $USER 136, "\x28\x73\x72\x63\x65\x6e\x64\x29", paren_srcend
        .long 2 * _SZ

        $USER 133, "\x28\x73\x72\x63\x29", paren_src
        .long 3 * _SZ

        $USER 134, "\x28\x73\x72\x63\x40\x29", paren_src_fetch
        .long 4 * _SZ

        $USER 135, "\x28\x73\x72\x63\x69\x64\x29", paren_srcid
        .long 5 * _SZ

        $USER 135, "\x28\x23\x6c\x69\x6e\x65\x29", paren_number_line
        .long 6 * _SZ

        $USER 132, "\x3e\x69\x6e\x2d", greater_in_minus
        .long 7 * _SZ

        $USER 131, "\x62\x6c\x6b", blk
        .long 8 * _SZ

        $USER 131, "\x3e\x69\x6e", greater_in
        .long 9 * _SZ

        $USER 133, "\x73\x74\x61\x74\x65", state
        .long 10 * _SZ

        $USER 132, "\x62\x61\x73\x65", base
        .long 11 * _SZ

        $USER 133, "\x28\x68\x6c\x64\x29", paren_hld
        .long 12 * _SZ

        $USER 134, "\x28\x68\x65\x72\x65\x29", paren_here
        .long 13 * _SZ

        $USER 133, "\x28\x72\x78\x3f\x29", paren_rx_question
        .long 14 * _SZ

        $USER 133, "\x28\x72\x78\x40\x29", paren_rx_fetch
        .long 15 * _SZ

        $USER 133, "\x28\x74\x78\x3f\x29", paren_tx_question
        .long 16 * _SZ

        $USER 133, "\x28\x74\x78\x21\x29", paren_tx_store
        .long 17 * _SZ

        $USER 134, "\x28\x62\x6f\x6f\x74\x29", paren_boot
        .long 18 * _SZ

        $USER 133, "\x28\x73\x70\x30\x29", paren_sp_zero
        .long 19 * _SZ

        $USER 133, "\x28\x72\x70\x30\x29", paren_rp_zero
        .long 20 * _SZ

        $USER 131, "\x64\x70\x6c", dpl
        .long 21 * _SZ

        $USER 131, "\x65\x72\x66", erf
        .long 22 * _SZ

        $USER 131, "\x74\x69\x62", tib
        .long 23 * _SZ

        $USER 137, "\x28\x73\x63\x72\x61\x74\x63\x68\x29", paren_scratch
        .long 24 * _SZ

        $USER 137, "\x28\x61\x62\x6f\x72\x74\x22\x24\x29", paren_abort_quote_dollar
        .long 25 * _SZ

        $USER 135, "\x63\x6f\x6e\x74\x65\x78\x74", context
        .long 26 * _SZ

        $USER 135, "\x63\x75\x72\x72\x65\x6e\x74", current
        .long 34 * _SZ

        $USER 134, "\x28\x76\x6f\x63\x73\x29", paren_vocs
        .long 35 * _SZ

        $CONSTANT 133, "\x28\x3d\x62\x73\x29", paren_equals_bs
        .long 8

        $CONSTANT 134, "\x28\x3d\x72\x75\x62\x29", paren_equals_rub
        .long 127

        $CONSTANT 133, "\x28\x3d\x6c\x66\x29", paren_equals_lf
        .long 10

        $CONSTANT 133, "\x28\x3d\x63\x72\x29", paren_equals_cr
        .long 13

        $CONSTANT 130, "\x62\x6c", bl
        .long 32

        $CONSTANT 141, "\x28\x65\x72\x72\x6f\x72\x2d\x61\x62\x6f\x72\x74\x29", paren_error_minus_abort
        .long -1

        $CONSTANT 142, "\x28\x65\x72\x72\x6f\x72\x2d\x61\x62\x6f\x72\x74\x22\x29", paren_error_minus_abort_quote
        .long -2

        $CONSTANT 143, "\x28\x65\x72\x72\x6f\x72\x2d\x73\x74\x61\x63\x6b\x2d\x6f\x29", paren_error_minus_stack_minus_o
        .long -3

        $CONSTANT 143, "\x28\x65\x72\x72\x6f\x72\x2d\x73\x74\x61\x63\x6b\x2d\x75\x29", paren_error_minus_stack_minus_u
        .long -4

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x74\x75\x72\x6e\x2d\x6f\x29", paren_error_minus_return_minus_o
        .long -5

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x74\x75\x72\x6e\x2d\x75\x29", paren_error_minus_return_minus_u
        .long -6

        $CONSTANT 138, "\x28\x65\x72\x72\x6f\x72\x2d\x64\x6f\x29", paren_error_minus_do
        .long -7

        $CONSTANT 140, "\x28\x65\x72\x72\x6f\x72\x2d\x64\x69\x63\x74\x29", paren_error_minus_dict
        .long -8

        $CONSTANT 139, "\x28\x65\x72\x72\x6f\x72\x2d\x6d\x65\x6d\x29", paren_error_minus_mem
        .long -9

        $CONSTANT 139, "\x28\x65\x72\x72\x6f\x72\x2d\x64\x69\x76\x29", paren_error_minus_div
        .long -10

        $CONSTANT 141, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x61\x6e\x67\x65\x29", paren_error_minus_range
        .long -11

        $CONSTANT 140, "\x28\x65\x72\x72\x6f\x72\x2d\x74\x79\x70\x65\x29", paren_error_minus_type
        .long -12

        $CONSTANT 141, "\x28\x65\x72\x72\x6f\x72\x2d\x75\x6e\x64\x65\x66\x29", paren_error_minus_undef
        .long -13

        $CONSTANT 148, "\x28\x65\x72\x72\x6f\x72\x2d\x63\x6f\x6d\x70\x69\x6c\x65\x2d\x6f\x6e\x6c\x79\x29", paren_error_minus_compile_minus_only
        .long -14

        $CONSTANT 142, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x6f\x72\x67\x65\x74\x29", paren_error_minus_forget
        .long -15

        $CONSTANT 143, "\x28\x65\x72\x72\x6f\x72\x2d\x6e\x6f\x2d\x6e\x61\x6d\x65\x29", paren_error_minus_no_minus_name
        .long -16

        $CONSTANT 141, "\x28\x65\x72\x72\x6f\x72\x2d\x6e\x75\x6d\x2d\x6f\x29", paren_error_minus_num_minus_o
        .long -17

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x73\x74\x72\x69\x6e\x67\x2d\x6f\x29", paren_error_minus_string_minus_o
        .long -18

        $CONSTANT 141, "\x28\x65\x72\x72\x6f\x72\x2d\x64\x65\x66\x2d\x6f\x29", paren_error_minus_def_minus_o
        .long -19

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x61\x64\x2d\x6f\x6e\x6c\x79\x29", paren_error_minus_read_minus_only
        .long -20

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x75\x6e\x73\x75\x70\x70\x6f\x72\x74\x65\x64\x29", paren_error_minus_unsupported
        .long -21

        $CONSTANT 143, "\x28\x65\x72\x72\x6f\x72\x2d\x63\x6f\x6e\x74\x72\x6f\x6c\x29", paren_error_minus_control
        .long -22

        $CONSTANT 141, "\x28\x65\x72\x72\x6f\x72\x2d\x61\x6c\x69\x67\x6e\x29", paren_error_minus_align
        .long -23

        $CONSTANT 139, "\x28\x65\x72\x72\x6f\x72\x2d\x6e\x75\x6d\x29", paren_error_minus_num
        .long -24

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x74\x75\x72\x6e\x2d\x69\x29", paren_error_minus_return_minus_i
        .long -25

        $CONSTANT 142, "\x28\x65\x72\x72\x6f\x72\x2d\x6c\x6f\x6f\x70\x2d\x75\x29", paren_error_minus_loop_minus_u
        .long -26

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x63\x75\x72\x73\x69\x6f\x6e\x29", paren_error_minus_recursion
        .long -27

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x69\x6e\x74\x65\x72\x72\x75\x70\x74\x29", paren_error_minus_interrupt
        .long -28

        $CONSTANT 143, "\x28\x65\x72\x72\x6f\x72\x2d\x6e\x65\x73\x74\x69\x6e\x67\x29", paren_error_minus_nesting
        .long -29

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x6f\x62\x73\x6f\x6c\x65\x74\x65\x29", paren_error_minus_obsolete
        .long -30

        $CONSTANT 140, "\x28\x65\x72\x72\x6f\x72\x2d\x62\x6f\x64\x79\x29", paren_error_minus_body
        .long -31

        $CONSTANT 142, "\x28\x65\x72\x72\x6f\x72\x2d\x6e\x61\x6d\x65\x2d\x61\x29", paren_error_minus_name_minus_a
        .long -32

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x62\x6c\x6b\x2d\x72\x65\x61\x64\x29", paren_error_minus_blk_minus_read
        .long -33

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x62\x6c\x6b\x2d\x77\x72\x69\x74\x65\x29", paren_error_minus_blk_minus_write
        .long -34

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x62\x6c\x6b\x2d\x69\x6e\x76\x61\x6c\x69\x64\x29", paren_error_minus_blk_minus_invalid
        .long -35

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x69\x6c\x65\x2d\x70\x6f\x73\x29", paren_error_minus_file_minus_pos
        .long -36

        $CONSTANT 143, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x69\x6c\x65\x2d\x69\x6f\x29", paren_error_minus_file_minus_io
        .long -37

        $CONSTANT 150, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x69\x6c\x65\x2d\x6e\x6f\x74\x2d\x66\x6f\x75\x6e\x64\x29", paren_error_minus_file_minus_not_minus_found
        .long -38

        $CONSTANT 139, "\x28\x65\x72\x72\x6f\x72\x2d\x65\x6f\x66\x29", paren_error_minus_eof
        .long -39

        $CONSTANT 140, "\x28\x65\x72\x72\x6f\x72\x2d\x62\x61\x73\x65\x29", paren_error_minus_base
        .long -40

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x70\x72\x65\x63\x69\x73\x69\x6f\x6e\x29", paren_error_minus_precision
        .long -41

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x6c\x6f\x61\x74\x2d\x64\x69\x76\x29", paren_error_minus_float_minus_div
        .long -42

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x6c\x6f\x61\x74\x2d\x72\x61\x6e\x67\x65\x29", paren_error_minus_float_minus_range
        .long -43

        $CONSTANT 149, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x6c\x6f\x61\x74\x2d\x73\x74\x61\x63\x6b\x2d\x6f\x29", paren_error_minus_float_minus_stack_minus_o
        .long -44

        $CONSTANT 149, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x6c\x6f\x61\x74\x2d\x73\x74\x61\x63\x6b\x2d\x75\x29", paren_error_minus_float_minus_stack_minus_u
        .long -45

        $CONSTANT 149, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x6c\x6f\x61\x74\x2d\x69\x6e\x76\x61\x6c\x69\x64\x29", paren_error_minus_float_minus_invalid
        .long -46

        $CONSTANT 143, "\x28\x65\x72\x72\x6f\x72\x2d\x64\x65\x6c\x65\x74\x65\x64\x29", paren_error_minus_deleted
        .long -47

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x70\x6f\x73\x74\x70\x6f\x6e\x65\x29", paren_error_minus_postpone
        .long -48

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x73\x65\x61\x72\x63\x68\x2d\x6f\x29", paren_error_minus_search_minus_o
        .long -49

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x73\x65\x61\x72\x63\x68\x2d\x75\x29", paren_error_minus_search_minus_u
        .long -50

        $CONSTANT 143, "\x28\x65\x72\x72\x6f\x72\x2d\x63\x68\x61\x6e\x67\x65\x64\x29", paren_error_minus_changed
        .long -51

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x63\x6f\x6e\x74\x72\x6f\x6c\x2d\x6f\x29", paren_error_minus_control_minus_o
        .long -52

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x65\x78\x63\x65\x70\x74\x69\x6f\x6e\x2d\x6f\x29", paren_error_minus_exception_minus_o
        .long -53

        $CONSTANT 143, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x6c\x6f\x61\x74\x2d\x6f\x29", paren_error_minus_float_minus_o
        .long -54

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x6c\x6f\x61\x74\x2d\x66\x61\x75\x6c\x74\x29", paren_error_minus_float_minus_fault
        .long -55

        $CONSTANT 140, "\x28\x65\x72\x72\x6f\x72\x2d\x71\x75\x69\x74\x29", paren_error_minus_quit
        .long -56

        $CONSTANT 140, "\x28\x65\x72\x72\x6f\x72\x2d\x63\x68\x61\x72\x29", paren_error_minus_char
        .long -57

        $CONSTANT 139, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x70\x70\x29", paren_error_minus_fpp
        .long -58

        $CONSTANT 144, "\x28\x65\x72\x72\x6f\x72\x2d\x61\x6c\x6c\x6f\x63\x61\x74\x65\x29", paren_error_minus_allocate
        .long -59

        $CONSTANT 140, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x72\x65\x65\x29", paren_error_minus_free
        .long -60

        $CONSTANT 142, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x73\x69\x7a\x65\x29", paren_error_minus_resize
        .long -61

        $CONSTANT 146, "\x28\x65\x72\x72\x6f\x72\x2d\x63\x6c\x6f\x73\x65\x2d\x66\x69\x6c\x65\x29", paren_error_minus_close_minus_file
        .long -62

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x63\x72\x65\x61\x74\x65\x2d\x66\x69\x6c\x65\x29", paren_error_minus_create_minus_file
        .long -63

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x64\x65\x6c\x65\x74\x65\x2d\x66\x69\x6c\x65\x29", paren_error_minus_delete_minus_file
        .long -64

        $CONSTANT 149, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x69\x6c\x65\x2d\x70\x6f\x73\x69\x74\x69\x6f\x6e\x29", paren_error_minus_file_minus_position
        .long -65

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x69\x6c\x65\x2d\x73\x69\x7a\x65\x29", paren_error_minus_file_minus_size
        .long -66

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x69\x6c\x65\x2d\x73\x74\x61\x74\x75\x73\x29", paren_error_minus_file_minus_status
        .long -67

        $CONSTANT 146, "\x28\x65\x72\x72\x6f\x72\x2d\x66\x6c\x75\x73\x68\x2d\x66\x69\x6c\x65\x29", paren_error_minus_flush_minus_file
        .long -68

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x6f\x70\x65\x6e\x2d\x66\x69\x6c\x65\x29", paren_error_minus_open_minus_file
        .long -69

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x61\x64\x2d\x66\x69\x6c\x65\x29", paren_error_minus_read_minus_file
        .long -70

        $CONSTANT 145, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x61\x64\x2d\x6c\x69\x6e\x65\x29", paren_error_minus_read_minus_line
        .long -71

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x6e\x61\x6d\x65\x2d\x66\x69\x6c\x65\x29", paren_error_minus_rename_minus_file
        .long -72

        $CONSTANT 151, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x70\x6f\x73\x69\x74\x69\x6f\x6e\x2d\x66\x69\x6c\x65\x29", paren_error_minus_reposition_minus_file
        .long -73

        $CONSTANT 147, "\x28\x65\x72\x72\x6f\x72\x2d\x72\x65\x73\x69\x7a\x65\x2d\x66\x69\x6c\x65\x29", paren_error_minus_resize_minus_file
        .long -74

        $CONSTANT 146, "\x28\x65\x72\x72\x6f\x72\x2d\x77\x72\x69\x74\x65\x2d\x66\x69\x6c\x65\x29", paren_error_minus_write_minus_file
        .long -75

        $CONSTANT 146, "\x28\x65\x72\x72\x6f\x72\x2d\x77\x72\x69\x74\x65\x2d\x6c\x69\x6e\x65\x29", paren_error_minus_write_minus_line
        .long -76

        $CONSTANT 139, "\x28\x6c\x65\x78\x2d\x73\x74\x61\x72\x74\x29", paren_lex_minus_start
        .long 128

        $CONSTANT 143, "\x28\x6c\x65\x78\x2d\x69\x6d\x6d\x65\x64\x69\x61\x74\x65\x29", paren_lex_minus_immediate
        .long 64

        $CONSTANT 146, "\x28\x6c\x65\x78\x2d\x63\x6f\x6d\x70\x69\x6c\x65\x2d\x6f\x6e\x6c\x79\x29", paren_lex_minus_compile_minus_only
        .long 32

        $CONSTANT 142, "\x28\x6c\x65\x78\x2d\x6d\x61\x78\x2d\x6e\x61\x6d\x65\x29", paren_lex_minus_max_minus_name
        .long 31

        $CONSTANT 132, "\x74\x72\x75\x65", true
        .long -1

        $CONSTANT 133, "\x66\x61\x6c\x73\x65", false
        .long 0

        $CONSTANT 129, "\x30", zero
        .long 0

        $CONSTANT 129, "\x31", one
        .long 1

        $COLON 136, "\x67\x6d\x70\x66\x6f\x72\x74\x68", gmpforth
        .long paren_s_quote
        .byte  17
        .ascii "\x6d\x69\x70\x73\x2f\x33\x32\x20\x47\x4d\x50\x20\x46\x6f\x72\x74\x68"
        $ALIGN
        .long type
        .long exit

        $COLON 139, "\x28\x69\x6e\x74\x65\x72\x70\x72\x65\x74\x29", paren_interpret
        .long query
        .long paren_evaluate
        .long exit

        $COLON 137, "\x28\x72\x65\x73\x70\x6f\x6e\x64\x29", paren_respond
        .long question_dup
        .long paren_zero_branch
        .long paren_respond_33
        .long dup
        .long paren_error_minus_abort
        .long less_greater
        .long paren_abort_quote_dollar
        .long fetch
        .long and
        .long paren_zero_branch
        .long paren_respond_15
        .long paren_abort_quote_dollar
        .long fetch
        .long count
        .long type
paren_respond_15:
        .long dup
        .long paren_error_minus_abort_quote
        .long zero
        .long within
        .long paren_zero_branch
        .long paren_respond_24
        .long drop
        .long paren_branch
        .long paren_respond_28
paren_respond_24:
        .long paren_s_quote
        .byte  2
        .ascii "\x65\x72"
        $ALIGN
        .long type
        .long dot
paren_respond_28:
        .long zero
        .long paren_abort_quote_dollar
        .long store
        .long paren_branch
        .long paren_respond_41
paren_respond_33:
        .long state
        .long fetch
        .long zero_equals
        .long paren_zero_branch
        .long paren_respond_41
        .long paren_s_quote
        .byte  3
        .ascii "\x20\x6f\x6b"
        $ALIGN
        .long type
paren_respond_41:
        .long exit

        $COLON 135, "\x28\x65\x72\x72\x6f\x72\x29", paren_error
        .long paren_abort_quote_dollar
        .long fetch
        .long zero_equals
        .long and
        .long paren_zero_branch
        .long paren_error_50
        .long source
        .long drop
        .long greater_in_minus
        .long fetch
        .long greater_in
        .long fetch
        .long over
        .long minus
        .long greater_r
        .long plus
        .long r_fetch
        .long two_dup
        .long plus
        .long one_minus
        .long c_fetch
        .long bl
        .long equals
        .long paren_zero_branch
        .long paren_error_26
        .long one_minus
paren_error_26:
        .long here
        .long c_store
        .long here
        .long one_plus
        .long r_greater
        .long cmove
        .long paren_s_quote
        .byte  3
        .ascii "\x20\x3f\x20"
        $ALIGN
        .long dup
        .long greater_r
        .long here
        .long count
        .long plus
        .long swap
        .long cmove
        .long here
        .long c_fetch
        .long r_greater
        .long plus
        .long here
        .long c_store
        .long here
        .long paren_abort_quote_dollar
        .long store
paren_error_50:
        .long exit

        $COLON 134, "\x28\x71\x75\x69\x74\x29", paren_quit
        .long paren_reset
        .long cr
        .long paren_dolit
        .long paren_interpret
        .long catch
        .long dup
        .long paren_error
        .long dup
        .long paren_respond
        .long paren_zero_branch
        .long paren_quit_17
        .long paren_sp_zero
        .long fetch
        .long sp_store
        .long paren_dolit
        .long left_bracket
        .long execute
paren_quit_17:
        .long exit

        $COLON 134, "\x28\x75\x74\x78\x21\x29", paren_utx_store
        .long paren_dolit
        .long -4
        .long paren_io
        .long exit

        $COLON 134, "\x28\x75\x74\x78\x3f\x29", paren_utx_question
        .long paren_dolit
        .long -5
        .long paren_io
        .long exit

        $COLON 134, "\x28\x75\x72\x78\x40\x29", paren_urx_fetch
        .long paren_dolit
        .long -6
        .long paren_io
        .long exit

        $COLON 134, "\x28\x75\x72\x78\x3f\x29", paren_urx_question
        .long paren_dolit
        .long -7
        .long paren_io
        .long exit

        $COLON 135, "\x28\x72\x65\x73\x65\x74\x29", paren_reset
        .long true
        .long dpl
        .long store
        .long tib
        .long fetch
        .long paren_scratch
        .long fetch
        .long two_dup
        .long zero
        .long paren_dolit
        .long 0
        .long paren_dolit
        .long 0
        .long two_dup
        .long paren_number_i
        .long restore_minus_input
        .long throw
        .long exit

        $COLON 134, "\x75\x64\x2f\x6d\x6f\x64", ud_slash_mod
        .long greater_r
        .long zero
        .long r_fetch
        .long um_slash_mod
        .long r_greater
        .long swap
        .long greater_r
        .long um_slash_mod
        .long r_greater
        .long exit

        $COLON 131, "\x75\x74\x2a", ut_star
        .long dup
        .long rot
        .long um_star
        .long two_greater_r
        .long um_star
        .long zero
        .long two_r_greater
        .long d_plus
        .long exit

        $COLON 134, "\x75\x74\x2f\x6d\x6f\x64", ut_slash_mod
        .long greater_r
        .long zero
        .long r_fetch
        .long um_slash_mod
        .long minus_rot
        .long r_fetch
        .long um_slash_mod
        .long rot
        .long two_swap
        .long r_greater
        .long um_slash_mod
        .long two_swap
        .long exit

        $COLON 132, "\x64\x61\x62\x73", dabs
        .long dup
        .long d_plus_minus
        .long exit

        $COLON 129, "\x23", number
        .long base
        .long fetch
        .long ud_slash_mod
        .long rot
        .long paren_dolit
        .long 9
        .long over
        .long less
        .long paren_zero_branch
        .long number_13
        .long paren_dolit
        .long 7
        .long plus
number_13:
        .long paren_dolit
        .long 48
        .long plus
        .long hold
        .long exit

        $COLON 130, "\x23\x3e", number_greater
        .long two_drop
        .long paren_hld
        .long fetch
        .long pad
        .long over
        .long minus
        .long exit

        $COLON 130, "\x23\x73", number_s
number_s_0:
        .long number
        .long two_dup
        .long or
        .long zero_equals
        .long paren_zero_branch
        .long number_s_0
        .long exit

        $COLON 129, "\x27", tick
        .long parse_minus_name
        .long paren_find
        .long zero_equals
        .long paren_zero_branch
        .long tick_7
        .long paren_error_minus_undef
        .long throw
tick_7:
        .long exit

        $COLON 193, "\x28", paren
        .long paren_dolit
        .long 41
        .long parse
        .long two_drop
        .long exit

        $COLON 130, "\x2b\x21", plus_store
        .long dup
        .long fetch
        .long rot
        .long plus
        .long swap
        .long store
        .long exit

        $COLON 229, "\x2b\x6c\x6f\x6f\x70", plus_loop
        .long paren_dolit
        .long paren_plus_loop
        .long compile_comma
        .long dup
        .long cell_plus
        .long comma
        .long paren_dolit
        .long then
        .long execute
        .long exit

        $COLON 129, "\x2c", comma
        .long here
        .long store
        .long one
        .long cells
        .long allot
        .long exit

        $COLON 129, "\x2e", dot
        .long dup
        .long greater_r
        .long abs
        .long zero
        .long less_number
        .long number_s
        .long r_greater
        .long sign
        .long number_greater
        .long type
        .long space
        .long exit

        $COLON 194, "\x2e\x22", dot_quote
        .long state
        .long fetch
        .long paren_zero_branch
        .long dot_quote_16
        .long paren_dolit
        .long paren_s_quote
        .long compile_comma
        .long paren_dolit
        .long 34
        .long parse
        .long paren_quote_comma
        .long paren_dolit
        .long type
        .long compile_comma
        .long paren_branch
        .long dot_quote_20
dot_quote_16:
        .long paren_dolit
        .long 34
        .long parse
        .long type
dot_quote_20:
        .long exit

        $COLON 130, "\x31\x2b", one_plus
        .long one
        .long plus
        .long exit

        $COLON 130, "\x31\x2d", one_minus
        .long one
        .long minus
        .long exit

        $COLON 130, "\x32\x21", two_store
        .long swap
        .long over
        .long store
        .long cell_plus
        .long store
        .long exit

        $COLON 130, "\x32\x40", two_fetch
        .long dup
        .long cell_plus
        .long fetch
        .long swap
        .long fetch
        .long exit

        $COLON 133, "\x32\x64\x72\x6f\x70", two_drop
        .long drop
        .long drop
        .long exit

        $COLON 132, "\x32\x64\x75\x70", two_dup
        .long over
        .long over
        .long exit

        $COLON 133, "\x32\x6f\x76\x65\x72", two_over
        .long greater_r
        .long greater_r
        .long two_dup
        .long r_greater
        .long r_greater
        .long two_swap
        .long exit

        $COLON 133, "\x32\x73\x77\x61\x70", two_swap
        .long rot
        .long greater_r
        .long rot
        .long r_greater
        .long exit

        $COLON 225, "\x3b", semis
        .long smudge
        .long paren_dolit
        .long left_bracket
        .long execute
        .long paren_dolit
        .long exit
        .long compile_comma
        .long exit

        $COLON 130, "\x3c\x23", less_number
        .long pad
        .long paren_hld
        .long store
        .long exit

        $COLON 129, "\x3d", equals
        .long minus
        .long zero_equals
        .long exit

        $COLON 129, "\x3e", greater
        .long swap
        .long less
        .long exit

        $COLON 133, "\x3e\x62\x6f\x64\x79", greater_body
        .long cell_plus
        .long exit

        $COLON 135, "\x74\x6f\x75\x70\x70\x65\x72", toupper
        .long dup
        .long paren_dolit
        .long 97
        .long paren_dolit
        .long 123
        .long within
        .long paren_zero_branch
        .long toupper_11
        .long paren_dolit
        .long 32
        .long minus
toupper_11:
        .long exit

        $COLON 133, "\x64\x69\x67\x69\x74", digit
        .long swap
        .long toupper
        .long paren_dolit
        .long 48
        .long minus
        .long dup
        .long zero_less
        .long zero_equals
        .long over
        .long paren_dolit
        .long 10
        .long paren_dolit
        .long 17
        .long within
        .long zero_equals
        .long and
        .long paren_zero_branch
        .long digit_39
        .long dup
        .long paren_dolit
        .long 16
        .long greater
        .long paren_zero_branch
        .long digit_27
        .long paren_dolit
        .long 7
        .long minus
digit_27:
        .long dup
        .long rot
        .long less
        .long paren_zero_branch
        .long digit_35
        .long true
        .long paren_branch
        .long digit_37
digit_35:
        .long drop
        .long false
digit_37:
        .long paren_branch
        .long digit_41
digit_39:
        .long two_drop
        .long false
digit_41:
        .long exit

        $COLON 130, "\x2b\x2d", plus_minus
        .long zero_less
        .long paren_zero_branch
        .long plus_minus_4
        .long negate
plus_minus_4:
        .long exit

        $COLON 131, "\x64\x2b\x2d", d_plus_minus
        .long zero_less
        .long paren_zero_branch
        .long d_plus_minus_4
        .long dnegate
d_plus_minus_4:
        .long exit

        $COLON 135, "\x3e\x6e\x75\x6d\x62\x65\x72", greater_number
        .long dup
        .long zero
        .long paren_question_do
        .long greater_number_31
greater_number_4:
        .long over
        .long c_fetch
        .long base
        .long fetch
        .long digit
        .long zero_equals
        .long paren_zero_branch
        .long greater_number_13
        .long paren_leave
greater_number_13:
        .long greater_r
        .long two_swap
        .long base
        .long fetch
        .long um_star
        .long drop
        .long r_greater
        .long swap
        .long rot
        .long base
        .long fetch
        .long um_star
        .long d_plus
        .long two_swap
        .long one
        .long slash_string
        .long paren_loop
        .long greater_number_4
greater_number_31:
        .long exit

        $COLON 132, "\x3f\x64\x75\x70", question_dup
        .long dup
        .long paren_zero_branch
        .long question_dup_4
        .long dup
question_dup_4:
        .long exit

        $COLON 133, "\x61\x62\x6f\x72\x74", abort
        .long paren_error_minus_abort
        .long throw
        .long exit

        $COLON 168, "\x28\x61\x62\x6f\x72\x74\x22\x29", paren_abort_quote
        .long rot
        .long paren_zero_branch
        .long paren_abort_quote_11
        .long drop
        .long one_minus
        .long paren_abort_quote_dollar
        .long store
        .long paren_error_minus_abort_quote
        .long throw
        .long paren_branch
        .long paren_abort_quote_12
paren_abort_quote_11:
        .long two_drop
paren_abort_quote_12:
        .long exit

        $COLON 230, "\x61\x62\x6f\x72\x74\x22", abort_quote
        .long paren_dolit
        .long 34
        .long parse
        .long paren_dolit
        .long paren_s_quote
        .long compile_comma
        .long paren_quote_comma
        .long paren_dolit
        .long paren_abort_quote
        .long compile_comma
        .long exit

        $COLON 131, "\x61\x62\x73", abs
        .long dup
        .long plus_minus
        .long exit

        $COLON 134, "\x61\x63\x63\x65\x70\x74", accept
        .long dup
        .long greater_r
accept_2:
        .long key
        .long dup
        .long paren_equals_cr
        .long less_greater
        .long paren_zero_branch
        .long accept_53
        .long dup
        .long paren_equals_bs
        .long equals
        .long over
        .long paren_equals_rub
        .long equals
        .long or
        .long paren_zero_branch
        .long accept_34
        .long drop
        .long dup
        .long zero
        .long r_fetch
        .long within
        .long paren_zero_branch
        .long accept_32
        .long paren_dolit
        .long -1
        .long slash_string
        .long paren_equals_bs
        .long emit
        .long space
        .long paren_equals_bs
        .long emit
accept_32:
        .long paren_branch
        .long accept_51
accept_34:
        .long over
        .long zero
        .long greater
        .long paren_zero_branch
        .long accept_50
        .long dup
        .long emit
        .long greater_r
        .long over
        .long r_greater
        .long swap
        .long c_store
        .long one
        .long slash_string
        .long paren_branch
        .long accept_51
accept_50:
        .long drop
accept_51:
        .long paren_branch
        .long accept_2
accept_53:
        .long space
        .long drop
        .long swap
        .long drop
        .long r_greater
        .long swap
        .long minus
        .long exit

        $COLON 133, "\x3e\x6d\x61\x72\x6b", greater_mark
        .long here
        .long zero
        .long comma
        .long exit

        $COLON 136, "\x3e\x72\x65\x73\x6f\x6c\x76\x65", greater_resolve
        .long here
        .long swap
        .long store
        .long exit

        $COLON 133, "\x3c\x6d\x61\x72\x6b", less_mark
        .long here
        .long exit

        $COLON 136, "\x3c\x72\x65\x73\x6f\x6c\x76\x65", less_resolve
        .long comma
        .long exit

        $COLON 229, "\x61\x68\x65\x61\x64", ahead
        .long paren_dolit
        .long paren_branch
        .long compile_comma
        .long greater_mark
        .long exit

        $COLON 133, "\x61\x6c\x69\x67\x6e", align
        .long here
        .long aligned
        .long here
        .long minus
        .long allot
        .long exit

        $COLON 135, "\x61\x6c\x69\x67\x6e\x65\x64", aligned
        .long dup
        .long paren_cell
        .long one_minus
        .long and
        .long question_dup
        .long paren_zero_branch
        .long aligned_10
        .long minus
        .long paren_cell
        .long plus
aligned_10:
        .long exit

        $COLON 133, "\x61\x6c\x6c\x6f\x74", allot
        .long paren_here
        .long plus_store
        .long exit

        $COLON 229, "\x62\x65\x67\x69\x6e", begin
        .long less_mark
        .long exit

        $COLON 130, "\x63\x2c", c_comma
        .long here
        .long c_store
        .long one
        .long allot
        .long exit

        $COLON 133, "\x63\x65\x6c\x6c\x2b", cell_plus
        .long paren_cell
        .long plus
        .long exit

        $COLON 133, "\x63\x65\x6c\x6c\x2d", cell_minus
        .long paren_cell
        .long minus
        .long exit

        $COLON 133, "\x63\x65\x6c\x6c\x73", cells
        .long paren_cell
        .long star
        .long exit

        $COLON 132, "\x63\x68\x61\x72", char
        .long bl
        .long parse
        .long drop
        .long c_fetch
        .long exit

        $COLON 133, "\x63\x68\x61\x72\x2b", char_plus
        .long one
        .long plus
        .long exit

        $COLON 197, "\x63\x68\x61\x72\x73", chars
        .long exit

        $COLON 133, "\x63\x6f\x75\x6e\x74", count
        .long dup
        .long char_plus
        .long swap
        .long c_fetch
        .long exit

        $COLON 130, "\x63\x72", cr
        .long paren_equals_cr
        .long emit
        .long paren_equals_lf
        .long emit
        .long exit

        $COLON 135, "\x28\x3f\x6e\x61\x6d\x65\x29", paren_question_name
        .long question_dup
        .long zero_equals
        .long paren_zero_branch
        .long paren_question_name_6
        .long paren_error_minus_no_minus_name
        .long throw
paren_question_name_6:
        .long dup
        .long paren_lex_minus_max_minus_name
        .long greater
        .long paren_zero_branch
        .long paren_question_name_13
        .long paren_error_minus_def_minus_o
        .long throw
paren_question_name_13:
        .long exit

        $COLON 136, "\x28\x63\x72\x65\x61\x74\x65\x29", paren_create
        .long align
        .long here
        .long current
        .long fetch
        .long dup
        .long fetch
        .long comma
        .long store
        .long paren_quote_comma
        .long smudge
        .long zero
        .long comma
        .long exit

        $COLON 135, "\x64\x65\x63\x69\x6d\x61\x6c", decimal
        .long paren_dolit
        .long 10
        .long base
        .long store
        .long exit

        $COLON 131, "\x68\x65\x78", hex
        .long paren_dolit
        .long 16
        .long base
        .long store
        .long exit

        $COLON 135, "\x64\x6e\x65\x67\x61\x74\x65", dnegate
        .long paren_dolit
        .long 0
        .long paren_dolit
        .long 0
        .long two_swap
        .long d_minus
        .long exit

        $COLON 226, "\x64\x6f", do
        .long paren_dolit
        .long paren_do
        .long compile_comma
        .long greater_mark
        .long exit

        $COLON 133, "\x6e\x61\x6d\x65\x3e", name_greater
        .long count
        .long paren_lex_minus_max_minus_name
        .long and
        .long plus
        .long aligned
        .long exit

        $COLON 229, "\x64\x6f\x65\x73\x3e", does_greater
        .long paren_dolit
        .long paren_semis_code
        .long compile_comma
        .long paren_does_comma
        .long exit

        $COLON 228, "\x65\x6c\x73\x65", else
        .long paren_dolit
        .long ahead
        .long execute
        .long swap
        .long paren_dolit
        .long then
        .long execute
        .long exit

        $COLON 132, "\x65\x6d\x69\x74", emit
        .long paren_tx_store
        .long fetch
        .long execute
        .long exit

        $COLON 140, "\x65\x6e\x76\x69\x72\x6f\x6e\x6d\x65\x6e\x74\x3f", environment_question
        .long two_drop
        .long false
        .long exit

        $COLON 134, "\x28\x28\x73\x22\x29\x29", paren_paren_s_quote
        .long state
        .long fetch
        .long paren_zero_branch
        .long paren_paren_s_quote_10
        .long paren_dolit
        .long paren_s_quote
        .long compile_comma
        .long paren_quote_comma
        .long paren_branch
        .long paren_paren_s_quote_22
paren_paren_s_quote_10:
        .long paren_scratch
        .long fetch
        .long greater_in
        .long fetch
        .long plus
        .long over
        .long minus
        .long swap
        .long two_dup
        .long two_greater_r
        .long cmove
        .long two_r_greater
paren_paren_s_quote_22:
        .long exit

        $COLON 139, "\x28\x24\x65\x76\x61\x6c\x75\x61\x74\x65\x29", paren_dollar_evaluate
        .long over
        .long plus
        .long two_dup
        .long paren_dolit
        .long -1
        .long paren_dolit
        .long 0
        .long paren_dolit
        .long 0
        .long two_dup
        .long paren_number_i
        .long restore_minus_input
        .long throw
        .long exit

        $COLON 166, "\x28\x77\x6f\x72\x64\x29", paren_word
        .long dup
        .long paren_lex_minus_compile_minus_only
        .long and
        .long state
        .long fetch
        .long zero_equals
        .long and
        .long paren_zero_branch
        .long paren_word_13
        .long drop
        .long paren_error_minus_compile_minus_only
        .long paren_branch
        .long paren_word_26
paren_word_13:
        .long paren_lex_minus_immediate
        .long and
        .long zero_equals
        .long state
        .long fetch
        .long and
        .long paren_zero_branch
        .long paren_word_24
        .long compile_comma
        .long paren_branch
        .long paren_word_25
paren_word_24:
        .long execute
paren_word_25:
        .long zero
paren_word_26:
        .long exit

        $COLON 168, "\x28\x6e\x75\x6d\x62\x65\x72\x29", paren_number
        .long state
        .long fetch
        .long paren_zero_branch
        .long paren_number_18
        .long paren_dolit
        .long 2
        .long equals
        .long paren_zero_branch
        .long paren_number_13
        .long swap
        .long paren_dolit
        .long literal
        .long execute
paren_number_13:
        .long paren_dolit
        .long literal
        .long execute
        .long paren_branch
        .long paren_number_19
paren_number_18:
        .long drop
paren_number_19:
        .long zero
        .long exit

        $COLON 137, "\x28\x6e\x75\x6d\x62\x65\x72\x3f\x29", paren_number_question
        .long over
        .long c_fetch
        .long paren_dolit
        .long 45
        .long equals
        .long dup
        .long greater_r
        .long minus_rot
        .long r_greater
        .long paren_zero_branch
        .long paren_number_question_21
        .long one
        .long slash_string
        .long dup
        .long zero_equals
        .long paren_zero_branch
        .long paren_number_question_21
        .long two_drop
        .long drop
        .long zero
        .long exit
paren_number_question_21:
        .long paren_dolit
        .long 0
        .long paren_dolit
        .long 0
        .long two_swap
        .long greater_number
        .long question_dup
        .long paren_zero_branch
        .long paren_number_question_67
        .long over
        .long c_fetch
        .long paren_dolit
        .long 46
        .long equals
        .long paren_zero_branch
        .long paren_number_question_60
        .long one
        .long slash_string
        .long dup
        .long greater_r
        .long greater_number
        .long paren_zero_branch
        .long paren_number_question_52
        .long r_greater
        .long drop
        .long two_drop
        .long two_drop
        .long zero
        .long exit
        .long paren_branch
        .long paren_number_question_57
paren_number_question_52:
        .long drop
        .long rot
        .long d_plus_minus
        .long paren_dolit
        .long 2
paren_number_question_57:
        .long r_greater
        .long paren_branch
        .long paren_number_question_65
paren_number_question_60:
        .long two_drop
        .long two_drop
        .long drop
        .long zero
        .long exit
paren_number_question_65:
        .long paren_branch
        .long paren_number_question_72
paren_number_question_67:
        .long two_drop
        .long swap
        .long plus_minus
        .long one
        .long true
paren_number_question_72:
        .long dpl
        .long store
        .long exit

        $COLON 135, "\x6e\x75\x6d\x62\x65\x72\x3f", number_question
        .long base
        .long fetch
        .long greater_r
        .long two_dup
        .long paren_dolit
        .long 3
        .long equals
        .long swap
        .long dup
        .long c_fetch
        .long paren_dolit
        .long 39
        .long equals
        .long swap
        .long one_plus
        .long one_plus
        .long c_fetch
        .long paren_dolit
        .long 39
        .long equals
        .long and
        .long and
        .long paren_zero_branch
        .long number_question_30
        .long r_greater
        .long two_drop
        .long one_plus
        .long c_fetch
        .long one
        .long exit
number_question_30:
        .long dup
        .long one
        .long greater
        .long paren_zero_branch
        .long number_question_83
        .long over
        .long c_fetch
        .long dup
        .long paren_dolit
        .long 35
        .long equals
        .long paren_zero_branch
        .long number_question_52
        .long drop
        .long paren_dolit
        .long 10
        .long base
        .long store
        .long one
        .long slash_string
        .long paren_branch
        .long number_question_83
number_question_52:
        .long dup
        .long paren_dolit
        .long 36
        .long equals
        .long paren_zero_branch
        .long number_question_67
        .long drop
        .long paren_dolit
        .long 16
        .long base
        .long store
        .long one
        .long slash_string
        .long paren_branch
        .long number_question_83
number_question_67:
        .long dup
        .long paren_dolit
        .long 37
        .long equals
        .long paren_zero_branch
        .long number_question_82
        .long drop
        .long paren_dolit
        .long 2
        .long base
        .long store
        .long one
        .long slash_string
        .long paren_branch
        .long number_question_83
number_question_82:
        .long drop
number_question_83:
        .long paren_number_question
        .long r_greater
        .long base
        .long store
        .long exit

        $COLON 138, "\x28\x65\x76\x61\x6c\x75\x61\x74\x65\x29", paren_evaluate
paren_evaluate_0:
        .long parse_minus_name
        .long question_dup
        .long paren_zero_branch
        .long paren_evaluate_22
        .long paren_find
        .long question_dup
        .long paren_zero_branch
        .long paren_evaluate_11
        .long paren_word
        .long paren_branch
        .long paren_evaluate_19
paren_evaluate_11:
        .long number_question
        .long question_dup
        .long paren_zero_branch
        .long paren_evaluate_18
        .long paren_number
        .long paren_branch
        .long paren_evaluate_19
paren_evaluate_18:
        .long paren_error_minus_undef
paren_evaluate_19:
        .long throw
        .long paren_branch
        .long paren_evaluate_0
paren_evaluate_22:
        .long drop
        .long question_stack
        .long exit

        $COLON 140, "\x28\x28\x65\x76\x61\x6c\x75\x61\x74\x65\x29\x29", paren_paren_evaluate
        .long save_minus_input
        .long n_greater_r
        .long catch
        .long dup
        .long zero_equals
        .long paren_zero_branch
        .long paren_paren_evaluate_13
        .long drop
        .long paren_dolit
        .long paren_evaluate
        .long catch
        .long dup
        .long paren_error
paren_paren_evaluate_13:
        .long nr_greater
        .long restore_minus_input
        .long paren_zero_branch
        .long paren_paren_evaluate_18
        .long paren_error_minus_reposition_minus_file
paren_paren_evaluate_18:
        .long throw
        .long exit

        $COLON 136, "\x65\x76\x61\x6c\x75\x61\x74\x65", evaluate
        .long paren_dolit
        .long paren_dollar_evaluate
        .long paren_paren_evaluate
        .long exit

        $COLON 132, "\x66\x69\x6c\x6c", fill
        .long minus_rot
        .long zero
        .long paren_question_do
        .long fill_10
fill_4:
        .long two_dup
        .long i
        .long plus
        .long c_store
        .long paren_loop
        .long fill_4
fill_10:
        .long two_drop
        .long exit

        $COLON 132, "\x68\x65\x72\x65", here
        .long paren_here
        .long fetch
        .long exit

        $COLON 132, "\x68\x6f\x6c\x64", hold
        .long paren_dolit
        .long -1
        .long paren_hld
        .long plus_store
        .long paren_hld
        .long fetch
        .long here
        .long u_less
        .long paren_zero_branch
        .long hold_12
        .long paren_error_minus_num_minus_o
        .long throw
hold_12:
        .long paren_hld
        .long fetch
        .long c_store
        .long exit

        $COLON 226, "\x69\x66", if
        .long paren_dolit
        .long paren_zero_branch
        .long compile_comma
        .long greater_mark
        .long exit

        $COLON 132, "\x63\x73\x65\x74", cset
        .long dup
        .long greater_r
        .long c_fetch
        .long or
        .long r_greater
        .long c_store
        .long exit

        $COLON 134, "\x63\x72\x65\x73\x65\x74", creset
        .long dup
        .long greater_r
        .long c_fetch
        .long swap
        .long invert
        .long and
        .long r_greater
        .long c_store
        .long exit

        $COLON 135, "\x63\x74\x6f\x67\x67\x6c\x65", ctoggle
        .long dup
        .long greater_r
        .long c_fetch
        .long xor
        .long r_greater
        .long c_store
        .long exit

        $COLON 134, "\x73\x6d\x75\x64\x67\x65", smudge
        .long paren_lex_minus_start
        .long latest
        .long ctoggle
        .long exit

        $COLON 137, "\x69\x6d\x6d\x65\x64\x69\x61\x74\x65", immediate
        .long paren_lex_minus_immediate
        .long latest
        .long cset
        .long exit

        $COLON 140, "\x63\x6f\x6d\x70\x69\x6c\x65\x2d\x6f\x6e\x6c\x79", compile_minus_only
        .long paren_lex_minus_compile_minus_only
        .long latest
        .long cset
        .long exit

        $COLON 131, "\x6b\x65\x79", key
        .long paren_rx_fetch
        .long fetch
        .long execute
        .long exit

        $COLON 229, "\x6c\x65\x61\x76\x65", leave
        .long paren_dolit
        .long paren_leave
        .long compile_comma
        .long exit

        $COLON 230, "\x3f\x6c\x65\x61\x76\x65", question_leave
        .long paren_dolit
        .long if
        .long execute
        .long paren_dolit
        .long leave
        .long execute
        .long paren_dolit
        .long then
        .long execute
        .long exit

        $COLON 231, "\x6c\x69\x74\x65\x72\x61\x6c", literal
        .long paren_dolit
        .long paren_dolit
        .long compile_comma
        .long comma
        .long exit

        $COLON 228, "\x6c\x6f\x6f\x70", loop
        .long paren_dolit
        .long paren_loop
        .long compile_comma
        .long dup
        .long cell_plus
        .long comma
        .long paren_dolit
        .long then
        .long execute
        .long exit

        $COLON 134, "\x6c\x73\x68\x69\x66\x74", lshift
        .long zero
        .long paren_question_do
        .long lshift_6
lshift_3:
        .long two_star
        .long paren_loop
        .long lshift_3
lshift_6:
        .long exit

        $COLON 131, "\x6d\x61\x78", max
        .long two_dup
        .long less
        .long paren_zero_branch
        .long max_5
        .long swap
max_5:
        .long drop
        .long exit

        $COLON 131, "\x6d\x69\x6e", min
        .long two_dup
        .long greater
        .long paren_zero_branch
        .long min_5
        .long swap
min_5:
        .long drop
        .long exit

        $COLON 134, "\x62\x6f\x75\x6e\x64\x73", bounds
        .long over
        .long plus
        .long swap
        .long exit

        $COLON 133, "\x63\x6d\x6f\x76\x65", cmove
        .long bounds
        .long paren_question_do
        .long cmove_10
cmove_3:
        .long dup
        .long c_fetch
        .long i
        .long c_store
        .long char_plus
        .long paren_loop
        .long cmove_3
cmove_10:
        .long drop
        .long exit

        $COLON 134, "\x63\x6d\x6f\x76\x65\x3e", cmove_greater
        .long one_minus
        .long dup
        .long greater_r
        .long over
        .long plus
        .long rot
        .long r_greater
        .long plus
        .long minus_rot
        .long paren_question_do
        .long cmove_greater_20
cmove_greater_11:
        .long dup
        .long c_fetch
        .long i
        .long c_store
        .long one_minus
        .long paren_dolit
        .long -1
        .long paren_plus_loop
        .long cmove_greater_11
cmove_greater_20:
        .long drop
        .long exit

        $COLON 134, "\x77\x69\x74\x68\x69\x6e", within
        .long over
        .long minus
        .long greater_r
        .long minus
        .long r_greater
        .long u_less
        .long exit

        $COLON 132, "\x6d\x6f\x76\x65", move
        .long greater_r
        .long two_dup
        .long swap
        .long dup
        .long r_fetch
        .long plus
        .long within
        .long r_greater
        .long swap
        .long paren_zero_branch
        .long move_14
        .long cmove_greater
        .long paren_branch
        .long move_15
move_14:
        .long cmove
move_15:
        .long exit

        $COLON 134, "\x6e\x65\x67\x61\x74\x65", negate
        .long zero
        .long swap
        .long minus
        .long exit

        $COLON 232, "\x70\x6f\x73\x74\x70\x6f\x6e\x65", postpone
        .long parse_minus_name
        .long paren_find
        .long question_dup
        .long zero_equals
        .long paren_zero_branch
        .long postpone_8
        .long paren_error_minus_undef
        .long throw
postpone_8:
        .long paren_lex_minus_immediate
        .long and
        .long swap
        .long paren_dolit
        .long literal
        .long execute
        .long paren_zero_branch
        .long postpone_21
        .long paren_dolit
        .long execute
        .long compile_comma
        .long paren_branch
        .long postpone_24
postpone_21:
        .long paren_dolit
        .long compile_comma
        .long compile_comma
postpone_24:
        .long exit

        $COLON 132, "\x71\x75\x69\x74", quit
        .long paren_dolit
        .long left_bracket
        .long execute
        .long paren_rp_zero
        .long fetch
        .long rp_store
quit_6:
        .long paren_dolit
        .long paren_quit
        .long catch
        .long paren_zero_branch
        .long quit_12
        .long quit
quit_12:
        .long paren_branch
        .long quit_6
        .long exit

        $COLON 231, "\x72\x65\x63\x75\x72\x73\x65", recurse
        .long latest
        .long name_greater
        .long compile_comma
        .long exit

        $COLON 230, "\x72\x65\x70\x65\x61\x74", repeat
        .long paren_dolit
        .long again
        .long execute
        .long paren_dolit
        .long then
        .long execute
        .long exit

        $COLON 134, "\x72\x73\x68\x69\x66\x74", rshift
        .long zero
        .long paren_question_do
        .long rshift_6
rshift_3:
        .long u_two_slash
        .long paren_loop
        .long rshift_3
rshift_6:
        .long exit

        $COLON 194, "\x73\x22", s_quote
        .long paren_dolit
        .long 34
        .long parse
        .long paren_paren_s_quote
        .long exit

        $COLON 131, "\x73\x3e\x64", s_greater_d
        .long dup
        .long zero_less
        .long exit

        $COLON 132, "\x73\x69\x67\x6e", sign
        .long zero_less
        .long paren_zero_branch
        .long sign_6
        .long paren_dolit
        .long 45
        .long hold
sign_6:
        .long exit

        $COLON 134, "\x73\x6f\x75\x72\x63\x65", source
        .long paren_src
        .long fetch
        .long paren_src_fetch
        .long fetch
        .long over
        .long minus
        .long exit

        $COLON 133, "\x73\x70\x61\x63\x65", space
        .long bl
        .long emit
        .long exit

        $COLON 134, "\x73\x70\x61\x63\x65\x73", spaces
        .long zero
        .long max
        .long zero
        .long paren_question_do
        .long spaces_8
spaces_5:
        .long space
        .long paren_loop
        .long spaces_5
spaces_8:
        .long exit

        $COLON 228, "\x74\x68\x65\x6e", then
        .long greater_resolve
        .long exit

        $COLON 132, "\x74\x79\x70\x65", type
        .long bounds
        .long paren_question_do
        .long type_8
type_3:
        .long i
        .long c_fetch
        .long emit
        .long paren_loop
        .long type_3
type_8:
        .long exit

        $COLON 130, "\x75\x2e", u_dot
        .long zero
        .long less_number
        .long number_s
        .long number_greater
        .long type
        .long space
        .long exit

        $COLON 229, "\x75\x6e\x74\x69\x6c", until
        .long paren_dolit
        .long paren_zero_branch
        .long compile_comma
        .long less_resolve
        .long exit

        $COLON 229, "\x77\x68\x69\x6c\x65", while
        .long paren_dolit
        .long if
        .long execute
        .long swap
        .long exit

        $COLON 225, "\x5b", left_bracket
        .long false
        .long state
        .long store
        .long exit

        $COLON 227, "\x5b\x27\x5d", bracket_tick_bracket
        .long tick
        .long paren_dolit
        .long literal
        .long execute
        .long exit

        $COLON 230, "\x5b\x63\x68\x61\x72\x5d", bracket_char_bracket
        .long parse_minus_name
        .long drop
        .long c_fetch
        .long paren_dolit
        .long literal
        .long execute
        .long exit

        $COLON 193, "\x5d", right_bracket
        .long true
        .long state
        .long store
        .long exit

        $COLON 135, "\x28\x69\x6e\x70\x75\x74\x29", paren_input
        .long source
        .long greater_in
        .long fetch
        .long two_dup
        .long swap
        .long zero
        .long swap
        .long one_plus
        .long within
        .long zero_equals
        .long paren_zero_branch
        .long paren_input_15
        .long paren_dolit
        .long -256
        .long throw
paren_input_15:
        .long slash_string
        .long bounds
        .long exit

        $COLON 134, "\x28\x73\x6b\x69\x70\x29", paren_skip
        .long paren_input
        .long paren_question_do
        .long paren_skip_15
paren_skip_3:
        .long i
        .long c_fetch
        .long bl
        .long greater
        .long paren_zero_branch
        .long paren_skip_10
        .long paren_leave
paren_skip_10:
        .long one
        .long greater_in
        .long plus_store
        .long paren_loop
        .long paren_skip_3
paren_skip_15:
        .long exit

        $COLON 138, "\x70\x61\x72\x73\x65\x2d\x6e\x61\x6d\x65", parse_minus_name
        .long paren_skip
        .long bl
        .long negate
        .long parse
        .long exit

        $COLON 133, "\x70\x61\x72\x73\x65", parse
        .long zero
        .long swap
        .long dup
        .long zero_less
        .long paren_zero_branch
        .long parse_12
        .long negate
        .long one_plus
        .long paren_dolit
        .long less
        .long paren_branch
        .long parse_14
parse_12:
        .long paren_dolit
        .long equals
parse_14:
        .long paren_input
        .long dup
        .long greater_r
        .long greater_in
        .long fetch
        .long greater_in_minus
        .long store
        .long paren_question_do
        .long parse_40
parse_23:
        .long one
        .long greater_in
        .long plus_store
        .long two_dup
        .long i
        .long c_fetch
        .long minus_rot
        .long execute
        .long paren_zero_branch
        .long parse_34
        .long paren_leave
parse_34:
        .long rot
        .long one_plus
        .long rot
        .long rot
        .long paren_loop
        .long parse_23
parse_40:
        .long two_drop
        .long r_greater
        .long swap
        .long exit

        $COLON 131, "\x70\x61\x64", pad
        .long here
        .long paren_pad
        .long plus
        .long exit

        $COLON 229, "\x61\x67\x61\x69\x6e", again
        .long paren_dolit
        .long paren_branch
        .long compile_comma
        .long less_resolve
        .long exit

        $COLON 227, "\x3f\x64\x6f", question_do
        .long paren_dolit
        .long paren_question_do
        .long compile_comma
        .long greater_mark
        .long exit

        $COLON 131, "\x73\x67\x6e", sgn
        .long dup
        .long zero_less
        .long paren_zero_branch
        .long sgn_9
        .long drop
        .long paren_dolit
        .long -1
        .long paren_branch
        .long sgn_15
sgn_9:
        .long dup
        .long zero_less_greater
        .long paren_zero_branch
        .long sgn_15
        .long drop
        .long one
sgn_15:
        .long exit

        $COLON 139, "\x63\x61\x73\x65\x63\x6f\x6d\x70\x61\x72\x65", casecompare
        .long two_swap
        .long rot
        .long two_dup
        .long minus
        .long greater_r
        .long min
        .long zero
        .long dup
        .long minus_rot
        .long paren_question_do
        .long casecompare_30
casecompare_11:
        .long drop
        .long two_dup
        .long c_fetch
        .long toupper
        .long swap
        .long c_fetch
        .long toupper
        .long minus
        .long dup
        .long paren_zero_branch
        .long casecompare_23
        .long paren_leave
casecompare_23:
        .long rot
        .long char_plus
        .long rot
        .long char_plus
        .long rot
        .long paren_loop
        .long casecompare_11
casecompare_30:
        .long r_greater
        .long two_swap
        .long two_drop
        .long dup
        .long zero_equals
        .long paren_zero_branch
        .long casecompare_40
        .long drop
        .long paren_branch
        .long casecompare_46
casecompare_40:
        .long over
        .long zero_equals
        .long paren_zero_branch
        .long casecompare_45
        .long swap
casecompare_45:
        .long drop
casecompare_46:
        .long sgn
        .long exit

        $COLON 131, "\x30\x3c\x3e", zero_less_greater
        .long zero_equals
        .long zero_equals
        .long exit

        $COLON 130, "\x3c\x3e", less_greater
        .long equals
        .long zero_equals
        .long exit

        $COLON 135, "\x2f\x73\x74\x72\x69\x6e\x67", slash_string
        .long dup
        .long minus_rot
        .long minus
        .long minus_rot
        .long plus
        .long swap
        .long exit

        $COLON 135, "\x63\x73\x2d\x70\x69\x63\x6b", cs_minus_pick
        .long pick
        .long exit

        $COLON 135, "\x63\x73\x2d\x72\x6f\x6c\x6c", cs_minus_roll
        .long roll
        .long exit

        $COLON 134, "\x6c\x61\x74\x65\x73\x74", latest
        .long current
        .long fetch
        .long fetch
        .long l_greater_name
        .long exit

        $COLON 136, "\x63\x6f\x6d\x70\x69\x6c\x65\x2c", compile_comma
        .long comma
        .long exit

        $CONSTANT 132, "\x28\x23\x69\x29", paren_number_i
        .long 9

        $COLON 138, "\x73\x61\x76\x65\x2d\x69\x6e\x70\x75\x74", save_minus_input
        .long state
        .long paren_src_zero
        .long paren_do
        .long save_minus_input_9
save_minus_input_4:
        .long i
        .long fetch
        .long paren_cell
        .long paren_plus_loop
        .long save_minus_input_4
save_minus_input_9:
        .long paren_number_i
        .long exit

        $COLON 141, "\x72\x65\x73\x74\x6f\x72\x65\x2d\x69\x6e\x70\x75\x74", restore_minus_input
        .long dup
        .long paren_number_i
        .long equals
        .long paren_zero_branch
        .long restore_minus_input_19
        .long drop
        .long paren_src_zero
        .long greater_in
        .long paren_do
        .long restore_minus_input_16
restore_minus_input_10:
        .long i
        .long store
        .long paren_cell
        .long negate
        .long paren_plus_loop
        .long restore_minus_input_10
restore_minus_input_16:
        .long false
        .long paren_branch
        .long restore_minus_input_20
restore_minus_input_19:
        .long true
restore_minus_input_20:
        .long exit

        $COLON 134, "\x6c\x3e\x6e\x61\x6d\x65", l_greater_name
        .long cell_plus
        .long exit

        $COLON 134, "\x6e\x3e\x6c\x69\x6e\x6b", n_greater_link
        .long cell_minus
        .long exit

        $COLON 133, "\x6c\x69\x6e\x6b\x3e", link_greater
        .long l_greater_name
        .long name_greater
        .long exit

        $COLON 133, "\x3e\x6e\x61\x6d\x65", greater_name
greater_name_0:
        .long one_minus
        .long dup
        .long c_fetch
        .long paren_lex_minus_start
        .long and
        .long paren_zero_branch
        .long greater_name_0
        .long exit

        $COLON 140, "\x28\x6d\x61\x74\x63\x68\x2d\x6e\x61\x6d\x65\x29", paren_match_minus_name
        .long dup
        .long greater_r
        .long paren_zero_branch
        .long paren_match_minus_name_35
        .long r_fetch
        .long l_greater_name
        .long count
        .long dup
        .long paren_lex_minus_start
        .long and
        .long paren_zero_branch
        .long paren_match_minus_name_31
        .long paren_lex_minus_max_minus_name
        .long and
        .long two_over
        .long casecompare
        .long paren_zero_branch
        .long paren_match_minus_name_21
        .long false
        .long paren_branch
        .long paren_match_minus_name_29
paren_match_minus_name_21:
        .long two_drop
        .long r_greater
        .long dup
        .long l_greater_name
        .long c_fetch
        .long greater_r
        .long link_greater
        .long true
paren_match_minus_name_29:
        .long paren_branch
        .long paren_match_minus_name_33
paren_match_minus_name_31:
        .long two_drop
        .long false
paren_match_minus_name_33:
        .long paren_branch
        .long paren_match_minus_name_38
paren_match_minus_name_35:
        .long two_drop
        .long r_fetch
        .long zero_equals
paren_match_minus_name_38:
        .long r_greater
        .long swap
        .long exit

        $COLON 145, "\x28\x73\x65\x61\x72\x63\x68\x2d\x77\x6f\x72\x64\x6c\x69\x73\x74\x29", paren_search_minus_wordlist
paren_search_minus_wordlist_0:
        .long fetch
        .long paren_match_minus_name
        .long paren_zero_branch
        .long paren_search_minus_wordlist_0
        .long exit

        $COLON 143, "\x73\x65\x61\x72\x63\x68\x2d\x77\x6f\x72\x64\x6c\x69\x73\x74", search_minus_wordlist
        .long paren_search_minus_wordlist
        .long dup
        .long paren_zero_branch
        .long search_minus_wordlist_12
        .long paren_lex_minus_immediate
        .long and
        .long paren_zero_branch
        .long search_minus_wordlist_11
        .long one
        .long paren_branch
        .long search_minus_wordlist_12
search_minus_wordlist_11:
        .long true
search_minus_wordlist_12:
        .long exit

        $COLON 139, "\x73\x65\x74\x2d\x63\x75\x72\x72\x65\x6e\x74", set_minus_current
        .long current
        .long store
        .long exit

        $COLON 139, "\x64\x65\x66\x69\x6e\x69\x74\x69\x6f\x6e\x73", definitions
        .long context
        .long fetch
        .long set_minus_current
        .long exit

        $COLON 137, "\x73\x6f\x75\x72\x63\x65\x2d\x69\x64", source_minus_id
        .long paren_srcid
        .long fetch
        .long exit

        $COLON 134, "\x28\x66\x69\x6e\x64\x29", paren_find
        .long paren_vocs
        .long context
        .long paren_do
        .long paren_find_22
paren_find_4:
        .long i
        .long fetch
        .long paren_zero_branch
        .long paren_find_19
        .long two_dup
        .long i
        .long fetch
        .long paren_search_minus_wordlist
        .long question_dup
        .long paren_zero_branch
        .long paren_find_19
        .long two_swap
        .long two_drop
        .long unloop
        .long exit
paren_find_19:
        .long paren_cell
        .long paren_plus_loop
        .long paren_find_4
paren_find_22:
        .long false
        .long exit

        $COLON 133, "\x71\x75\x65\x72\x79", query
        .long paren_src
        .long fetch
        .long paren_srcend
        .long fetch
        .long over
        .long minus
        .long accept
        .long paren_src
        .long fetch
        .long plus
        .long paren_src_fetch
        .long store
        .long zero
        .long greater_in
        .long store
        .long zero
        .long greater_in_minus
        .long store
        .long exit

        $COLON 134, "\x72\x65\x66\x69\x6c\x6c", refill
        .long source_minus_id
        .long zero_less
        .long zero_equals
        .long dup
        .long paren_zero_branch
        .long refill_7
        .long query
refill_7:
        .long exit

        $COLON 132, "\x28\x22\x2c\x29", paren_quote_comma
        .long dup
        .long greater_r
        .long c_comma
        .long here
        .long r_fetch
        .long cmove
        .long r_greater
        .long allot
        .long here
        .long aligned
        .long here
        .long minus
        .long zero
        .long paren_question_do
        .long paren_quote_comma_19
paren_quote_comma_15:
        .long zero
        .long c_comma
        .long paren_loop
        .long paren_quote_comma_15
paren_quote_comma_19:
        .long exit

        $COLON 133, "\x74\x68\x72\x6f\x77", throw
        .long question_dup
        .long paren_zero_branch
        .long throw_14
        .long erf
        .long fetch
        .long rp_store
        .long two_r_greater
        .long minus_rot
        .long erf
        .long store
        .long greater_r
        .long sp_store
        .long drop
        .long r_greater
throw_14:
        .long exit

        $COLON 133, "\x63\x61\x74\x63\x68", catch
        .long sp_fetch
        .long erf
        .long fetch
        .long swap
        .long two_greater_r
        .long rp_fetch
        .long erf
        .long store
        .long execute
        .long two_r_greater
        .long drop
        .long erf
        .long store
        .long false
        .long exit

        $COLON 131, "\x6d\x2a\x2f", m_star_slash
        .long two_dup
        .long xor
        .long greater_r
        .long abs
        .long swap
        .long abs
        .long swap
        .long two_swap
        .long dup
        .long r_greater
        .long xor
        .long greater_r
        .long dabs
        .long two_swap
        .long greater_r
        .long ut_star
        .long r_greater
        .long ut_slash_mod
        .long drop
        .long rot
        .long drop
        .long r_greater
        .long d_plus_minus
        .long exit

        $COLON 134, "\x73\x6d\x2f\x72\x65\x6d", sm_slash_rem
        .long over
        .long greater_r
        .long two_dup
        .long xor
        .long greater_r
        .long greater_r
        .long dabs
        .long r_greater
        .long abs
        .long um_slash_mod
        .long r_greater
        .long plus_minus
        .long swap
        .long r_greater
        .long plus_minus
        .long swap
        .long exit

        $COLON 132, "\x2f\x6d\x6f\x64", slash_mod
        .long greater_r
        .long s_greater_d
        .long r_greater
        .long sm_slash_rem
        .long exit

        $COLON 129, "\x2f", slash
        .long slash_mod
        .long nip
        .long exit

        $COLON 133, "\x2a\x2f\x6d\x6f\x64", star_slash_mod
        .long greater_r
        .long m_star
        .long r_greater
        .long sm_slash_rem
        .long exit

        $COLON 130, "\x2a\x2f", star_slash
        .long star_slash_mod
        .long nip
        .long exit

        $COLON 134, "\x66\x6d\x2f\x6d\x6f\x64", fm_slash_mod
        .long dup
        .long greater_r
        .long sm_slash_rem
        .long over
        .long paren_zero_branch
        .long fm_slash_mod_17
        .long over
        .long r_fetch
        .long xor
        .long zero_less
        .long paren_zero_branch
        .long fm_slash_mod_17
        .long one_minus
        .long swap
        .long r_fetch
        .long plus
        .long swap
fm_slash_mod_17:
        .long r_greater
        .long drop
        .long exit

        $CODE 132, "\x74\x72\x61\x70", trap
                $NEXT
        $ENDCODE

        $COLON 133, "\x64\x65\x70\x74\x68", depth
        .long sp_fetch
        .long paren_sp_zero
        .long fetch
        .long swap
        .long minus
        .long paren_cell
        .long slash
        .long exit

        $COLON 131, "\x62\x79\x65", bye
        .long paren_dolit
        .long -8
        .long paren_io
        .long exit

        $COLON 193, "\x5c", backsl
        .long blk
        .long fetch
        .long paren_zero_branch
        .long backsl_16
        .long greater_in
        .long fetch
        .long paren_dolit
        .long 63
        .long and
        .long paren_dolit
        .long 64
        .long plus
        .long greater_in
        .long store
        .long paren_branch
        .long backsl_19
backsl_16:
        .long paren_equals_lf
        .long parse
        .long two_drop
backsl_19:
        .long exit

        $COLON 130, "\x6d\x2a", m_star
        .long two_dup
        .long xor
        .long greater_r
        .long abs
        .long swap
        .long abs
        .long um_star
        .long r_greater
        .long d_plus_minus
        .long exit

        $COLON 131, "\x75\x74\x2f", ut_slash
        .long dup
        .long greater_r
        .long um_slash_mod
        .long swap
        .long rot
        .long zero
        .long r_fetch
        .long um_slash_mod
        .long swap
        .long rot
        .long r_greater
        .long um_slash_mod
        .long swap
        .long drop
        .long zero
        .long two_swap
        .long swap
        .long d_plus
        .long exit

        $COLON 132, "\x75\x6d\x2a\x2f", um_star_slash
        .long greater_r
        .long ut_star
        .long r_greater
        .long ut_slash
        .long exit

        $COLON 131, "\x75\x6d\x2f", um_slash
        .long um_slash_mod
        .long swap
        .long drop
        .long exit

        $COLON 131, "\x6d\x6f\x64", mod
        .long slash_mod
        .long drop
        .long exit

        $COLON 132, "\x77\x6f\x72\x64", word
        .long parse
        .long here
        .long minus_rot
        .long paren_quote_comma
        .long exit

        $COLON 132, "\x66\x69\x6e\x64", find
        .long dup
        .long count
        .long paren_find
        .long dup
        .long paren_zero_branch
        .long find_18
        .long paren_lex_minus_immediate
        .long and
        .long paren_zero_branch
        .long find_13
        .long one
        .long paren_branch
        .long find_14
find_13:
        .long true
find_14:
        .long rot
        .long drop
        .long paren_branch
        .long find_20
find_18:
        .long minus_rot
        .long two_drop
find_20:
        .long exit

        $COLON 131, "\x64\x2e\x72", d_dot_r
        .long greater_r
        .long dup
        .long greater_r
        .long dabs
        .long less_number
        .long number_s
        .long r_greater
        .long sign
        .long number_greater
        .long r_greater
        .long over
        .long minus
        .long spaces
        .long type
        .long exit

        $COLON 130, "\x64\x2e", d_dot
        .long zero
        .long d_dot_r
        .long space
        .long exit

        $COLON 130, "\x2e\x72", dot_r
        .long greater_r
        .long s_greater_d
        .long r_greater
        .long d_dot_r
        .long exit

        $COLON 131, "\x75\x2e\x72", u_dot_r
        .long zero
        .long swap
        .long d_dot_r
        .long exit

        $COLON 194, "\x2e\x28", dot_paren
        .long paren_dolit
        .long 41
        .long parse
        .long type
        .long exit

        $COLON 135, "\x3a\x6e\x6f\x6e\x61\x6d\x65", colon_noname
        .long paren_s_quote
        .byte  0
        .ascii ""
        $ALIGN
        .long paren_create
        .long latest
        .long name_greater
        .long paren_dolit
        .long DOCOL
        .long over
        .long store
        .long paren_dolit
        .long right_bracket
        .long execute
        .long exit

        $COLON 133, "\x65\x72\x61\x73\x65", erase
        .long zero
        .long fill
        .long exit

        $COLON 131, "\x6e\x69\x70", nip
        .long swap
        .long drop
        .long exit

        $COLON 132, "\x74\x75\x63\x6b", tuck
        .long swap
        .long over
        .long exit

        $COLON 130, "\x30\x3e", zero_greater
        .long zero
        .long greater
        .long exit

        $COLON 130, "\x2e\x73", dot_s
        .long depth
        .long zero
        .long paren_question_do
        .long dot_s_12
dot_s_4:
        .long depth
        .long i
        .long minus
        .long one_minus
        .long pick
        .long dot
        .long paren_loop
        .long dot_s_4
dot_s_12:
        .long exit

        $COLON 132, "\x64\x75\x6d\x70", dump
        .long base
        .long fetch
        .long greater_r
        .long hex
        .long zero
        .long paren_question_do
        .long dump_65
dump_7:
        .long cr
        .long dup
        .long i
        .long plus
        .long paren_dolit
        .long 2
        .long cells
        .long u_dot_r
        .long space
        .long paren_dolit
        .long 16
        .long zero
        .long paren_do
        .long dump_32
dump_21:
        .long dup
        .long i
        .long j
        .long plus
        .long plus
        .long c_fetch
        .long paren_dolit
        .long 3
        .long u_dot_r
        .long paren_loop
        .long dump_21
dump_32:
        .long paren_dolit
        .long 2
        .long spaces
        .long paren_dolit
        .long 16
        .long zero
        .long paren_do
        .long dump_61
dump_40:
        .long dup
        .long i
        .long j
        .long plus
        .long plus
        .long c_fetch
        .long dup
        .long paren_dolit
        .long 32
        .long paren_dolit
        .long 127
        .long within
        .long zero_equals
        .long paren_zero_branch
        .long dump_58
        .long drop
        .long paren_dolit
        .long 46
dump_58:
        .long emit
        .long paren_loop
        .long dump_40
dump_61:
        .long paren_dolit
        .long 16
        .long paren_plus_loop
        .long dump_7
dump_65:
        .long r_greater
        .long base
        .long store
        .long drop
        .long exit

        $COLON 135, "\x28\x6e\x61\x6d\x65\x24\x29", paren_name_dollar
        .long count
        .long paren_lex_minus_max_minus_name
        .long and
        .long exit

        $COLON 133, "\x2e\x6e\x61\x6d\x65", dot_name
        .long greater_name
        .long paren_name_dollar
        .long type
        .long exit

        $COLON 133, "\x77\x6f\x72\x64\x73", words
        .long zero
        .long greater_r
        .long context
        .long fetch
words_4:
        .long question_dup
        .long paren_zero_branch
        .long words_42
        .long fetch
        .long question_dup
        .long paren_zero_branch
        .long words_42
        .long dup
        .long l_greater_name
        .long dup
        .long c_fetch
        .long paren_lex_minus_start
        .long and
        .long paren_zero_branch
        .long words_39
        .long paren_name_dollar
        .long r_greater
        .long over
        .long one_plus
        .long minus
        .long dup
        .long zero_less
        .long paren_zero_branch
        .long words_34
        .long drop
        .long cr
        .long paren_dolit
        .long 79
        .long over
        .long minus
words_34:
        .long greater_r
        .long type
        .long space
        .long paren_branch
        .long words_40
words_39:
        .long drop
words_40:
        .long paren_branch
        .long words_4
words_42:
        .long r_greater
        .long drop
        .long exit

        $COLON 129, "\x3f", question
        .long fetch
        .long dot
        .long exit

        $COLON 132, "\x63\x6f\x64\x65", code
        .long create
        .long smudge
        .long here
        .long latest
        .long name_greater
        .long store
        .long exit

        $COLON 229, "\x3b\x63\x6f\x64\x65", semis_code
        .long paren_dolit
        .long paren_semis_code
        .long compile_comma
        .long paren_dolit
        .long left_bracket
        .long execute
        .long exit

        $COLON 136, "\x65\x6e\x64\x2d\x63\x6f\x64\x65", end_minus_code
        .long smudge
        .long exit

        $COLON 133, "\x3e\x6c\x69\x6e\x6b", greater_link
        .long greater_name
        .long n_greater_link
        .long exit

        $COLON 133, "\x62\x6f\x64\x79\x3e", body_greater
        .long cell_minus
        .long exit

        $COLON 132, "\x2e\x77\x69\x64", dot_wid
        .long dup
        .long cell_plus
        .long cell_plus
        .long fetch
        .long question_dup
        .long paren_zero_branch
        .long dot_wid_12
        .long paren_name_dollar
        .long type
        .long drop
        .long paren_branch
        .long dot_wid_13
dot_wid_12:
        .long dot
dot_wid_13:
        .long exit

        $COLON 139, "\x67\x65\x74\x2d\x63\x75\x72\x72\x65\x6e\x74", get_minus_current
        .long current
        .long fetch
        .long exit

        $COLON 137, "\x73\x65\x74\x2d\x6f\x72\x64\x65\x72", set_minus_order
        .long dup
        .long cells
        .long current
        .long context
        .long minus
        .long greater
        .long paren_zero_branch
        .long set_minus_order_10
        .long paren_error_minus_search_minus_o
        .long throw
set_minus_order_10:
        .long context
        .long current
        .long over
        .long minus
        .long erase
        .long dup
        .long zero_less
        .long paren_zero_branch
        .long set_minus_order_23
        .long drop
        .long forth
        .long paren_branch
        .long set_minus_order_35
set_minus_order_23:
        .long context
        .long swap
        .long zero
        .long paren_question_do
        .long set_minus_order_34
set_minus_order_28:
        .long swap
        .long over
        .long store
        .long cell_plus
        .long paren_loop
        .long set_minus_order_28
set_minus_order_34:
        .long drop
set_minus_order_35:
        .long exit

        $COLON 137, "\x67\x65\x74\x2d\x6f\x72\x64\x65\x72", get_minus_order
        .long zero
        .long context
        .long current
        .long cell_minus
        .long paren_do
        .long get_minus_order_17
get_minus_order_6:
        .long i
        .long fetch
        .long question_dup
        .long paren_zero_branch
        .long get_minus_order_13
        .long swap
        .long one_plus
get_minus_order_13:
        .long paren_cell
        .long negate
        .long paren_plus_loop
        .long get_minus_order_6
get_minus_order_17:
        .long exit

        $COLON 132, "\x6f\x6e\x6c\x79", only
        .long paren_dolit
        .long -1
        .long set_minus_order
        .long exit

        $COLON 132, "\x61\x6c\x73\x6f", also
        .long current
        .long cell_minus
        .long fetch
        .long paren_zero_branch
        .long also_7
        .long paren_error_minus_search_minus_o
        .long throw
also_7:
        .long context
        .long dup
        .long cell_plus
        .long current
        .long over
        .long minus
        .long move
        .long exit

        $COLON 133, "\x6f\x72\x64\x65\x72", order
        .long get_minus_order
        .long zero
        .long paren_question_do
        .long order_8
order_4:
        .long dot_wid
        .long space
        .long paren_loop
        .long order_4
order_8:
        .long paren_s_quote
        .byte  2
        .ascii "\x2f\x20"
        $ALIGN
        .long type
        .long current
        .long fetch
        .long dot_wid
        .long exit

        $COLON 136, "\x70\x72\x65\x76\x69\x6f\x75\x73", previous
        .long context
        .long cell_plus
        .long fetch
        .long zero_equals
        .long paren_zero_branch
        .long previous_8
        .long paren_error_minus_search_minus_u
        .long throw
previous_8:
        .long context
        .long dup
        .long cell_plus
        .long swap
        .long current
        .long cell_minus
        .long over
        .long minus
        .long move
        .long zero
        .long current
        .long cell_minus
        .long store
        .long exit

        $COLON 140, "\x28\x66\x6f\x72\x67\x65\x74\x2d\x77\x69\x64\x29", paren_forget_minus_wid
        .long dup
        .long greater_r
        .long fetch
paren_forget_minus_wid_3:
        .long two_dup
        .long greater
        .long zero_equals
        .long over
        .long zero_less_greater
        .long and
        .long paren_zero_branch
        .long paren_forget_minus_wid_14
        .long fetch
        .long paren_branch
        .long paren_forget_minus_wid_3
paren_forget_minus_wid_14:
        .long r_fetch
        .long store
        .long r_greater
        .long cell_plus
        .long cell_plus
        .long dup
        .long fetch
        .long rot
        .long greater
        .long paren_zero_branch
        .long paren_forget_minus_wid_30
        .long zero
        .long swap
        .long store
        .long paren_branch
        .long paren_forget_minus_wid_31
paren_forget_minus_wid_30:
        .long drop
paren_forget_minus_wid_31:
        .long exit

        $COLON 136, "\x28\x66\x6f\x72\x67\x65\x74\x29", paren_forget
        .long greater_link
        .long false
        .long swap
        .long paren_vocs
paren_forget_4:
        .long fetch
        .long two_dup
        .long less
        .long paren_zero_branch
        .long paren_forget_29
        .long paren_vocs
        .long context
        .long paren_do
        .long paren_forget_26
paren_forget_13:
        .long i
        .long fetch
        .long over
        .long equals
        .long paren_zero_branch
        .long paren_forget_23
        .long rot
        .long zero_equals
        .long minus_rot
        .long paren_leave
paren_forget_23:
        .long paren_cell
        .long paren_plus_loop
        .long paren_forget_13
paren_forget_26:
        .long cell_plus
        .long paren_branch
        .long paren_forget_4
paren_forget_29:
        .long paren_vocs
        .long store
        .long swap
        .long paren_zero_branch
        .long paren_forget_36
        .long only
        .long definitions
paren_forget_36:
        .long paren_vocs
paren_forget_37:
        .long fetch
        .long question_dup
        .long paren_zero_branch
        .long paren_forget_46
        .long two_dup
        .long paren_forget_minus_wid
        .long cell_plus
        .long paren_branch
        .long paren_forget_37
paren_forget_46:
        .long paren_here
        .long store
        .long exit

        $COLON 134, "\x66\x6f\x72\x67\x65\x74", forget
        .long tick
        .long paren_forget
        .long exit

        $COLON 226, "\x63\x22", c_quote
        .long paren_dolit
        .long 34
        .long parse
        .long paren_dolit
        .long paren_s_quote
        .long compile_comma
        .long paren_quote_comma
        .long paren_dolit
        .long drop
        .long compile_comma
        .long paren_dolit
        .long one_minus
        .long compile_comma
        .long exit

        $COLON 132, "\x28\x6f\x66\x29", paren_of
        .long over
        .long equals
        .long dup
        .long paren_zero_branch
        .long paren_of_6
        .long nip
paren_of_6:
        .long exit

        $COLON 228, "\x63\x61\x73\x65", case
        .long zero
        .long exit

        $COLON 226, "\x6f\x66", of
        .long paren_dolit
        .long paren_of
        .long compile_comma
        .long paren_dolit
        .long if
        .long execute
        .long exit

        $COLON 229, "\x65\x6e\x64\x6f\x66", endof
        .long paren_dolit
        .long else
        .long execute
        .long exit

        $COLON 231, "\x65\x6e\x64\x63\x61\x73\x65", endcase
        .long paren_dolit
        .long drop
        .long compile_comma
endcase_3:
        .long question_dup
        .long paren_zero_branch
        .long endcase_11
        .long paren_dolit
        .long then
        .long execute
        .long paren_branch
        .long endcase_3
endcase_11:
        .long exit

        $COLON 130, "\x75\x3e", u_greater
        .long swap
        .long u_less
        .long exit

        $COLON 135, "\x62\x75\x66\x66\x65\x72\x3a", buffer_colon
        .long zero
        .long constant
        .long align
        .long here
        .long swap
        .long allot
        .long latest
        .long name_greater
        .long greater_body
        .long store
        .long exit

        $COLON 201, "\x61\x63\x74\x69\x6f\x6e\x2d\x6f\x66", action_minus_of
        .long tick
        .long state
        .long fetch
        .long paren_zero_branch
        .long action_minus_of_13
        .long paren_dolit
        .long literal
        .long execute
        .long paren_dolit
        .long defer_fetch
        .long compile_comma
        .long paren_branch
        .long action_minus_of_14
action_minus_of_13:
        .long defer_fetch
action_minus_of_14:
        .long exit

        $COLON 134, "\x64\x65\x66\x65\x72\x40", defer_fetch
        .long greater_body
        .long cell_plus
        .long fetch
        .long exit

        $COLON 134, "\x64\x65\x66\x65\x72\x21", defer_store
        .long greater_body
        .long cell_plus
        .long store
        .long exit

        $COLON 133, "\x64\x65\x66\x65\x72", defer
        .long create
        .long paren_dolit
        .long store
        .long comma
        .long paren_dolit
        .long abort
        .long comma
        .long paren_semis_code
        $DODOES
        .long cell_plus
        .long fetch
        .long execute
        .long exit

        $COLON 194, "\x69\x73", is
        .long paren_dolit
        .long to
        .long execute
        .long exit

        $COLON 194, "\x74\x6f", to
        .long tick
        .long greater_body
        .long dup
        .long cell_plus
        .long swap
        .long fetch
        .long state
        .long fetch
        .long paren_zero_branch
        .long to_17
        .long swap
        .long paren_dolit
        .long literal
        .long execute
        .long compile_comma
        .long paren_branch
        .long to_18
to_17:
        .long execute
to_18:
        .long exit

        $COLON 133, "\x76\x61\x6c\x75\x65", value
        .long create
        .long paren_dolit
        .long store
        .long comma
        .long comma
        .long paren_semis_code
        $DODOES
        .long cell_plus
        .long fetch
        .long exit

        $COLON 201, "\x5b\x63\x6f\x6d\x70\x69\x6c\x65\x5d", bracket_compile_bracket
        .long tick
        .long compile_comma
        .long exit

        $COLON 134, "\x32\x76\x61\x6c\x75\x65", two_value
        .long create
        .long paren_dolit
        .long two_store
        .long comma
        .long comma
        .long comma
        .long paren_semis_code
        $DODOES
        .long cell_plus
        .long two_fetch
        .long exit

        $COLON 135, "\x73\x79\x6e\x6f\x6e\x79\x6d", synonym
        .long create
        .long smudge
        .long tick
        .long dup
        .long comma
        .long greater_name
        .long c_fetch
        .long paren_lex_minus_max_minus_name
        .long invert
        .long and
        .long latest
        .long c_fetch
        .long or
        .long latest
        .long c_store
        .long paren_semis_code
        $DODOES
        .long fetch
        .long execute
        .long exit

        $COLON 133, "\x28\x73\x5c\x22\x29", paren_s_backsl_quote
        .long two_dup
        .long two_greater_r
        .long zero
        .long zero
        .long two_swap
        .long bounds
        .long paren_question_do
        .long paren_s_backsl_quote_254
paren_s_backsl_quote_8:
        .long zero
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_62
        .long i
        .long c_fetch
        .long paren_dolit
        .long 92
        .long equals
        .long paren_zero_branch
        .long paren_s_backsl_quote_52
        .long i
        .long one_plus
        .long c_fetch
        .long paren_dolit
        .long 109
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_38
        .long dup
        .long i
        .long plus
        .long paren_dolit
        .long 13
        .long swap
        .long c_store
        .long paren_dolit
        .long 2
        .long paren_branch
        .long paren_s_backsl_quote_50
paren_s_backsl_quote_38:
        .long paren_dolit
        .long 120
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_48
        .long one_minus
        .long paren_dolit
        .long 3
        .long paren_branch
        .long paren_s_backsl_quote_50
paren_s_backsl_quote_48:
        .long drop
        .long one
paren_s_backsl_quote_50:
        .long paren_branch
        .long paren_s_backsl_quote_60
paren_s_backsl_quote_52:
        .long dup
        .long i
        .long plus
        .long i
        .long c_fetch
        .long swap
        .long c_store
        .long zero
paren_s_backsl_quote_60:
        .long paren_branch
        .long paren_s_backsl_quote_252
paren_s_backsl_quote_62:
        .long one
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_174
        .long one_minus
        .long i
        .long c_fetch
        .long paren_dolit
        .long 97
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_78
        .long paren_dolit
        .long 7
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_78:
        .long paren_dolit
        .long 98
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_87
        .long paren_dolit
        .long 8
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_87:
        .long paren_dolit
        .long 101
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_96
        .long paren_dolit
        .long 27
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_96:
        .long paren_dolit
        .long 102
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_105
        .long paren_dolit
        .long 12
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_105:
        .long paren_dolit
        .long 108
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_114
        .long paren_dolit
        .long 10
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_114:
        .long paren_dolit
        .long 110
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_123
        .long paren_dolit
        .long 10
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_123:
        .long paren_dolit
        .long 113
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_132
        .long paren_dolit
        .long 34
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_132:
        .long paren_dolit
        .long 114
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_141
        .long paren_dolit
        .long 13
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_141:
        .long paren_dolit
        .long 116
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_150
        .long paren_dolit
        .long 9
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_150:
        .long paren_dolit
        .long 118
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_159
        .long paren_dolit
        .long 11
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_159:
        .long paren_dolit
        .long 122
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_167
        .long zero
        .long paren_branch
        .long paren_s_backsl_quote_167
paren_s_backsl_quote_167:
        .long over
        .long i
        .long plus
        .long c_store
        .long zero
        .long paren_branch
        .long paren_s_backsl_quote_252
paren_s_backsl_quote_174:
        .long paren_dolit
        .long 2
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_189
        .long dup
        .long i
        .long plus
        .long paren_dolit
        .long 10
        .long swap
        .long c_store
        .long zero
        .long paren_branch
        .long paren_s_backsl_quote_252
paren_s_backsl_quote_189:
        .long paren_dolit
        .long 3
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_199
        .long one_minus
        .long paren_dolit
        .long 4
        .long paren_branch
        .long paren_s_backsl_quote_252
paren_s_backsl_quote_199:
        .long paren_dolit
        .long 4
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_226
        .long dup
        .long i
        .long plus
        .long i
        .long c_fetch
        .long paren_dolit
        .long 16
        .long digit
        .long zero_equals
        .long paren_zero_branch
        .long paren_s_backsl_quote_216
        .long zero
paren_s_backsl_quote_216:
        .long paren_dolit
        .long 16
        .long star
        .long swap
        .long c_store
        .long one_minus
        .long paren_dolit
        .long 5
        .long paren_branch
        .long paren_s_backsl_quote_252
paren_s_backsl_quote_226:
        .long paren_dolit
        .long 5
        .long paren_of
        .long paren_zero_branch
        .long paren_s_backsl_quote_251
        .long dup
        .long i
        .long plus
        .long dup
        .long c_fetch
        .long i
        .long c_fetch
        .long paren_dolit
        .long 16
        .long digit
        .long zero_equals
        .long paren_zero_branch
        .long paren_s_backsl_quote_245
        .long zero
paren_s_backsl_quote_245:
        .long or
        .long swap
        .long c_store
        .long zero
        .long paren_branch
        .long paren_s_backsl_quote_252
paren_s_backsl_quote_251:
        .long drop
paren_s_backsl_quote_252:
        .long paren_loop
        .long paren_s_backsl_quote_8
paren_s_backsl_quote_254:
        .long drop
        .long two_r_greater
        .long rot
        .long plus
        .long exit

        $COLON 195, "\x73\x5c\x22", s_backsl_quote
        .long paren_dolit
        .long 34
        .long parse
        .long paren_s_backsl_quote
        .long paren_paren_s_quote
        .long exit

        $COLON 133, "\x68\x6f\x6c\x64\x73", holds
        .long over
        .long plus
holds_2:
        .long two_dup
        .long u_less
        .long paren_zero_branch
        .long holds_12
        .long one_minus
        .long dup
        .long c_fetch
        .long hold
        .long paren_branch
        .long holds_2
holds_12:
        .long two_drop
        .long exit

        $COLON 196, "\x5b\x69\x66\x5d", bracket_if_bracket
        .long zero_equals
        .long paren_zero_branch
        .long bracket_if_bracket_64
        .long zero
        .long greater_r
bracket_if_bracket_5:
        .long parse_minus_name
        .long question_dup
        .long paren_zero_branch
        .long bracket_if_bracket_57
        .long two_dup
        .long paren_s_quote
        .byte  4
        .ascii "\x5b\x69\x66\x5d"
        $ALIGN
        .long casecompare
        .long zero_equals
        .long paren_zero_branch
        .long bracket_if_bracket_24
        .long two_drop
        .long r_greater
        .long one_plus
        .long greater_r
        .long false
        .long paren_branch
        .long bracket_if_bracket_55
bracket_if_bracket_24:
        .long two_dup
        .long paren_s_quote
        .byte  6
        .ascii "\x5b\x65\x6c\x73\x65\x5d"
        $ALIGN
        .long casecompare
        .long zero_equals
        .long paren_zero_branch
        .long bracket_if_bracket_37
        .long two_drop
        .long r_fetch
        .long zero_equals
        .long paren_branch
        .long bracket_if_bracket_55
bracket_if_bracket_37:
        .long two_dup
        .long paren_s_quote
        .byte  6
        .ascii "\x5b\x74\x68\x65\x6e\x5d"
        $ALIGN
        .long casecompare
        .long zero_equals
        .long paren_zero_branch
        .long bracket_if_bracket_53
        .long two_drop
        .long r_fetch
        .long zero_equals
        .long r_greater
        .long one_minus
        .long greater_r
        .long paren_branch
        .long bracket_if_bracket_55
bracket_if_bracket_53:
        .long two_drop
        .long false
bracket_if_bracket_55:
        .long paren_branch
        .long bracket_if_bracket_60
bracket_if_bracket_57:
        .long drop
        .long refill
        .long zero_equals
bracket_if_bracket_60:
        .long paren_zero_branch
        .long bracket_if_bracket_5
        .long r_greater
        .long drop
bracket_if_bracket_64:
        .long exit

        $COLON 198, "\x5b\x65\x6c\x73\x65\x5d", bracket_else_bracket
        .long zero
        .long paren_dolit
        .long bracket_if_bracket
        .long execute
        .long exit

        $COLON 198, "\x5b\x74\x68\x65\x6e\x5d", bracket_then_bracket
        .long exit

        $COLON 201, "\x5b\x64\x65\x66\x69\x6e\x65\x64\x5d", bracket_defined_bracket
        .long parse_minus_name
        .long paren_find
        .long paren_zero_branch
        .long bracket_defined_bracket_8
        .long drop
        .long true
        .long paren_branch
        .long bracket_defined_bracket_10
bracket_defined_bracket_8:
        .long two_drop
        .long false
bracket_defined_bracket_10:
        .long exit

        $COLON 203, "\x5b\x75\x6e\x64\x65\x66\x69\x6e\x65\x64\x5d", bracket_undefined_bracket
        .long paren_dolit
        .long bracket_defined_bracket
        .long execute
        .long zero_equals
        .long exit

        $COLON 135, "\x28\x6e\x61\x6d\x65\x3e\x29", paren_name_greater
        .long dup
        .long name_greater
        .long swap
        .long c_fetch
        .long paren_lex_minus_immediate
        .long and
        .long exit

        $COLON 140, "\x6e\x61\x6d\x65\x3e\x63\x6f\x6d\x70\x69\x6c\x65", name_greater_compile
        .long paren_name_greater
        .long paren_zero_branch
        .long name_greater_compile_7
        .long paren_dolit
        .long execute
        .long paren_branch
        .long name_greater_compile_9
name_greater_compile_7:
        .long paren_dolit
        .long compile_comma
name_greater_compile_9:
        .long exit

        $COLON 142, "\x6e\x61\x6d\x65\x3e\x69\x6e\x74\x65\x72\x70\x72\x65\x74", name_greater_interpret
        .long paren_name_greater
        .long paren_zero_branch
        .long name_greater_interpret_5
        .long drop
        .long false
name_greater_interpret_5:
        .long exit

        $COLON 139, "\x6e\x61\x6d\x65\x3e\x73\x74\x72\x69\x6e\x67", name_greater_string
        .long count
        .long paren_lex_minus_max_minus_name
        .long and
        .long exit

        $COLON 145, "\x74\x72\x61\x76\x65\x72\x73\x65\x2d\x77\x6f\x72\x64\x6c\x69\x73\x74", traverse_minus_wordlist
        .long swap
        .long greater_r
traverse_minus_wordlist_2:
        .long question_dup
        .long paren_zero_branch
        .long traverse_minus_wordlist_31
        .long fetch
        .long question_dup
        .long paren_zero_branch
        .long traverse_minus_wordlist_31
        .long dup
        .long l_greater_name
        .long dup
        .long c_fetch
        .long paren_lex_minus_start
        .long and
        .long paren_zero_branch
        .long traverse_minus_wordlist_25
        .long r_fetch
        .long rot
        .long greater_r
        .long execute
        .long r_greater
        .long swap
        .long paren_branch
        .long traverse_minus_wordlist_27
traverse_minus_wordlist_25:
        .long drop
        .long true
traverse_minus_wordlist_27:
        .long paren_zero_branch
        .long traverse_minus_wordlist_31
        .long paren_branch
        .long traverse_minus_wordlist_2
traverse_minus_wordlist_31:
        .long r_greater
        .long drop
        .long exit

        $COLON 137, "\x32\x63\x6f\x6e\x73\x74\x61\x6e\x74", two_constant
        .long create
        .long comma
        .long comma
        .long paren_semis_code
        $DODOES
        .long two_fetch
        .long exit

        $COLON 232, "\x32\x6c\x69\x74\x65\x72\x61\x6c", two_literal
        .long swap
        .long paren_dolit
        .long paren_dolit
        .long compile_comma
        .long comma
        .long paren_dolit
        .long paren_dolit
        .long compile_comma
        .long comma
        .long exit

        $COLON 137, "\x32\x76\x61\x72\x69\x61\x62\x6c\x65", two_variable
        .long create
        .long paren_dolit
        .long 0
        .long paren_dolit
        .long 0
        .long comma
        .long comma
        .long paren_semis_code
        $DODOES
        .long exit

        $COLON 130, "\x64\x3d", d_equals
        .long d_minus
        .long d_zero_equals
        .long exit

        $COLON 130, "\x64\x3c", d_less
        .long paren_dolit
        .long 2
        .long pick
        .long over
        .long xor
        .long zero_less
        .long paren_zero_branch
        .long d_less_11
        .long two_drop
        .long paren_branch
        .long d_less_12
d_less_11:
        .long d_minus
d_less_12:
        .long d_zero_less
        .long exit

        $COLON 131, "\x64\x3e\x73", d_greater_s
        .long drop
        .long exit

        $COLON 131, "\x64\x32\x2f", d_two_slash
        .long dup
        .long one
        .long and
        .long one
        .long cells
        .long paren_dolit
        .long 8
        .long star
        .long one_minus
        .long lshift
        .long greater_r
        .long two_slash
        .long swap
        .long u_two_slash
        .long r_greater
        .long or
        .long swap
        .long exit

        $COLON 131, "\x64\x32\x2a", d_two_star
        .long paren_dolit
        .long 2
        .long one
        .long m_star_slash
        .long exit

        $COLON 131, "\x64\x30\x3d", d_zero_equals
        .long zero_equals
        .long swap
        .long zero_equals
        .long and
        .long exit

        $COLON 131, "\x64\x30\x3c", d_zero_less
        .long nip
        .long zero_less
        .long exit

        $COLON 132, "\x64\x6d\x61\x78", dmax
        .long two_over
        .long two_over
        .long d_less
        .long paren_zero_branch
        .long dmax_6
        .long two_swap
dmax_6:
        .long two_drop
        .long exit

        $COLON 132, "\x64\x6d\x69\x6e", dmin
        .long two_over
        .long two_over
        .long two_swap
        .long d_less
        .long paren_zero_branch
        .long dmin_7
        .long two_swap
dmin_7:
        .long two_drop
        .long exit

        $COLON 132, "\x32\x72\x6f\x74", two_rot
        .long paren_dolit
        .long 5
        .long roll
        .long paren_dolit
        .long 5
        .long roll
        .long exit

        $COLON 131, "\x64\x75\x3c", du_less
        .long two_over
        .long two_swap
        .long d_minus
        .long rot
        .long swap
        .long two_dup
        .long less_greater
        .long paren_zero_branch
        .long du_less_10
        .long two_swap
du_less_10:
        .long two_drop
        .long u_less
        .long exit

        $COLON 135, "\x63\x6f\x6e\x76\x65\x72\x74", convert
        .long count
        .long greater_number
        .long drop
        .long exit

        $COLON 134, "\x75\x6e\x75\x73\x65\x64", unused
        .long paren_dolit
        .long -3
        .long paren_io
        .long here
        .long minus
        .long exit

        $COLON 134, "\x6d\x61\x72\x6b\x65\x72", marker
        .long create
        .long paren_semis_code
        $DODOES
        .long body_greater
        .long paren_forget
        .long exit

        $CONSTANT 142, "\x66\x6f\x72\x74\x68\x2d\x77\x6f\x72\x64\x6c\x69\x73\x74", forth_minus_wordlist
        .long forth_pfa

        $COLON 133, "\x63\x2d\x73\x74\x72", c_minus_str
        .long paren_scratch
        .long fetch
        .long dup
        .long greater_r
        .long two_dup
        .long plus
        .long greater_r
        .long swap
        .long move
        .long zero
        .long r_greater
        .long c_store
        .long r_greater
        .long exit

        $COLON 133, "\x28\x69\x6f\x72\x29", paren_ior
        .long dup
        .long paren_dolit
        .long -255
        .long zero
        .long within
        .long paren_zero_branch
        .long paren_ior_12
        .long paren_dolit
        .long -1000
        .long plus
        .long paren_branch
        .long paren_ior_14
paren_ior_12:
        .long drop
        .long zero
paren_ior_14:
        .long exit

        $COLON 134, "\x6d\x75\x6e\x6d\x61\x70", munmap
        .long paren_dolit
        .long -10
        .long paren_io
        .long paren_ior
        .long exit

        $COLON 132, "\x6d\x6d\x61\x70", mmap
        .long paren_dolit
        .long -9
        .long paren_io
        .long dup
        .long paren_ior
        .long exit

        $COLON 137, "\x6f\x70\x65\x6e\x2d\x66\x69\x6c\x65", open_minus_file
        .long greater_r
        .long c_minus_str
        .long r_greater
        .long paren_dolit
        .long -11
        .long paren_io
        .long dup
        .long paren_ior
        .long exit

        $COLON 137, "\x66\x69\x6c\x65\x2d\x73\x69\x7a\x65", file_minus_size
        .long paren_dolit
        .long -13
        .long paren_io
        .long dup
        .long greater_r
        .long s_greater_d
        .long r_greater
        .long paren_ior
        .long exit

        $CONSTANT 131, "\x72\x2f\x6f", r_slash_o
        .long 0

        $COLON 138, "\x63\x6c\x6f\x73\x65\x2d\x66\x69\x6c\x65", close_minus_file
        .long paren_dolit
        .long -12
        .long paren_io
        .long paren_ior
        .long exit

        $COLON 136, "\x69\x6e\x63\x6c\x75\x64\x65\x22", include_quote
        .long paren_dolit
        .long 34
        .long parse
        .long r_slash_o
        .long open_minus_file
        .long throw
        .long dup
        .long file_minus_size
        .long throw
        .long drop
        .long two_dup
        .long mmap
        .long throw
        .long rot
        .long greater_r
        .long swap
        .long two_dup
        .long two_greater_r
        .long paren_dolit
        .long evaluate
        .long catch
        .long two_r_greater
        .long munmap
        .long r_greater
        .long close_minus_file
        .long rot
        .long throw
        .long throw
        .long throw
        .long exit

        $COLON 132, "\x63\x6f\x6c\x64", cold
        .long rp_fetch
        .long paren_rp_zero
        .long store
        .long paren_dolit
        .long paren_urx_question
        .long paren_rx_question
        .long store
        .long paren_dolit
        .long paren_urx_fetch
        .long paren_rx_fetch
        .long store
        .long paren_dolit
        .long paren_utx_question
        .long paren_tx_question
        .long store
        .long paren_dolit
        .long paren_utx_store
        .long paren_tx_store
        .long store
        .long forth
        .long definitions
        .long gmpforth
        .long quit
        .long exit

        .globl _ENTRY
        .set _ENTRY, cold

