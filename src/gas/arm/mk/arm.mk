#
#  arm.mk
# 
#  Copyright (c) 2015 by Daniel Kelley
# 
#  $Id:$
#
#  external dependency: MODEL

.PHONY: all clean

VPATH := ../..
VPATH += ../../common
VPATH += ../common

TARGET := arm

ABI :=

ifeq ($(MODEL),a64)
ARCH := aarch64
CROSS_A64 ?= $(ARCH)-elf-
CROSS_TARGET := $(CROSS_A64)
else
ARCH := $(TARGET)
ABI :=  -meabi=5
CROSS_A32 ?= $(ARCH)-elf-
CROSS_TARGET := $(CROSS_A32)
endif
CROSS ?= $(CROSS_TARGET)


BASE := ../../../..

INC := -I../.. -I../../common -I../common -I$(BASE)/include

OPT := -g

# EABI=5 is needed for thumb so function addresses will have LSB set.
ASFLAGS := -aldm=kernel.lst $(ABI) $(OPT) $(INC) -MD=kernel.d

MFLAGS := $(OPT) $(INC)

LDFLAGS := $(OPT) -Map=forth.map

ifeq ($(MODEL),t32)
LDFLAGS += --thumb-entry=_start
endif

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

kernel.o: kernel.s mdefs.inc ../../defs.inc pre.inc kernel.inc post.inc start.inc

kernel.inc:
	$(BASE)/bin/gmpfc -c -H -t$(TARGET) -u$(MODEL) -I$(BASE) --make-dependency=$@.d,$@ --make-asm-header=const.inc src/gas/$(TARGET)/$(MODEL)/forth.fs src/fig/cold.fs > $@

clean:
	-rm -f kernel.o $(GENERATED) kernel.lst \
	forth.map forth.elf

-include *.d
