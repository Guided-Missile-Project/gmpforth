#
#  test_gas_rv32i.rb
#
#  Copyright (c) 2020 by Daniel Kelley
#
# gas rv32i c10 stack model tests

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

class Test_gas_rv32i < Test::Unit::TestCase

  MODEL = "rv32i"

  extend NoRedef
  include Stackx
  include Control32
  include Define32
  include SDiv
  include ParenIO
  include XDict
  include RISCVRun

end
