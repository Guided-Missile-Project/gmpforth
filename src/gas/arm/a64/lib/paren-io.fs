CODE (io)

        .globl  _END_DICT
        .set _HAS_PAREN_IO, 1

        $BLOCK
        /* check (io) opcode */
        cmp     pp1, 0
        $TRANSFER
        bpl     ret_false       /* generalized syscall interface not supported */
1:
        $BLOCK
        cmp     pp1, -16
        $TRANSFER
        bmi     ret_false       /* local IO call out of range */
1:
        $BLOCK
        adr     t1, _iotbl
        ldr     t1, [t1]        /* get iotbl */
        ldr     t1, [t1, pp1, lsl _LGSZ]        /* get handler address */
        $TRANSFER
        br      t1              /* branch to handler */
        $ENDCODE
_iotbl: $WORD iotbl

        /* txstore ( c io -- ) */
        $MACH_FUNC_MARK txstore
txstore:
        $BLOCK
        $PDIS   1
        $SYS3   64, 1, spp, 1   /* sys_write(1,spp,1) */
        $PDIS   1
        $PTOS   pp1
        $NEXT

        /* ret_true */
        $MACH_FUNC_MARK ret_true
ret_true:
        $BLOCK
        $SET    pp1, -1
        $NEXT

        /* ret_false */
        $MACH_FUNC_MARK ret_false
ret_false:
        $BLOCK
        $SET    pp1, 0
        $NEXT

        /* rx_fetch ( io -- c ) */
        $MACH_FUNC_MARK rxfetch
rxfetch:
        $BLOCK
        $SET    pp1, 0
        $S_PTOS pp1
        $SYS3   63, 0, spp, 1    /* sys_read(0,spp,1) */
        $PTOS   pp1
        $NEXT

        $MACH_FUNC_MARK memlimit
memlimit:
        adr     t1, _memlimit
        ldr     pp1, [t1]        /* get _END_DICT */
        $NEXT
_memlimit: $WORD _END_DICT

        $MACH_FUNC_MARK io_mmap
io_mmap:
        $BLOCK
        /* io_mmap ( fd len -- addr' ior )  */
        $SET    pp1, 0
        $NEXT

        $MACH_FUNC_MARK io_munmap
io_munmap:
        $BLOCK
        /* io_munmap ( addr len -- ior )  */
        $SET    pp1, 0
        $NEXT

        $MACH_FUNC_MARK io_open_file
io_open_file:
        $BLOCK
        /* io_open_file  ( cstr flags -- ior )  */
        $SET    pp1, 0
        $NEXT

        $MACH_FUNC_MARK io_close_file
io_close_file:
        $BLOCK
        /* io_close_file  ( fd -- ior )  */
        $SET    pp1, 0
        $NEXT

        $MACH_FUNC_MARK io_size_file
io_size_file:
        $BLOCK
        /* io_size_file  ( fd -- ior )  */
        $SET    pp1, 0
        $NEXT

        $MACH_FUNC_MARK hlt
hlt:
        $TRANSFER
        $JMP    _exit

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

END-CODE
