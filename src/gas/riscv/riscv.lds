SECTIONS
{
    . = 0x1000;
    .text : {
        *(.text)
    }
    .data ALIGN(256) : {
        __DATA_BEGIN__ = .;
        *(.data)
    }
    .sdata ALIGN(8) : {
        __SDATA_BEGIN__ = .;
        *(.sdata)
    }
    .bss : {
        *(.bss)
    }
    __BSS_END__ = .;
    __global_pointer$ = MIN(__SDATA_BEGIN__ + 0x800,
		            MAX(__DATA_BEGIN__ + 0x800, __BSS_END__ - 0x800));
}
