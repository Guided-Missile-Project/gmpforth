#
#  test_ht_gas_mips_64.rb
# 
#  Copyright (c) 2016 by Daniel Kelley
# 
#  $Id:$
#

require 'test/unit'
require 'noredef'
require 'hayes_test'
require 'hayes_test_base'
require 'hayes_test_annex'

class Test_HT_GAS_MIPS_64 < Test::Unit::TestCase

  include HayesTest
  include HayesTestBase
  include HayesTestAnnex

  def setup
    @ldelay = 1.0
    @image = "src/gas/mips/64/forth"
  end

end
