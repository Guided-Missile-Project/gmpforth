#
#  test_binary_long_division.rb
#
#  Copyright (c) 2016 by Daniel Kelley
#
#

require 'test/unit'
require 'noredef'
require 'pp'
require 'binary-long-division'

class TestBinaryLongDivision < Test::Unit::TestCase

  extend NoRedef

  # constructor, internal functions
  def test_bld_000
    b = 64
    d = BinaryLongDivision.new(b)
    assert_equal(32,d.clz(0xffffffff))
    assert_equal(64,d.clz(0))
    assert_equal(63,d.clz(1))
    assert_equal(0xfefefefe,d.lo(0xfefefefefefefefe))
  end

  # simple no remainder
  def test_bld_001
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div(10,2) { |q| pp(q) }
    assert_equal([5,0],a)
  end

  # simple, remainder
  def test_bld_002
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div(10,3) { |q| pp(q) }
    assert_equal([3,1],a)
  end

  # restoring algorithm
  def test_bld_003
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_no_x(10,2)
    assert_equal([5,0],a)
    a = d.div_no_x(10,3)
    assert_equal([3,1],a)
  end

  # divisor equal to dividend
  def test_bld_004
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div(10,10)
    assert_equal([1,0],a)
  end

  # divisor greater than dividend
  def test_bld_005
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div(10,110)
    assert_equal([0,110],a)
    a = d.div(10,11)
    assert_equal([0,11],a)
  end

  # division by zero
  def test_bld_006
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div(0,0)
    assert_equal([0,0],a)
    a = d.div(10,0)
    assert_equal([0,0],a)
  end

  # large division
  def test_bld_007
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div(0x800000007,9)
    assert_equal([3817748708,3],a)
  end

  # simple no remainder
  def test_bld_hpr_001
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_h_p_r(10,2) { |q| pp(q) }
    assert_equal([5,0],a)
  end

  # simple, remainder
  def test_bld_hpr_002
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_h_p_r(10,3) { |q| pp(q) }
    assert_equal([3,1],a)
  end

  # large division
  def test_bld_hpr_007
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_h_p_r(0x800000007,9)
    assert_equal([3817748708,3],a)
  end

  # simple no remainder
  def off_test_bld_hpnr_001
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_h_p_nr(10,2) { |q| pp(q) }
    assert_equal([5,0],a)
  end

  # simple, remainder
  def off_test_bld_hpnr_002
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_h_p_nr(10,3) { |q| pp(q) }
    assert_equal([3,1],a)
  end

  # large division
  def off_test_bld_hpnr_007
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_h_p_nr(0x800000007,9)
    assert_equal([3817748708,3],a)
  end

  # simple no remainder
  def off_test_bld_hpr2_001
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_h_p_r2(10,2) { |q| pp(q) }
    assert_equal([5,0],a)
  end

  # simple, remainder
  def off_test_bld_hpr2_002
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_h_p_r2(10,3) { |q| pp(q) }
    assert_equal([3,1],a)
  end

  # large division
  def off_test_bld_hpr2_007
    b = 64
    d = BinaryLongDivision.new(b)
    a = d.div_h_p_r2(0x800000007,9)
    assert_equal([3817748708,3],a)
  end

end
