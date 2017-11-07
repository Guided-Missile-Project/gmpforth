#
#  test_ht_gas_vm.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

require 'test/unit'
require 'noredef'
require 'bogomips'
require 'hayes_test'
require 'hayes_test_base'
require 'hayes_test_cvm'
require 'hayes_test_annex'

class Test_HT_CVM < Test::Unit::TestCase

  include HayesTest
  include HayesTestBase
  include HayesTestCVM
  include HayesTestAnnex

  def setup
    @ldelay = 500.0/bogomips
    @image = "cvm/cvm -b src/gas/vm/image.bin"
  end

end
