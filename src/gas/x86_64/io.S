#include        "asm/unistd.h"
#include        "asm/ioctls.h"
#include        "syscall-linux.inc"
#include        "mdefs.inc"
#include        "defs.inc"
#include        "termios.inc"

        .globl  _io
        .globl  _exit
        .globl  aelist
        .globl  _END_DICT
        .set    nr_sysargs, linux_sysargs_end - linux_sysargs

        .macro $TRACE point
        $TRACE_LABEL io, \point
        .endm

        .text
_io:
        $BLOCK
        /* save regs that are destroyed by system calls */
        movq    %rsi, %r12
        /* get (io) opcode */
        movq    (%rsp), %rax
        cmpq    $0, %rax
        $TRANSFER
        jns     _syscall                /* >=0 is syscall */
        $BLOCK
        cmpq    $-16, %rax              /* <-16 is hlt */
        $TRANSFER
        jb      hlt
__io:
        $BLOCK
        mov     iotbl(,%rax,_SZ), %rdx    /* lookup in iotbl */
        $TRANSFER
        jmp     *%rdx

        /* txstore */
txstore:
        $BLOCK
        cmpq    $0, needraw
        $TRANSFER
        jne     1f
        call    setraw
1:
        $BLOCK
        addq    $_SZ, %rsp /* pop (io) opcode, write char on TOS */
        $SYS3   __NR_write, $1, %rsp, $1
        cmpq    $1, %rax
        $TRANSFER
        jne     hlt
        $BLOCK
        addq    $_SZ, %rsp /* pop character */
        jmp     io_next

        /* ret_true */
ret_true:
        $BLOCK
        movq    $-1, (%rsp)
        jmp     io_next

        /* ret_false */
ret_false:
        $BLOCK
        movq    $0, (%rsp)
        jmp     io_next

        /* rx_fetch */
rxfetch:
        $BLOCK
        cmpq    $0, needraw
        $TRANSFER
        jne     1f
        call    setraw
1:
        $BLOCK
        /* IO req on stack will be overwritten by read */
        movq    $0, (%rsp)
        $SYS3   __NR_read, $0, %rsp, $1
        cmpq    $1, %rax
        $TRANSFER
        je      2f
        /* make error or eof look like cr to force accept to complete */
        $BLOCK
        movq    $13, (%rsp)
2:
        $BLOCK
        jmp     io_next

        /* memlimit */
memlimit:
        $BLOCK
        movq    $_END_DICT, (%rsp)
        jmp     io_next

        /* io_mmap ( fd len -- addr' ior ) */
io_mmap:
        $BLOCK
        addq    $_SZ, %rsp /* pop (io) opcode */
        popq    %rbx            /* len */
        popq    %rax            /* fd */
        pushq   $0              /* addr */
        pushq   %rbx            /* len */
        cmpq    $0, %rax
        $TRANSFER
        jns     1f
        /* anonymous memory mapping */
        pushq   $7              /* prot */
        pushq   $0x22           /* flags */
        $TRANSFER
        jmp 2f
1:
        $BLOCK
        /* read-only file mapping */
        pushq   $5              /* prot */
        pushq   $0x02           /* flags */
2:
        $BLOCK
        pushq   %rax            /* fd */
        pushq   $0              /* addr */
        movq    $__NR_mmap, %rax
        $TRANSFER
        jmp     syscall_direct

io_munmap:
        $BLOCK
        /* io_munmap ( addr len -- ior ) */
        addq    $_SZ, %rsp /* pop (io) opcode */
        movq    $__NR_munmap, %rax
        $TRANSFER
        jmp     syscall_direct

io_open_file:
        $BLOCK
        /* io_open_file  ( cstr flags -- ior ) */
        movq    $0, (%rsp) /* mode */
        movq    $__NR_open, %rax
        $TRANSFER
        jmp     syscall_direct

io_close_file:
        $BLOCK
        /* io_close_file  ( fd -- ior ) */
        addq    $_SZ, %rsp /* pop (io) opcode */
        movq    $__NR_close, %rax
        $TRANSFER
        jmp     syscall_direct

io_size_file:
        $BLOCK
        /* io_size_file  ( fd -- ior ) */
        addq    $_SZ, %rsp /* pop (io) opcode */
        movq    $__NR_lseek, %rax
        popq    %rdi
        movq    $0, %rsi
        movq    $2, %rdx /* seek to end */
        syscall
        pushq   %rax     /* save offset, which is the length of the file */
        movq    $__NR_lseek, %rax
        movq    $0, %rdx /* seek to beginning */
        syscall
        jmp     io_next

_syscall:
        $BLOCK
        addq    $_SZ, %rsp /* pop (io) opcode */
        cmpq    $nr_sysargs, %rax
        $TRANSFER
        jge     syscall_u
syscall_direct:
        $BLOCK
        movzbq  linux_sysargs(%rax), %rbx
        mov     iotbl(,%rbx,_SZ), %rdx    /* lookup in iotbl */
        $TRANSFER
        jmp     *%rdx

