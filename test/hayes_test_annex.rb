#
#  hayes_test_annex.rb
#
#  Copyright (c) 2014 by Daniel Kelley
#

module HayesTestAnnex

  def test_annex_f83
    result = ht_run("src/test/annex/f83.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_annex_core_ext
    result = ht_run("src/test/annex/core-ext.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_annex_core_ext_2
    result = ht_run("src/test/hayes/coreexttest.fth")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_annex_tools
    result = ht_run("src/test/annex/tools.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_annex_tools_ext
    result = ht_run("src/test/annex/tools-ext.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_annex_double_1
    result = ht_run("src/test/annex/double.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_annex_double_2
    result = ht_run("src/test/hayes/doubletest.fth")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_annex_double_ext
    result = ht_run("src/test/annex/double-ext.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_annex_search
    result = ht_run("src/test/hayes/searchordertest.fth")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_annex_impl
    result = ht_run("src/test/annex/impl.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

end

