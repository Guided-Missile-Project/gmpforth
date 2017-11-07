#
#  test_gas_mips_64.rb
# 
#  Copyright (c) 2016 by Daniel Kelley
# 
# gas mips/64 tests

require 'test/unit'
require 'open3'
require 'noredef'
require 'stackx'
require 'stack64'
require 'control32'
require 'define32'
require 'sdiv'
require 'parenio'
require 'xdict'
require 'dict64'
require 'mipsrun'

class Test_gas_mips_64 < Test::Unit::TestCase

  MODEL = "64"
  LIBS = ["src/gas/mips/32/lib"]

  extend NoRedef
  include Stackx
  include Stack64
  include Control32
  include Define32
  include SDiv
  include ParenIO
  include XDict
  include Dict64
  include MIPSRun

end
