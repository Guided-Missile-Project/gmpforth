#
#  Makefile
#
#  Copyright (c) 2010 by Daniel Kelley
#

RUBY19 ?= ruby19
RUBY ?= ruby

RUBYLIB := $(CURDIR)/lib:$(CURDIR)/test
export RUBYLIB

LIDX := src/core/Library.yaml
LIDX += src/core-ext/Library.yaml
LIDX += src/double/Library.yaml
LIDX += src/double-f/Library.yaml
LIDX += src/double-ext/Library.yaml
LIDX += src/exception/Library.yaml
LIDX += src/impl/Library.yaml
LIDX += src/impl/parameter/Library.yaml
LIDX += src/impl-ext/Library.yaml
LIDX += src/search/Library.yaml
LIDX += src/search-ext/Library.yaml
LIDX += src/string/Library.yaml
LIDX += src/tools/Library.yaml
LIDX += src/tools-ext/Library.yaml
LIDX += src/user/lib/Library.yaml
LIDX += src/vm/lib/Library.yaml
LIDX += src/32/Library.yaml
LIDX += src/64/Library.yaml
LIDX += src/f83/Library.yaml
LIDX += src/f83/sp-none/Library.yaml
LIDX += src/f83/sp-down/Library.yaml
LIDX += src/f83/sp-up/Library.yaml
LIDX += src/fig/Library.yaml
LIDX += src/file/Library.yaml
LIDX += src/gas/common/Library.yaml
LIDX += src/gas/mmix/common/Library.yaml
LIDX += src/gas/pure/Library.yaml
LIDX += src/gas/mmix/pure/lib/Library.yaml
LIDX += src/gas/c10/Library.yaml
LIDX += src/gas/mmix/c10/lib/Library.yaml
LIDX += src/gas/c11/Library.yaml
LIDX += src/gas/mmix/c11/lib/Library.yaml
LIDX += src/core-ext/recursive/pick/Library.yaml
LIDX += src/core-ext/recursive/roll/Library.yaml
LIDX += src/gas/arm/a32/lib/Library.yaml
LIDX += src/gas/arm/t32/lib/Library.yaml
LIDX += src/gas/arm/a64/lib/Library.yaml
LIDX += src/gas/mips/32/lib/Library.yaml
LIDX += src/gas/mips/64/lib/Library.yaml
LIDX += src/gas/i386/lib/Library.yaml
LIDX += src/gas/x86_64/lib/Library.yaml
LIDX += src/gas/riscv/i/Library.yaml
LIDX += src/gas/riscv/m/Library.yaml

FILES := image32be
FILES += image32le
FILES += kern-i386.s
FILES += $(LIDX)

FORTH := i386-forth

GENERATED := lib/gmpforth/ioconstants.rb
GENERATED += include/ioconstants.h

RELEASE_TESTS := test
RELEASE_TESTS += test-le

RELEASE_TESTS += test-cvm
RELEASE_TESTS += test-gdb-mi2
RELEASE_TESTS += i386-test
RELEASE_TESTS += test-ht-cvm
RELEASE_TESTS += test-ht-gas-vm
RELEASE_TESTS += test-cli
RELEASE_TESTS += doc
RELEASE_TESTS += coverage

COV_ARCH :=
HAYES_TESTS :=

ifeq (x86_64,$(shell uname -m))
COV_ARCH += x86_64
RELEASE_TESTS += x86_64-test
FORTH += x86_64-forth
COV_HAYES_TEST := test-ht-gas-x86_64
HAYES_TESTS += $(COV_HAYES_TEST)
else
COV_ARCH += i386
COV_HAYES_TEST += test-ht-gas-i386
HAYES_TESTS += $(COV_HAYES_TEST)
endif

COV_OUTPUT := $(patsubst %,output/COV.%,$(COV_ARCH))
COV_TARGET := $(patsubst %,%-forth,$(COV_ARCH))

