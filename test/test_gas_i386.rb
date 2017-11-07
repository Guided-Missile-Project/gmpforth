#
#  test_gas_i386.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# gas i386 tests



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

class Test_gas_i386 < Test::Unit::TestCase

  MODEL = "i386"

  extend NoRedef
  include Stackx
  include Control32
  include Define32
  include SDiv
  include XDict
  include X86Run

end
