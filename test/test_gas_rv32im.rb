#
#  test_gas_rv32im.rb
#
#  Copyright (c) 2020 by Daniel Kelley
#
# gas rv32im c10 stack model tests

require 'test/unit'
require 'open3'
require 'noredef'
require 'stackx'
require 'control32'
require 'define32'
require 'sdiv'
require 'parenio'
require 'xdict'
require 'riscvrun'

class Test_gas_rv32im < Test::Unit::TestCase

  MODEL = "rv32im"

  extend NoRedef
  include Stackx
  include Control32
  include Define32
  include SDiv
  include ParenIO
  include XDict
  include RISCVRun

end
