#
#  test_ht_gas_x86_64.rb
# 
#  Copyright (c) 2013 by Daniel Kelley
# 
#  $Id:$
#

require 'test/unit'
require 'noredef'
require 'hayes_test'
require 'hayes_test_base'
require 'hayes_test_x86_64'
require 'hayes_test_annex'
require 'hayes_test_io'

class Test_HT_GAS_x86_64 < Test::Unit::TestCase

  include HayesTest
  include HayesTestBase
  include HayesTestX86_64
  include HayesTestAnnex
  include HayesTestIO

  def setup
    @ldelay = 0.001
    @image = "src/gas/x86_64/forth"
  end

end
