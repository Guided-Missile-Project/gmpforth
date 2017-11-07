#
#  fdiv.rb
#
#  Copyright (c) 2015 by Daniel Kelley
#

#  Architecture width independent floored division tests

module FDiv

  extend NoRedef

# star_slash_mod
  def test_fdiv_star_slash_mod_001
    rsp = exec(": test -2 -5 7 */mod ;")
    stk = stack(rsp)
    assert_equal([3, 1], stk)
  end

  def test_fdiv_star_slash_mod_002
    rsp = exec(": test -2 5 7 */mod ;")
    stk = stack(rsp)
    assert_equal([4, -2], stk)
  end

  def test_fdiv_star_slash_mod_003
    rsp = exec(": test 2 -5 7 */mod ;")
    stk = stack(rsp)
    assert_equal([4, -2], stk)
  end

  def test_fdiv_star_slash_mod_004
    rsp = exec(": test 2 5 -7 */mod ;")
    stk = stack(rsp)
    assert_equal([-4, -2], stk)
  end

  def test_fdiv_star_slash_mod_005
    rsp = exec(": test -2 -5 -7 */mod ;")
    stk = stack(rsp)
    assert_equal([-4, -2], stk)
  end

  def test_fdiv_star_slash_mod_006
    rsp = exec(": test -2 5 -7 */mod ;")
    stk = stack(rsp)
    assert_equal([-3, 1], stk)
  end

  def test_fdiv_star_slash_mod_007
    rsp = exec(": test 2 -5 -7 */mod ;")
    stk = stack(rsp)
    assert_equal([-3, 1], stk)
  end

# star_slash
  def test_fdiv_star_slash_001
    rsp = exec(": test -2 -5 7 */ ;")
    stk = stack(rsp)
    assert_equal([1], stk)
  end

  def test_fdiv_star_slash_002
    rsp = exec(": test -2 5 7 */ ;")
    stk = stack(rsp)
    assert_equal([-2], stk)
  end

  def test_fdiv_star_slash_003
    rsp = exec(": test 2 -5 7 */ ;")
    stk = stack(rsp)
    assert_equal([-2], stk)
  end

  def test_fdiv_star_slash_004
    rsp = exec(": test 2 5 -7 */ ;")
    stk = stack(rsp)
    assert_equal([-2], stk)
  end

  def test_fdiv_star_slash_005
    rsp = exec(": test -2 -5 -7 */ ;")
    stk = stack(rsp)
    assert_equal([-2], stk)
  end

  def test_fdiv_star_slash_006
    rsp = exec(": test -2 5 -7 */ ;")
    stk = stack(rsp)
    assert_equal([1], stk)
  end

  def test_fdiv_star_slash_007
    rsp = exec(": test 2 -5 -7 */ ;")
    stk = stack(rsp)
    assert_equal([1], stk)
  end

end

