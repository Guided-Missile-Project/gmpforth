#
#  Makefile
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

BASE=../../..

all: image.bin

.DELETE_ON_ERROR: # delete target if a command returns an error

image.bin: image.o
	ld -o$@ -e0 --oformat=binary -Ttext=0 $<

image.o: vm.s vm_defs.inc vm_macro.inc ../defs.inc vm_forth.inc vm_type0.inc
	as -o$@  -MD=image.d -I.. -ahlsm $< > vm.lst

vm_type0.inc: $(BASE)/lib/gmpforth/vm.rb
	ruby -I$(BASE)/lib -rgmpforth.rb -eGMPForth::VM.gas_macros > $@

vm_forth.inc:
	$(BASE)/bin/gmpfc -c -tvmgas  --make-dependency=$@.d,$@ -I$(BASE) src/vm/forth32.fs src/forth-vm.fs src/fig/cold.fs > $@

clean:
	-rm -f vm_type0.inc vm.lst image.o image.bin vm_forth.inc *.d

-include *.d
