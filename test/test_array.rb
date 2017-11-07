#
#  test_array.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# test array extensions

require 'test/unit'
require 'noredef'
require 'array/sub'

class Test_array < Test::Unit::TestCase

  extend NoRedef

  # no subst
  def test_001
    a = [1,2,3]
    b = a.sub([4],[5])
    assert_equal(a,b)
  end

  # sub beginning same size
  def test_002
    a = [1,2,3]
    b = a.sub([1],[2])
    assert_equal([2,2,3],b)
  end

  # sub middle same size
  def test_003
    a = [1,2,3]
    b = a.sub([2],[3])
    assert_equal([1,3,3],b)
  end

  # sub end same size
  def test_004
    a = [1,2,3]
    b = a.sub([3],[1])
    assert_equal([1,2,1],b)
  end

  # sub beginning, shrink
  def test_005
    a = [1,2,3]
    b = a.sub([1,2],[2])
    assert_equal([2,3],b)
  end

  # sub end, grow
  def test_006
    a = [1,2,3]
    b = a.sub([2,3],[4,5,6])
    assert_equal([1,4,5,6],b)
  end

  # sub end, shrink
  def test_007
    a = [1,2,3]
    b = a.sub([2,3],[1])
    assert_equal([1,1],b)
  end

  # no sub
  def test_008
    a = [1,2,3]
    b = a.sub([1,3],[1])
    assert_equal(a,b)
  end

  # sub! beginning shrink
  def test_009
    a = [1,2,3]
    y = a.sub!([1,2],[2])
    assert_equal([2,3],y)
    assert_equal([2,3],a)
  end

  # no sub!
  def test_010
    a = [1,2,3]
    y = a.sub!([4],[5,6])
    assert_equal(nil,y)
    assert_equal([1,2,3],a)
  end

  # sub beginning, grow
  def test_011
    a = [1,2,3]
    b = a.sub([1,2],[4,5,6])
    assert_equal([4,5,6,3],b)
  end

  # sub all, same
  def test_012
    a = [1,2,3]
    b = a.sub([1,2,3],[4,5,6])
    assert_equal([4,5,6],b)
  end

  # sub all, shrink
  def test_013
    a = [1,2,3]
    b = a.sub([1,2,3],[])
    assert_equal([],b)
  end

  # sub all, grow
  def test_014
    a = [1,2,3]
    b = a.sub([1,2,3],[4,5,6,7,8,9])
    assert_equal([4,5,6,7,8,9],b)
  end

  # sub mid, same
  def test_015
    a = [1,2,3,4]
    b = a.sub([2,3],[4,5])
    assert_equal([1,4,5,4],b)
  end

  # sub mid, shrink
  def test_016
    a = [1,2,3,4]
    b = a.sub([2,3],[2])
    assert_equal([1,2,4],b)
  end

  # sub mid, grow
  def test_017
    a = [1,2,3,4]
    b = a.sub([2,3],[4,5,6])
    assert_equal([1,4,5,6,4],b)
  end

  # no sub overlap end
  def test_018
    a = [1,2,3,4]
    b = a.sub([3,4,5],[4,5,6])
    assert_equal(a,b)
  end

  # gsub! beginning shrink
  def test_019
    a = [1,2,3]
    y = a.gsub!([1,2],[2])
    assert_equal([2,3],y)
    assert_equal([2,3],a)
  end

  # no gsub!
  def test_020
    a = [1,2,3]
    y = a.gsub!([4],[5,6])
    assert_equal(nil,y)
    assert_equal([1,2,3],a)
  end

  # gsub! multiple subs
  def test_021
    a = [1,2,3,1,1,2,3,4,1,2,1,1,2]
    c = [2,3,2,3,4,2,2]
    y = a.gsub!([1,2],[2])
    assert_equal(c,y)
    assert_equal(c,a)
  end

  def test_022
    a = [2, 3, 1, 1, 2, 3, 4, 1, 2, 1, 1, 2]
    b = [2, 3, 1,    2, 3, 4, 1, 2, 1, 1, 2]
    y = a.sub([1,2],[2])
    assert_equal(b,y)
  end

end