# add if mmix
ifneq (,$(wildcard .mmix))
RELEASE_TESTS += test-gas-mmix-pure
RELEASE_TESTS += test-gas-mmix-c10
RELEASE_TESTS += test-gas-mmix-c11
HAYES_TESTS   += test-ht-gas-mmix-pure
HAYES_TESTS   += test-ht-gas-mmix-c10
HAYES_TESTS   += test-ht-gas-mmix-c11
FORTH += gas-mmix-pure-forth
FORTH += gas-mmix-c10-forth
FORTH += gas-mmix-c11-forth
include .mmix
endif

# add if arm/a32 arm/t32
ifneq (,$(wildcard .arm))
RELEASE_TESTS += test-gas-arm-a32
RELEASE_TESTS += test-gas-arm-t32
HAYES_TESTS   += test-ht-gas-arm-a32
HAYES_TESTS   += test-ht-gas-arm-t32
FORTH += gas-arm-a32-forth
FORTH += gas-arm-t32-forth
include .arm
endif

# add if arm/a64
ifneq (,$(wildcard .aarch64))
RELEASE_TESTS += test-gas-arm-a64
HAYES_TESTS   += test-ht-gas-arm-a64
FORTH += gas-arm-a64-forth
include .aarch64
endif

# add if mips32
ifneq (,$(wildcard .mips32))
RELEASE_TESTS += test-gas-mips-32
HAYES_TESTS   += test-ht-gas-mips-32
FORTH += gas-mips-32-forth
include .mips32
endif

# add if mips64
ifneq (,$(wildcard .mips64))
RELEASE_TESTS += test-gas-mips-64
HAYES_TESTS   += test-ht-gas-mips-64
FORTH += gas-mips-64-forth
include .mips64
endif

# add if riscv
ifneq (,$(wildcard .riscv))
include .riscv
endif

RELEASE_TESTS += $(HAYES_TESTS)

INC := -I. -Isrc/vm -Isrc

.PHONY: test cvm all doc lib generated

all: lib generated image32be image32le cvm $(FORTH) profile_tools

test: generated
	bin/test

test19: generated
	$(RUBY19) bin/test

test-le: generated
	bin/test -- -El

test19-le: generated
	$(RUBY19) bin/test -- -El

test-cvm:  generated cvm
	$(RUBY) test/test_cvm.rb

test-gdb-mi2:
	$(RUBY) test/test_gdb_mi2.rb

test-gas-i386: i386-forth lib
	$(RUBY) test/test_gas_i386.rb

test-gas-x86_64: x86_64-forth lib
	$(RUBY) test/test_gas_x86_64.rb

test-ht-cvm: cvm
	$(RUBY) test/test_ht_cvm.rb

test-ht-gas-i386: i386-forth
	$(RUBY) test/test_ht_gas_i386.rb

test-ht-gas-vm: gas-vm-forth
	$(RUBY) test/test_ht_gas_vm.rb

test-ht-gas-x86_64: x86_64-forth
	$(RUBY) test/test_ht_gas_x86_64.rb

test-gas-mmix-pure: gas-mmix-pure-forth
	$(RUBY) test/test_gas_mmix_pure.rb

test-gas-mmix-c10: gas-mmix-c10-forth
	$(RUBY) test/test_gas_mmix_c10.rb

test-gas-mmix-c11: gas-mmix-c11-forth
	$(RUBY) test/test_gas_mmix_c11.rb

test-ht-gas-mmix-pure: gas-mmix-pure-forth
	$(RUBY) test/test_ht_gas_mmix_pure.rb

test-ht-gas-mmix-c10: gas-mmix-c10-forth
	$(RUBY) test/test_ht_gas_mmix_c10.rb

test-ht-gas-mmix-c11: gas-mmix-c10-forth
	$(RUBY) test/test_ht_gas_mmix_c11.rb

test-gas-arm-a32: gas-arm-a32-forth
	$(RUBY) test/test_gas_arm_a32.rb

test-gas-arm-t32: gas-arm-t32-forth
	$(RUBY) test/test_gas_arm_t32.rb

