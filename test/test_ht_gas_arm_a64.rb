#
#  test_ht_gas_arm_a64.rb
# 
#  Copyright (c) 2015 by Daniel Kelley
# 
#  $Id:$
#

require 'test/unit'
require 'noredef'
require 'hayes_test'
require 'hayes_test_base'
require 'hayes_test_annex'

class Test_HT_GAS_ARM_A64 < Test::Unit::TestCase

  include HayesTest
  include HayesTestBase
  include HayesTestAnnex

  def setup
    @ldelay = 1.0
    @image = "src/gas/arm/a64/forth"
  end

end
