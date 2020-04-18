#
#  test_gas_rv32ic.rb
#
#  Copyright (c) 2020 by Daniel Kelley
#
# gas rv32ic c10 stack model tests

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

class Test_gas_rv32ic < Test::Unit::TestCase

  MODEL = "rv32ic"

  extend NoRedef
  include Stackx
  include Control32
  include Define32
  include SDiv
  include ParenIO
  include XDict
  include RISCVRun

end
