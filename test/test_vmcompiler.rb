#
#  test_vmcompiler.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# 

require 'test/unit'
require 'gmpforth'
require 'gmpforth/cli'
require 'noredef'
require 'vm32'
require 'vmcompiler'
require 'vmoptimizer'

class TestVMCompiler < Test::Unit::TestCase

  def setup
    @vc = GMPForth::VMCompiler.new GMPForth::CLI::sysopt
    # make addr 0-3 illegal
    4.times { @vc.vm.asm(:vm_nop) }
    @vc.vm.fence = @vc.vm.dot
    @vc.include('.')
    @vc.scan('src/vm/forth32.fs')
    # minus one / mask with all bits set
    @m1 = @vc.vm.modulus - 1
    # largest negative
    @m = @vc.vm.modulus / 2
    # largest positive
    @n = @m-1
    # largest double negative
    @mm = 2 ** (@vc.vm.databits * 2 - 1)
    # largest double positive
    @nn = @mm-1
  end

  extend NoRedef
  include VMCompiler
  include VMOptimizer

end
