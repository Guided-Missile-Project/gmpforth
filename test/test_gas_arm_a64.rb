#
#  test_gas_arm_a64.rb
# 
#  Copyright (c) 2015 by Daniel Kelley
# 
# gas mmix pure stack model tests



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
require 'armrun'

class Test_gas_arm_a64 < Test::Unit::TestCase

  MODEL = "a64"
  LIBS = ["src/gas/arm/a32/lib"]

  extend NoRedef
  include Stackx
  include Stack64
  include Control32
  include Define32
  include SDiv
  include ParenIO
  include XDict
  include Dict64
  include ARMRun

end
