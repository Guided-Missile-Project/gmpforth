        .macro vm_push n nxt=0
        vm_op VM_PUSH+\n \nxt
        .endm

        .macro vm_next
        vm_nop 1
        .endm

        .macro vm_halt nxt=0
        vm_push VM_HALT
        vm_io \nxt
        .endm

        .macro vm_push_0 nxt=0
        vm_push 0 \nxt
        .endm

        .macro vm_push_1 nxt=0
        vm_push 1 \nxt
        .endm

        .macro vm_push_m1 nxt=0
        vm_push VM_M1 \nxt
        .endm

        .macro vm_reg reg fetch=0 nxt=0
        vm_push \reg
        .if    \fetch
        vm_reg_fetch \nxt
        .else
        vm_reg_store \nxt
        .endif
        .endm

        .macro vm_rp_fetch nxt=0
        vm_reg VM_REG_RP FETCH \nxt
        .endm

        .macro vm_sp_fetch nxt=0
        vm_reg VM_REG_SP FETCH \nxt
        .endm

        .macro vm_up_fetch nxt=0
        vm_reg VM_REG_UP FETCH \nxt
        .endm

        .macro vm_rp_store nxt=0
        vm_reg VM_REG_RP STORE \nxt
        .endm

        .macro vm_sp_store nxt=0
        vm_reg VM_REG_SP STORE \nxt
        .endm

        .macro vm_up_store nxt=0
        vm_reg VM_REG_UP STORE \nxt
        .endm

        .macro vm_op opcode nxt
        .if    \nxt
        .byte  \opcode+VM_NEXT
        .else
        .byte  \opcode
        .endif
        .endm