test-gas-arm-a64: gas-arm-a64-forth
	$(RUBY) test/test_gas_arm_a64.rb

test-ht-gas-arm-a32: gas-arm-a32-forth
	$(RUBY) test/test_ht_gas_arm_a32.rb

test-ht-gas-arm-t32: gas-arm-t32-forth
	$(RUBY) test/test_ht_gas_arm_t32.rb

test-ht-gas-arm-a64: gas-arm-a64-forth
	$(RUBY) test/test_ht_gas_arm_a64.rb

test-gas-mips-32: gas-mips-32-forth
	$(RUBY) test/test_gas_mips_32.rb

test-gas-mips-64: gas-mips-64-forth
	$(RUBY) test/test_gas_mips_64.rb

test-ht-gas-mips-32: gas-mips-32-forth
	$(RUBY) test/test_ht_gas_mips_32.rb

test-ht-gas-mips-64: gas-mips-64-forth
	$(RUBY) test/test_ht_gas_mips_64.rb


test-gas-rv32i: gas-rv32i-forth
	$(RUBY) test/test_gas_rv32i.rb

test-ht-gas-rv32i: gas-rv32i-forth
	$(RUBY) test/test_ht_gas_rv32i.rb

test-gas-rv32ic: gas-rv32ic-forth
	$(RUBY) test/test_gas_rv32ic.rb

test-ht-gas-rv32ic: gas-rv32ic-forth
	$(RUBY) test/test_ht_gas_rv32ic.rb

test-gas-rv32im: gas-rv32im-forth
	$(RUBY) test/test_gas_rv32im.rb

test-ht-gas-rv32im: gas-rv32im-forth
	$(RUBY) test/test_ht_gas_rv32im.rb

test-gas-rv64im: gas-rv64im-forth
	$(RUBY) test/test_gas_rv64im.rb

test-ht-gas-rv64im: gas-rv64im-forth
	$(RUBY) test/test_ht_gas_rv64im.rb


test-cli:
	bin/test_cli

dictdiff:
	bin/test -n test_dict_001 | bin/dictdiff

compile: generated
	bin/gmpfc $(INC) -c forth32.fs

exec: generated
	bin/gmpfc $(INC) -Texec -v -e forth32.fs fig/cold.fs

image32be: src/vm/forth32.fs src/forth-vm.fs src/fig/cold.fs
	bin/gmpfc $(INC) -B$@ -H $^

image32le: src/vm/forth32.fs src/forth-vm.fs src/fig/cold.fs
	bin/gmpfc $(INC) -El -B$@ -H $^

cvm: generated image32le
	$(MAKE) -C cvm

cvm-clean:
	$(MAKE) -C cvm clean

cvm/cvm: cvm

cvm-test: cvm image32le
	$(RUBY) -rproject test/test_cvm.rb

i386-forth: generated
	$(MAKE) -C src/gas/i386 forth

i386-test: test-gas-i386 test-ht-gas-i386

i386-clean:
	$(MAKE) -C src/gas/i386 clean

x86_64-forth: generated
	$(MAKE) -C src/gas/x86_64 forth

x86_64-test: test-gas-x86_64 test-ht-gas-x86_64

x86_64-clean:
	$(MAKE) -C src/gas/x86_64 clean

gas-vm-forth:
	$(MAKE) -C src/gas/vm image.bin

gas-vm-clean:
	$(MAKE) -C src/gas/vm clean

gas-mmix-pure-forth:
	$(MAKE) -C src/gas/mmix/pure

gas-mmix-pure-clean:
	$(MAKE) -C src/gas/mmix/pure clean

gas-mmix-c10-forth:
	$(MAKE) -C src/gas/mmix/c10

gas-mmix-c10-clean:
	$(MAKE) -C src/gas/mmix/c10 clean

gas-mmix-c11-forth:
	$(MAKE) -C src/gas/mmix/c11

