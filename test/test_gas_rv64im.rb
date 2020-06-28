#
#  test_gas_rv64im.rb
#
#  Copyright (c) 2020 by Daniel Kelley
#
# gas rv64im c10 stack model tests

require 'test/unit'
require 'open3'
require 'noredef'
require 'stackx'
require 'control32'
require 'define32'
require 'sdiv'
require 'parenio'
require 'xdict'
require 'dict64'
require 'riscvrun'

class Test_gas_rv64im < Test::Unit::TestCase

  MODEL = "rv64im"

  extend NoRedef
  include Stackx
  include Control32
  include Define32
  include SDiv
  include ParenIO
  include XDict
  include Dict64
  include RISCVRun

end
