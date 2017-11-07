#
#  test_gas_x86_64.rb
# 
#  Copyright (c) 2015 by Daniel Kelley
# 
# gas x86_64 tests



require 'test/unit'
require 'open3'
require 'noredef'
require 'stackx'
require 'control32'
require 'define32'
require 'sdiv'
# require 'parenio' # not compatible with gdb/mi2
require 'xdict'
require 'x86run'

class Test_gas_x86_64 < Test::Unit::TestCase

  MODEL = "x86_64"

  extend NoRedef
  include Stackx
  include Control32
  include Define32
  include SDiv
  include XDict
  include X86Run

end
