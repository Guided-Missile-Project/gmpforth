#
#  test_gas_mips_32.rb
# 
#  Copyright (c) 2015 by Daniel Kelley
# 
# gas mips/32 tests

require 'test/unit'
require 'open3'
require 'noredef'
require 'stackx'
require 'control32'
require 'define32'
require 'sdiv'
require 'parenio'
require 'xdict'
require 'mipsrun'

class Test_gas_mips_32 < Test::Unit::TestCase

  MODEL = "32"

  extend NoRedef
  include Stackx
  include Control32
  include Define32
  include SDiv
  include ParenIO
  include XDict
  include MIPSRun

end
