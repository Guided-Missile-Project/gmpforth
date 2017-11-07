#
#  control32.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

module Control32

  extend NoRedef

# if else then
  def test_control32_001_01
    rsp = exec(": test 1 0 if 1 then ;")
    stk = stack(rsp)
    assert_equal([1], stk)
  end

  def test_control32_001_02
    rsp = exec(": test 2 1 if 1 then ;")
    stk = stack(rsp)
    assert_equal([2, 1], stk)
  end

  def test_control32_001_03
    rsp = exec(": test 2 0 if 1 else 3 then ;")
    stk = stack(rsp)
    assert_equal([2, 3], stk)
  end

  def test_control32_001_04
    rsp = exec(": test 2 1 if 4 else 3 then ;")
    stk = stack(rsp)
    assert_equal([2, 4], stk)
  end

# exit
  def test_control32_002_01
    rsp = exec(": test 1 2 exit 3 4 ;")
    stk = stack(rsp)
    assert_equal([1, 2], stk)
  end

  def test_control32_003_01
    rsp = exec(": test 0 begin dup 3 < while 1+ repeat ;")
    stk = stack(rsp)
    assert_equal([3], stk)
  end

# begin while repeat
  def test_control32_003_02
    rsp = exec(": test 0 begin dup 0< while 1+ repeat ;")
    stk = stack(rsp)
    assert_equal([0], stk)
  end

  def test_control32_003_03
    rsp = exec <<EOF
: test 0 begin s" this" drop drop dup 0< while 1+ s" 1234567" drop drop repeat ;
EOF
    stk = stack(rsp)
    assert_equal([0], stk)
  end

  def test_control32_003_04
    rsp = exec <<EOF
: test 0 begin s" this" drop drop dup 0< while 1+ s" 1234567" drop drop repeat ;
EOF
    stk = stack(rsp)
    assert_equal([0], stk)
  end

# do i j loop
  def test_control32_004_01
    rsp = exec(": test 1 2 0 do 3 + loop ;")
    stk = stack(rsp)
    assert_equal([7], stk)
  end

  def test_control32_004_02
    rsp = exec(": test 5 0 do i loop ;")
    stk = stack(rsp)
    assert_equal([0,1,2,3,4], stk)
  end

  def test_control32_004_03
    rsp = exec(": test 2 0 do 2 0 do i j loop loop ;")
    stk = stack(rsp)
    assert_equal([0,0,1,0,0,1,1,1], stk)
  end

# do unloop loop
  def test_control32_005_01
    rsp = exec(": test -4 10 0 do dup 1 > if unloop exit then 1+ loop 1+ ;")
    stk = stack(rsp)
    assert_equal([2], stk)
  end

# do leave loop
  def test_control32_006_01
    rsp = exec(": test -4 10 0 do dup 1 > if leave then 1+ loop 1+ ;")
    stk = stack(rsp)
    assert_equal([3], stk)
  end

# do leave loop - should loop more than once if index and limit are equal
  def test_control32_006_02
    rsp = exec(": test 0 2 2 do 1+ dup 9 > if leave then loop ;")
    stk = stack(rsp)
    assert_equal([10], stk)
  end

# do ?leave loop
  def test_control32_006_03
    rsp = exec(": test -4 10 0 do dup 1 > ?leave 1+ loop 1+ ;")
    stk = stack(rsp)
    assert_equal([3], stk)
  end

# do +loop
  def test_control32_007_01
    rsp = exec(": test 1 10 0 do 3 + 3 +loop ;")
    stk = stack(rsp)
    assert_equal([13], stk)
  end

  def test_control32_007_02
    rsp = exec(": test 15 0 do i 3 +loop ;")
    stk = stack(rsp)
    assert_equal([0,3,6,9,12], stk)
  end

  def test_control32_007_03
    rsp = exec(": test 0 3 do i -1 +loop ;")
    stk = stack(rsp)
    assert_equal([3,2,1,0], stk)
  end

  # handle entire unsigned index range with very large increments
  def test_control32_007_04
    rsp = exec(": test 0 -1 0 do 1+ -1 2 rshift 1+ +loop ;")
    stk = stack(rsp)
    assert_equal([4], stk)
  end

  def test_control32_007_05
    rsp = exec(": test 0 0 -1 do 1+ -1 2 rshift 1+ negate +loop ;")
    stk = stack(rsp)
    assert_equal([4], stk)
  end

