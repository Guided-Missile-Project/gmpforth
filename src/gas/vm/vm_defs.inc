        .set VM_PUSH, 0x80
        .set VM_NEXT, 0x40
        .set VM_HALT, 0x38

        .set VM_M1,   0x3f
        .set VM_REG_SP, 0
        .set VM_REG_RP, 1
        .set VM_REG_UP, 2
        .set FETCH, 1
        .set STORE, 0

        .include        "vm_macro.inc"
        .include        "vm_type0.inc"

        .set _LINK, 0
        .set _ALIGN, 4
        .set _SZ, 4