gas-mmix-c11-clean:
	$(MAKE) -C src/gas/mmix/c11 clean

gas-arm-a32-forth:
	$(MAKE) -C src/gas/arm/a32

gas-arm-a32-clean:
	$(MAKE) -C src/gas/arm/a32 clean

gas-arm-t32-forth:
	$(MAKE) -C src/gas/arm/t32

gas-arm-t32-clean:
	$(MAKE) -C src/gas/arm/t32 clean

gas-arm-a64-forth:
	$(MAKE) -C src/gas/arm/a64

gas-arm-a64-clean:
	$(MAKE) -C src/gas/arm/a64 clean

gas-mips-32-forth:
	$(MAKE) -C src/gas/mips/32

gas-mips-32-clean:
	$(MAKE) -C src/gas/mips/32 clean

gas-mips-64-forth:
	$(MAKE) -C src/gas/mips/64

gas-mips-64-clean:
	$(MAKE) -C src/gas/mips/64 clean

gas-rv32i-forth:
	$(MAKE) -C src/gas/riscv/rv32i

gas-rv32i-run:
	$(MAKE) -C src/gas/riscv/rv32i run

gas-rv32i-clean:
	$(MAKE) -C src/gas/riscv/rv32i clean

gas-rv32ic-forth:
	$(MAKE) -C src/gas/riscv/rv32ic

gas-rv32ic-run:
	$(MAKE) -C src/gas/riscv/rv32ic run

gas-rv32ic-clean:
	$(MAKE) -C src/gas/riscv/rv32ic clean

gas-rv32im-forth:
	$(MAKE) -C src/gas/riscv/rv32im

gas-rv32im-run:
	$(MAKE) -C src/gas/riscv/rv32im run

gas-rv32im-clean:
	$(MAKE) -C src/gas/riscv/rv32im clean

gas-rv64im-forth:
	$(MAKE) -C src/gas/riscv/rv64im

gas-rv64im-run:
	$(MAKE) -C src/gas/riscv/rv64im run

gas-rv64im-clean:
	$(MAKE) -C src/gas/riscv/rv64im clean

generated: $(GENERATED)

lib: $(LIDX)

%/Library.yaml: %/*.fs
	bin/gmpfc -X $+

lib/gmpforth/ioconstants.rb: src/impl/parameter/io.fs lib/gmpforth/compiler.rb
	bin/gmpfc -c -I. $< --make-constants=$@

include/ioconstants.h: src/impl/parameter/io.fs lib/gmpforth/compiler.rb
	bin/gmpfc -c -I. $< --make-defines=$@

release-test: clean lib $(RELEASE_TESTS)

hayes-test: $(HAYES_TESTS)

coverage: profile_tools vg_tools output $(COV_TARGET)
	-rm -f $(COV_OUTPUT)
	PROFILE=vg/profile PROFILE_OUTPUT=output $(MAKE) $(COV_HAYES_TEST) $(COV_OUTPUT)

profile_tools:
	$(MAKE) -C profile

vg_tools:
	$(MAKE) -C vg

output/COV.i386:
	bin/coverage output/P-i386-*.y > $@

output/COV.x86_64:
	bin/coverage output/P-x86_64-*.y > $@

output:
	mkdir $@

doc:
	$(MAKE) -C doc/manual web

doc-clean:
	$(MAKE) -C doc/manual clean

show_tests:
	@echo $(RELEASE_TESTS) $(HAYES_TESTS)

clean: cvm-clean i386-clean gas-vm-clean x86_64-clean doc-clean \
	gas-mmix-pure-clean gas-mmix-c10-clean gas-mmix-c11-clean \
	gas-arm-a32-clean gas-arm-t32-clean gas-arm-a64-clean \
	gas-mips-32-clean gas-mips-64-clean \
	gas-rv32i-clean gas-rv32ic-clean \
	gas-rv32im-clean gas-rv64im-clean
	-rm -rf $(FILES) $(GENERATED) $(COV_OUTPUT) output