# do unloop +loop
  def test_control32_008_01
    rsp = exec(": test 4 9 0 do dup 5 > if unloop exit then 1+ 2 +loop 1+ ;")
    stk = stack(rsp)
    assert_equal([6], stk)
  end

# do leave +loop
  def test_control32_009_01
    rsp = exec(": test 4 9 0 do dup 5 > if leave then 1+ 2 +loop 1+ ;")
    stk = stack(rsp)
    assert_equal([7], stk)
  end

  def test_control32_009_02
    rsp = exec(": test 0 9 0 do dup 5 > if leave then 1+ 0 +loop 1+ ;")
    stk = stack(rsp)
    assert_equal([7], stk)
  end

# ?do +loop
  def test_control32_010_01
    rsp = exec(": test 1 10 0 ?do 3 + 3 +loop ;")
    stk = stack(rsp)
    assert_equal([13], stk)
  end

  def test_control32_010_02
    rsp = exec(": test 1 0 0 ?do 3 + 3 +loop ;")
    stk = stack(rsp)
    assert_equal([1], stk)
  end

  def test_control32_010_03
    rsp = exec(": test 6 10 ?do i -1 +loop ;")
    stk = stack(rsp)
    assert_equal([10,9,8,7,6], stk)
  end

# ?do unloop +loop
  def test_control32_011_01
    rsp = exec(": test 4 9 0 ?do dup 5 > if unloop exit then 1+ 2 +loop 1+ ;")
    stk = stack(rsp)
    assert_equal([6], stk)
  end

  def test_control32_011_02
    rsp = exec(": test 4 9 9 ?do dup 5 > if unloop exit then 1+ 2 +loop 1+ ;")
    stk = stack(rsp)
    assert_equal([5], stk)
  end

# ?do leave +loop
  def test_control32_012_01
    rsp = exec(": test 4 9 0 ?do dup 5 > if leave then 1+ 2 +loop 1+ ;")
    stk = stack(rsp)
    assert_equal([7], stk)
  end

  def test_control32_012_02
    rsp = exec(": test 4 -5 -5 ?do dup 5 > if leave then 1+ 2 +loop 1+ ;")
    stk = stack(rsp)
    assert_equal([5], stk)
  end

# execute
  def test_control32_013_01
    rsp = exec <<EOF
    : test1 1 2 3 ;
    : test ['] test1 execute ;
EOF
    stk = stack(rsp)
    assert_equal([1,2,3], stk)
  end

# (s")
  def test_control32_014_01
    rsp = exec(': test s" " 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(0, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_02
    rsp = exec(': test s" a" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(1, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_03
    rsp = exec(': test s" ab" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(2, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_04
    rsp = exec(': test s" abc" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(3, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_05
    rsp = exec(': test s" abcd" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(4, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_06
    rsp = exec(': test s" abcde" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(5, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_07
    rsp = exec(': test s" abcdef" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(6, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_08
    rsp = exec(': test s" abcdefg" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(7, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_09
    rsp = exec(': test s" abcdefgh" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(8, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_10
    rsp = exec(': test s" abcdefghi" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(9, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_11
    rsp = exec(': test s" abcdefghij" 10 ;')
    stk = stack(rsp)
    assert_equal(3, stk.length)
    assert_not_equal(0, stk[0])
    assert_equal(10, stk[1])
    assert_equal(10, stk[2])
  end

  def test_control32_014_11_01
    rsp = exec(': test s" abcdefghij" drop c@ ;')
    stk = stack(rsp)
    assert_equal(1, stk.length)
    assert_equal(97, stk[0])
  end

  def test_control32_014_11_02
    rsp = exec(': test s" abcdefghij" drop 4 + c@ ;')
    stk = stack(rsp)
    assert_equal(1, stk.length)
    assert_equal(97+4, stk[0])
  end

  def test_control32_014_11_03
    rsp = exec(': test s" abcdefghij" drop 9 + c@ ;')
    stk = stack(rsp)
    assert_equal(1, stk.length)
    assert_equal(97+9, stk[0])
  end


end
