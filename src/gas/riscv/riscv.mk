#
#  riscv.mk
#
#  Copyright (c) 2020 by Daniel Kelley
#
#  external dependency: MODEL CROSS
#

.PHONY: all clean

VPATH := ..
VPATH += ../..
VPATH += ../../common

TARGET := riscv

ifneq (, $(findstring 64,$(MODEL)))
EMULATION := elf64lriscv
MACH := -mabi=lp64
else
EMULATION := elf32lriscv
MACH := -mabi=ilp32
endif
MACH += -march=$(MODEL)

PIC := -fno-pic

LDSCRIPT := ../riscv.lds

BASE := ../../../..

INC := -I.. -I../.. -I../../common -I$(BASE)/include

OPT := -g

ASFLAGS := $(MACH) $(PIC) -aldm=kernel.lst $(OPT) $(INC) -MD=kernel.d

MFLAGS := $(OPT) $(INC)

LDFLAGS := $(OPT) -m $(EMULATION) -Map=forth.map
LDFLAGS += --build-id
LDFLAGS += --verbose
#LDFLAGS += -T$(LDSCRIPT)

GENERATED := kernel.inc
GENERATED += syscall.inc
GENERATED += const.inc
GENERATED += *.d

AS := $(CROSS)as
LD := $(CROSS)ld
OBJCOPY := $(CROSS)objcopy
STRIP := $(CROSS)strip

all: forth.elf

.DELETE_ON_ERROR: # delete target if a command returns an error

forth.elf: kernel.o # $(LDSCRIPT)
	$(LD) $(LDFLAGS) -o $@ kernel.o -L.
	$(OBJCOPY) --only-keep-debug $@ $@.debug
	$(STRIP) $@
	$(OBJCOPY) --add-gnu-debuglink=$@.debug $@

kernel.o: kernel.s sdefs.inc mdefs.inc defs.inc pre.inc kernel.inc post.inc start.inc

kernel.inc:
	$(BASE)/bin/gmpfc -c -H -t$(TARGET) -u$(MODEL) -I$(BASE) --make-dependency=$@.d,$@ --make-asm-header=const.inc src/gas/$(TARGET)/$(MODEL)/forth.fs src/fig/cold.fs > $@

run: forth.elf
	./forth

clean:
	-rm -f kernel.o $(GENERATED) kernel.lst \
	forth.map forth.elf forth.elf.debug

-include *.d
