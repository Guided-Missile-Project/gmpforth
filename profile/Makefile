#
#  Makefile
#
#  Copyright (c) 2014 by Daniel Kelley
#
# Disassembler benefits from a special binutils BFD and opcodes
# library built for all targets.
#
# .../binutils/configure --enable-64-bit-bfd --enable-targets=all
#  --enable-shared  --program-prefix=u-
# --disable-gold --disable-ld --without-gas --without-gprof --with-system-zlib
#

-include .ubfd

UBFD ?= /usr/local
INC := $(UBFD)/include
LIB := $(UBFD)/lib
CFLAGS := -Wall -Wextra -MMD
CFLAGS += -I.
CFLAGS += -I$(INC)
LDFLAGS := -g -L $(LIB) -Wl,-rpath=$(LIB)
LDLIBS := -lbfd -lopcodes -liberty -lz

all: profile disasm

clean:
	-rm -f profile disasm *.d

-include *.d

