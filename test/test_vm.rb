#
#  test_vm.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#
# Default 32 bit big-endian VM
#

require 'test/unit'
require 'gmpforth'
require 'gmpforth/cli'
require 'noredef'
require 'vm32'
require 'vmstack'
require 'vmmath'
require 'vmop'

class TestVM < Test::Unit::TestCase

  extend NoRedef
  include VM32
  include VMStack
  include VMMath
  include VMOp

  def setup
    @vm = GMPForth::VM.opt_new GMPForth::CLI::sysopt
  end

end
