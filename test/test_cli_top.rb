#
#  test_cli.rb
# 
#  Copyright (c) 2012 by Daniel Kelley
# 
#  $Id:$
#
#

require 'test/unit'
require 'noredef'
require 'rbconfig'
require 'gmpforth'
require 'gmpforth/x86compiler'
require 'gmpforth/vmgascompiler'

class Test_cli_top < Test::Unit::TestCase

  extend NoRedef

  CONFIG = RUBY_VERSION >= "1.9" ? RbConfig::CONFIG : Config::CONFIG

  GMPFORTH_TEST_CLI_OBJ = "/tmp/GMPFORTH_TEST_CLI_OBJ.#{$$}"

  ENV["GMPFORTH_TEST_CLI_OBJ"] = GMPFORTH_TEST_CLI_OBJ

  def ruby
    CONFIG["bindir"] + '/' + CONFIG["ruby_install_name"]
  end

  def cmd(*args)
    s = "#{ruby} test/test_cli.rb "
    if args.length > 0
      s += args.join ' '
    end
    resp = `#{s}`
    robj = Marshal.load(IO.read(GMPFORTH_TEST_CLI_OBJ))
    File.unlink GMPFORTH_TEST_CLI_OBJ
    [resp, robj]
  end

  def test_target_top
    out,c = cmd
    assert($?.success?, out)
  end

  def test_target_0
    ENV["GMPFORTH_TEST_CLI_TGT"] = "-"
    out,c = cmd
    assert($?.success?, out)
    assert_equal(GMPForth::VMCompiler, c)
    ENV.delete("GMPFORTH_TEST_CLI_TGT")
  end

  def test_target_1
    ENV["GMPFORTH_TEST_CLI_TGT"] = "vm"
    out,c = cmd
    assert($?.success?, out)
    assert_equal(GMPForth::VMCompiler, c)
    ENV.delete("GMPFORTH_TEST_CLI_TGT")
  end

  def test_target_2
    ENV["GMPFORTH_TEST_CLI_TGT"] = "x86"
    out,c = cmd
    assert($?.success?, out)
    assert_equal(GMPForth::X86Compiler, c)
    ENV.delete("GMPFORTH_TEST_CLI_TGT")
  end

  def test_target_3
    ENV["GMPFORTH_TEST_CLI_TGT"] = "vmgas"
    out,c = cmd
    assert($?.success?, out)
    assert_equal(GMPForth::VMGASCompiler, c)
    ENV.delete("GMPFORTH_TEST_CLI_TGT")
  end

  # no args
  def test_cli_top_001
    out,c = cmd
    assert($?.success?, out)
    assert_equal(1, c)
  end

  # no op
  def test_cli_top_002
    out,c = cmd "0"
    assert($?.success?, out)
    assert_equal(2, c)
  end

  # help
  def test_cli_top_003
    out,c = cmd "-h"
    assert($?.success?, out)
    assert_equal(0, c)
  end

  # scan
  def test_cli_top_004
    out,c = cmd "-s src/bwr.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::Scanner, c.class)
  end

  # scan
  def test_cli_top_005
    out,c = cmd "-c src/vm/lib/exit.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::VMCompiler, c.class)
  end

  # scan/Dot
  def test_cli_top_006
    out,c = cmd "--dot src/bwr.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::Compiler, c.class)
  end

  # scan/Dep
  def test_cli_top_007
    out,c = cmd "-P src/bwr.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::Compiler, c.class)
  end

  # exec
  def test_cli_top_008
    out,c = cmd "-I. -e src/vm/forth32.fs src/bwr.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::VMCompiler, c.class)
  end

  # exec+heads
  def test_cli_top_009
    out,c = cmd "-H -I. -e src/vm/forth32.fs src/bwr.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::VMCompiler, c.class)
  end

  # x86 compiler
  def test_cli_top_010
    out,c = cmd "-c -H -tx86 -I. src/gas/i386/forth.fs src/bwr.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::X86Compiler, c.class)
  end

  # vmgas compiler
  def test_cli_top_011
    out,c = cmd "-c -H -tvmgas -I. src/vm/forth32.fs src/bwr.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::VMGASCompiler, c.class)
  end

  # scan+be
  def test_cli_top_012
    out,c = cmd "-Eb -c src/vm/lib/exit.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::VMCompiler, c.class)
    assert_equal(true, c.vm.bigendian)
    assert_equal(4, c.vm.databytes)
  end

  # scan+le
  def test_cli_top_013
    out,c = cmd "-El -c src/vm/lib/exit.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::VMCompiler, c.class)
    assert_equal(false, c.vm.bigendian)
    assert_equal(4, c.vm.databytes)
  end

  # scan+le+16bit
  def test_cli_top_014
    out,c = cmd "-El -W2 -c src/vm/lib/exit.fs"
    assert($?.success?, out)
    assert_equal(GMPForth::VMCompiler, c.class)
    assert_equal(false, c.vm.bigendian)
    assert_equal(2, c.vm.databytes)
  end

end
