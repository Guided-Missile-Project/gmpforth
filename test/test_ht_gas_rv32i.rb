#
#  test_ht_gas_rv32i.rb
#
#  Copyright (c) 2020 by Daniel Kelley
#

require 'test/unit'
require 'noredef'
require 'hayes_test'
require 'hayes_test_base'
require 'hayes_test_annex'

class Test_HT_GAS_RV32I < Test::Unit::TestCase

  include HayesTest
  include HayesTestBase
  include HayesTestAnnex

  def setup
    @ldelay = 1.0
    @image = "src/gas/riscv/rv32i/forth"
  end

end
