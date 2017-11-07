#
#  mmix.mk
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

TARGET := mmix

BASE := ../../../..

INC := -I../.. -I../../common -I../common -I$(BASE)/include

OPT := -g

ASFLAGS := -aldm=kernel.lst $(OPT) $(INC) -MD=kernel.d

MFLAGS := $(OPT) $(INC)

LDFLAGS := $(OPT) -Map=forth.map --oformat mmo

GENERATED := kernel.inc
GENERATED += syscall.inc
GENERATED += const.inc
GENERATED += *.d

# FIXME: pick up from .cross
AS := $(TARGET)-as
LD := $(TARGET)-ld

all: forth.mmo

.DELETE_ON_ERROR: # delete target if a command returns an error

forth.mmo: kernel.o
	$(LD) $(LDFLAGS) -o $@ kernel.o -L.

kernel.o: kernel.s mdefs.inc ../../defs.inc pre.inc kernel.inc post.inc start.inc

kernel.inc:
	$(BASE)/bin/gmpfc -c -H -t$(TARGET) -u$(MODEL) -I$(BASE) --make-dependency=$@.d,$@ --make-asm-header=const.inc src/gas/$(TARGET)/$(MODEL)/forth.fs src/fig/cold.fs > $@

clean:
	-rm -f kernel.o $(GENERATED) kernel.lst \
	forth.map forth.mmo

-include *.d