syscall_u:
        $BLOCK
        /* undefined syscall */
        movq    $-22, %rax
        $TRANSFER
        jmp     syscall_done

syscall_6:
        $BLOCK
        /* 6 argument syscall */
        popq    %r9
syscall_5:
        $BLOCK
        /* 5 argument syscall */
        popq    %r8
syscall_4:
        $BLOCK
        /* 4 argument syscall */
        popq    %r10
syscall_3:
        $BLOCK
        /* 3 argument syscall */
        popq    %rdx
syscall_2:
        $BLOCK
        /* 2 argument syscall */
        popq    %rsi
syscall_1:
        $BLOCK
        /* 1 argument syscall */
        popq    %rdi
syscall_0:
        $BLOCK
        /* 0 argument syscall */
        syscall
syscall_done:
        $BLOCK
        pushq   %rax
io_next:
        $BLOCK
        /* restore regs that are destroyed by system calls */
        movq    %r12, %rsi
        $NEXT

hlt:
        $TRANSFER
        jmp     _exit

setraw:
        $BLOCK
        /* get current terminal state */
        $SYS3   __NR_ioctl, $0, $TCGETS, $termios_cooked

        /* if not a tty, then nevermind */
        cmpq    $0, %rax
        $TRANSFER
        jne     1f

        /* get current terminal state, and set raw */
        $SYS3   __NR_ioctl, $0, $TCGETS, $termios_raw
        movq    $termios_raw, %rdi
        call    cfmakeraw
        $SYS3   __NR_ioctl, $0, $TCSETS, $termios_raw
        incq    needraw

        /* register setcooked atexit record */
        movq    aelist, %rax
        movq    %rax, ioatexit
        movq    $ioatexit, %rax
        movq    %rax, aelist
1:      
        $TRANSFER
        ret

        /* put terminal back to cooked mode, and return the
           addr of the next atexit record */
setcooked:
        $BLOCK
        $SYS3   __NR_ioctl, $0, $TCSETS, $termios_cooked
        movq    ioatexit, %rax
        $TRANSFER
        ret

        .set    c_iflag, ~(IGNBRK|BRKINT|IGNPAR|PARMRK|INPCK|ISTRIP|\
                           INLCR|IGNCR|ICRNL|IUCLC|IXON|IXANY|IXOFF|IMAXBEL)
        .set    c_oflag, ~OPOST
        .set    c_lflag, ~(ICANON|ECHO|ECHONL|ISIG|IEXTEN|XCASE)
        .set    c_cflaga, ~(CSIZE|PARENB)
        .set    c_cflago, CS8;

cfmakeraw:
        andl    $c_iflag,   (%rdi)      /* c_iflag */
        andl    $c_oflag,  4(%rdi)      /* c_oflag */
        andl    $c_cflaga, 8(%rdi)      /* c_cflag */
        orl     $c_cflago, 8(%rdi)
        andl    $c_lflag, 12(%rdi)      /* c_lflag */
        movb    $0, 22(%rdi)
        movb    $1, 23(%rdi)
        ret

        .data

        /* atexit record: function, link */
ioatexit:
        .quad   0
ioatexitf:
        .quad   setcooked
iotbl_end:
        .quad   ret_false       /* -16 unimplemented  */
        .quad   ret_false       /* -15 unimplemented  */
        .quad   ret_false       /* -14 unimplemented  */
        .quad   io_size_file    /* -13 IO_SIZE_FILE   */
        .quad   io_close_file   /* -12 IO_CLOSE_FIZE  */
        .quad   io_open_file    /* -11 IO_OPEN_FILE   */
        .quad   io_munmap       /* -10 IO_MUNMAP      */
        .quad   io_mmap         /* -9  IO_MMAP        */
        .quad   hlt             /* -8  IO_HALT        */
        .quad   ret_true        /* -7  IO_RX_QUESTION */
        .quad   rxfetch         /* -6  IO_RX_FETCH    */
        .quad   ret_true        /* -5  IO_TX_QUESTION */
        .quad   txstore         /* -4  IO_TX_STORE    */
        .quad   memlimit        /* -3  IO_MEM_LIMIT   */
        .quad   ret_false       /* -2  unimplemented  */
        .quad   ret_false       /* -1  unimplemented  */
iotbl:
        .quad   syscall_0       /* 0 argument syscall */
        .quad   syscall_1       /* 1 argument syscall */
        .quad   syscall_2       /* 2 argument syscall */
        .quad   syscall_3       /* 3 argument syscall */
        .quad   syscall_4       /* 4 argument syscall */
        .quad   syscall_5       /* 5 argument syscall */
        .quad   syscall_6       /* 6 argument syscall */
        .quad   syscall_u       /* undefined syscall */
        .include "syscall.inc"

        .bss
        .balign 32
termios_raw:
        .space 60
        .balign 32
termios_cooked:
        .space 60
needraw:
        .space  _SZ
