#
#  parenio.rb
#
#  Copyright (c) 2015 by Daniel Kelley
#
#

module ParenIO

  extend NoRedef

  def test_parenio_000
    n = 64
    rsp = exec(": test [char] @ dup -4 (io) ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_parenio_001
    # -1 is unimplemented: returns false
    rsp = exec(": test -1 (io) ;")
    stk = stack(rsp)
    assert_equal([0], stk)
  end

  def test_parenio_002
    # -7 IO_RX_QUESTION returns true
    rsp = exec(": test -7 (io) ;")
    stk = stack(rsp)
    assert_equal([-1], stk)
  end

  def test_parenio_003
    # -3 IO_MEM_LIMIT returns non-zero
    rsp = exec(": test -3 (io) ;")
    stk = stack(rsp)
    assert_not_equal([0], stk)
  end

  def test_parenio_004
    # -3 IO_MEM_LIMIT > HERE
    rsp = exec(": test -3 (io) here > ;")
    stk = stack(rsp)
    assert_equal([-1], stk)
  end

end
