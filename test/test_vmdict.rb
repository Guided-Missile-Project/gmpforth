#
#  test_vmdict.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

require 'test/unit'
require 'gmpforth'
require 'gmpforth/cli'
require 'noredef'
require 'vmdict'

class TestVMDict < Test::Unit::TestCase

  def setup
    @vc = GMPForth::VMCompiler.new GMPForth::CLI::sysopt
    @vc.headless = false
    # make addr 0-3 illegal
    4.times { @vc.vm.asm(:vm_nop) }
    @vc.vm.fence = @vc.vm.dot
    @vc.include('.')
    @vc.scan('src/vm/forth32.fs')
    # minus one / mask with all bits set
    @m1 = @vc.vm.modulus - 1
  end

  extend NoRedef
  include VMDict

end
