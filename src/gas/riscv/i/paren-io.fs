CODE (io)

        .globl  __edict
        .set _HAS_PAREN_IO, 1

        $BLOCK
        /* check (io) opcode */
        $TRANSFER
        $BGEZ   pp1, ret_false  /* generalized syscall not supported */
1:
        $BLOCK
        $SLTI   t1, pp1, -16
        $TRANSFER
        bnez    t1, ret_false   /* local IO call out of range */
1:
        $BLOCK
        $LA     t1, iotbl
        $SHL    pp1, pp1, _LGSZ
        $ADD    t1, t1, pp1
        $XLD    t1, (t1)        /* get handler address */
        $TRANSFER
        jr      t1              /* branch to handler */
        $ENDCODE

        /* txstore ( c io -- ) */
txstore:
        $BLOCK
        $PDIS   1
        /* ENDIAN DEPENDENT */
        $SET    a0, 1
        $MOV    a1, sp
        $SET    a2, 1
        $SYS    SYS_WRITE       /* sys_write(1,sp,1) */
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
        $SET    a0, 0
        $MOV    a1, sp
        $SET    a2, 1
        $SYS    SYS_READ        /* O32 sys_read(0,sp,1) */
        $PTOS   pp1
        $NEXT

memlimit:
        $LDA    pp1, __edict
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

        .section .sdata, "aw"

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

END-CODE
