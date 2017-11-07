#
#  hayes_test_cvm.rb
# 
#  Copyright (c) 2013 by Daniel Kelley
# 
#  $Id:$
#

module HayesTestCVM

  def test_code
    result = ht_run("src/test/impl/vm/code.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

end
