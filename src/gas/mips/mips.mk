#
#  mips.mk
# 
#  Copyright (c) 2015 by Daniel Kelley
# 
#  $Id:$
#
#  external dependency: MODEL

.PHONY: all clean

VPATH := ..
VPATH += ../..
VPATH += ../../common

TARGET := mips

ABI :=

ARCH := $(TARGET)

ifeq ($(MODEL),64)
CROSS_MIPS_64 ?= $(ARCH)-elf-
CROSS_TARGET := $(CROSS_MIPS_64)
ABI := -mabi=64
ELF := -melf64btsmip
else
CROSS_MIPS_32 ?= $(ARCH)-elf-
CROSS_TARGET := $(CROSS_MIPS_32)
endif
CROSS ?= $(CROSS_TARGET)

BASE := ../../../..

INC := -I.. -I../.. -I../../common -I$(BASE)/include

OPT := -g

ASFLAGS := $(ABI) -aldm=kernel.lst $(OPT) $(INC) -MD=kernel.d

MFLAGS := $(OPT) $(INC)

LDFLAGS := $(OPT) $(ELF) -Map=forth.map

GENERATED := kernel.inc
GENERATED += syscall.inc
GENERATED += const.inc
GENERATED += *.d

AS := $(CROSS)as
LD := $(CROSS)ld

all: forth.elf

.DELETE_ON_ERROR: # delete target if a command returns an error

forth.elf: kernel.o
	$(LD) $(LDFLAGS) -o $@ kernel.o -L.

kernel.o: kernel.s sdefs.inc mdefs.inc defs.inc pre.inc kernel.inc post.inc start.inc

kernel.inc:
	$(BASE)/bin/gmpfc -c -H -t$(TARGET) -u$(MODEL) -I$(BASE) --make-dependency=$@.d,$@ --make-asm-header=const.inc src/gas/$(TARGET)/$(MODEL)/forth.fs src/fig/cold.fs > $@

clean:
	-rm -f kernel.o $(GENERATED) kernel.lst \
	forth.map forth.elf

-include *.d
