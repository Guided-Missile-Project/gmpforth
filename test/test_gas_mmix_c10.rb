#
#  test_gas_mmix_c10.rb
# 
#  Copyright (c) 2015 by Daniel Kelley
# 
# gas mmix c10 stack model tests



require 'test/unit'
require 'open3'
require 'noredef'
require 'stackx'
require 'control32'
require 'define32'
require 'fdiv'
require 'parenio'
require 'xdict'
require 'mmixrun'

class Test_gas_mmix_c10 < Test::Unit::TestCase

  MODEL = "c10"

  extend NoRedef
  include Stackx
  include Control32
  include Define32
  include FDiv
  include ParenIO
  include XDict
  include MMIXRun

end
