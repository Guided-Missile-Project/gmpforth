#
#  define32.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

module Define32

  extend NoRedef

# variable
  def test_define32_001_01
    rsp = exec <<EOF
variable x
: test x ;
EOF
    stk = stack(rsp)
    assert_equal(1, stk.length)
    assert_not_equal(0, stk[0])
  end

# create
  def test_define32_002_01
    rsp = exec <<EOF
create x
: test x ;
EOF
    stk = stack(rsp)
    assert_equal(1, stk.length)
    assert_not_equal(0, stk[0])
  end

# constant
  def test_define32_003_01
    rsp = exec <<EOF
10 constant x
: test x ;
EOF
    stk = stack(rsp)
    assert_equal([10], stk)
  end

# c@ c!
  def test_define32_004_01
    rsp = exec <<EOF
variable x
: test 
   x c@ 32 = 
   32 x c! 
   x c@ 32 = 
;
EOF
    stk = stack(rsp)
    assert_equal([0 , -1], stk)
  end

  def test_define32_004_02
    # c@ should not extend sign
    rsp = exec <<EOF
variable x
: test 
   x c@ 160 =
   160 x c!
   x c@ 160 =
;
EOF
    stk = stack(rsp)
    assert_equal([0 , -1], stk)
  end

# @ !
  def test_define32_005_01
    rsp = exec <<EOF
variable x
: test 
   x @ 32 = 
   32 x ! 
   x @ 32 = 
;
EOF
    stk = stack(rsp)
    assert_equal([0 , -1], stk)
  end

# base
  def test_define32_006_01
    rsp = exec ": test base ;"
    stk = stack(rsp)
    assert_equal(1, stk.length)
    assert_not_equal(0, stk)
  end

  def test_define32_006_02
    rsp = exec ": test base @ ;"
    stk = stack(rsp)
    assert_equal([10], stk)
  end

  def test_define32_006_03
    rsp = exec <<EOF
: test 
   base @ 32 = 
   32 base ! 
   base @ 32 = 
;
EOF
    stk = stack(rsp)
    assert_equal([0 , -1], stk)
  end

# cset/creset
  def test_define32_007_01
    rsp = exec <<EOF
variable x
: test 
   x c@ 1 =
   3 x cset
   x c@ 3 =
   1 x creset
   x c@ 2 =
;
EOF
    stk = stack(rsp)
    assert_equal([0 , -1, -1], stk)
  end

# ctoggle
  def test_define32_007_02
    rsp = exec <<EOF
variable x
: test 
   x c@ 1 =
   1 x ctoggle
   x c@ 1 =
   1 x ctoggle
   x c@ 1 =
;
EOF
    stk = stack(rsp)
    assert_equal([0 , -1, 0], stk)
  end

end
