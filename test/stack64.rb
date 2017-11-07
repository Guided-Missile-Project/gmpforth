#
#  stack64.rb
#
#  Copyright (c) 2016 by Daniel Kelley
#

module Stack64

  extend NoRedef

  def test_stack64_000
    n = 0xffffffffffffffff
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([-1], stk)
  end

  def test_stack64_001
    n = 0xffffffffffffff
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack64_002
    n = 100000000
    rsp = exec(": test #{n} dup * ;")
    stk = stack(rsp)
    assert_equal([n*n], stk)
  end

  def test_stack64_003
    n = 100000000
    rsp = exec(": test #{n} pad ! pad @ ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack64_004
    n = 0xfffffffffffffff
    rsp = exec(": test #{n} dup um* ;")
    stk = stack(rsp)
    assert_equal([signed(0xE000000000000001),0xFFFFFFFFFFFFFF], stk)
  end

end
