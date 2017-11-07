#
#  test_gas_arm_t32.rb
# 
#  Copyright (c) 2015 by Daniel Kelley
# 
# gas mmix pure stack model tests



require 'test/unit'
require 'open3'
require 'noredef'
require 'stackx'
require 'control32'
require 'define32'
require 'sdiv'
require 'parenio'
require 'xdict'
require 'armrun'

class Test_gas_arm_t32 < Test::Unit::TestCase

  MODEL = "t32"
  LIBS = ["src/gas/arm/a32/lib"]

  extend NoRedef
  include Stackx
  include Control32
  include Define32
  include SDiv
  include ParenIO
  include XDict
  include ARMRun

end
