#
#  hayes_test_i386.rb
# 
#  Copyright (c) 2013 by Daniel Kelley
# 
#  $Id:$
#

module HayesTestI386

  def test_code
    result = ht_run("src/test/impl/i386/code.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_core_ext_ns
    result = ht_run("src/test/annex/core-ext-ns.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_i386_io
    result = ht_run("src/test/impl/i386/io.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_common_io
    result = ht_run("src/test/impl/common/io.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

end
