#
#  test_ht_gas_i386.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

require 'test/unit'
require 'noredef'
require 'hayes_test'
require 'hayes_test_base'
require 'hayes_test_i386'
require 'hayes_test_annex'
require 'hayes_test_io'

class Test_HT_GAS_i386 < Test::Unit::TestCase

  include HayesTest
  include HayesTestBase
  include HayesTestI386
  include HayesTestAnnex
  include HayesTestIO

  def setup
    @ldelay = 0.001
    @image = "src/gas/i386/forth"
  end

end
