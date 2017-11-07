#
#  hayes_test_io.rb
#
#  Copyright (c) 2014 by Daniel Kelley
#

module HayesTestIO

  def test_io_impl
    result = ht_run("src/test/io/impl.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

  def test_io_file
    result = ht_run("src/test/io/file.fs")
    assert_equal(false, @fault)
    assert_equal(true, @end_of_test)
    assert_equal([], result)
  end

end
