#
#  dict64.rb
#
#  Copyright (c) 2016 by Daniel Kelley
#

module Dict64

  extend NoRedef

  def test_dict64_001_01
    n = 0x7fffffffffffffff
    rsp = exec(': test s" '+n.to_s+'" (number?) ;')
    stk = stack(rsp)
    assert_equal([n, 1], stk)
  end

  def test_dict64_001_02
    n = 0x7ffffffffffffff
    rsp = exec(': test s" '+n.to_s+'" (number?) ;')
    stk = stack(rsp)
    assert_equal([n, 1], stk)
  end

  def test_dict64_001_03
    n = 0x7fffffffffffff
    rsp = exec(': test s" '+n.to_s+'" (number?) ;')
    stk = stack(rsp)
    assert_equal([n, 1], stk)
  end

  def test_dict64_001_04
    n = 0x7ffffffffffff
    rsp = exec(': test s" '+n.to_s+'" (number?) ;')
    stk = stack(rsp)
    assert_equal([n, 1], stk)
  end

  def test_dict64_001_05
    n = 0x7fffffffffff
    rsp = exec(': test s" '+n.to_s+'" (number?) ;')
    stk = stack(rsp)
    assert_equal([n, 1], stk)
  end

  def test_dict64_001_06
    n = 0x7ffffffffff
    rsp = exec(': test s" '+n.to_s+'" (number?) ;')
    stk = stack(rsp)
    assert_equal([n, 1], stk)
  end

  def test_dict64_001_07
    n = 0x7fffffffff
    rsp = exec(': test s" '+n.to_s+'" (number?) ;')
    stk = stack(rsp)
    assert_equal([n, 1], stk)
  end

  def test_dict64_001_08
    n = 0x7fffffff
    rsp = exec(': test s" '+n.to_s+'" (number?) ;')
    stk = stack(rsp)
    assert_equal([n, 1], stk)
  end

end
