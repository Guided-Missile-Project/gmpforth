#
#  hayes_test_base.rb
#
#  Copyright (c) 2014 by Daniel Kelley
#
#  Tests for base words
#
#

module HayesTestBase

  def test_base_core
    result = ht_run("src/test/hayes/core.fr")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_base_core_plus
    result = ht_run("src/test/hayes/coreplustest.fth")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_base_core_ext
    result = ht_run("src/test/base/core-ext.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_base_core_misc
    result = ht_run("src/test/base/core-misc.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_base_impl
    result = ht_run("src/test/base/impl.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_base_double
    result = ht_run("src/test/base/double.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_base_tools_ext
    result = ht_run("src/test/base/tools-ext.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_base_search
    result = ht_run("src/test/base/search.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

end
