#
#  stack32.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# 

module Stack32

  extend NoRedef

  def test_stack32_000
    n = 0
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_01
    n = 1
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_02
    n = 2
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_03
    n = 4
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_04
    n = 7
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_05
    n = -1
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_06
    n = -2
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_07
    n = -4
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_08
    n = -7
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_09
    n = -8
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_10
    n = 2**4
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_11
    n = 2**5
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_12
    n = 2**6
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_37
    n = -2**4
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_38
    n = -2**5
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_39
    n = -2**6
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_65
    n = (2**5)-1
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_66
    n = (2**6)-1
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_67
    n = (2**7)-1
    rsp = exec(": test #{n} ;")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_stack32_000_200
    n = 1
    rsp = exec(": test #{n}. ;")
    stk = stack(rsp)
    assert_equal([n, 0], stk)
  end

  def test_stack32_000_201
    n = -1
    rsp = exec(": test #{n}. ;")
    stk = stack(rsp)
    assert_equal([n, n], stk)
  end

  def test_stack32_001
    rsp = exec(": test 1 2 ;")
    stk = stack(rsp)
    assert_equal([1, 2], stk)
  end

# swap
  def test_stack32_002
    rsp = exec(": test 1 2 swap ;")
    stk = stack(rsp)
    assert_equal([2, 1], stk)
  end

# dup
  def test_stack32_003
    rsp = exec(": test 1 dup ;")
    stk = stack(rsp)
    assert_equal([1, 1], stk)
  end

# over
  def test_stack32_004
    rsp = exec(": test 1 2 over ;")
    stk = stack(rsp)
    assert_equal([1, 2, 1], stk)
  end

# rot
  def test_stack32_005
    rsp = exec(": test 1 2 3 rot ;")
    stk = stack(rsp)
    assert_equal([2, 3, 1], stk)
  end

# dash_rot
  def test_stack32_006
    rsp = exec(": test 1 2 3 -rot ;")
    stk = stack(rsp)
    assert_equal([3, 1, 2], stk)
  end

# roll
  def test_stack32_007_1
    rsp = exec(": test 1 2 3 4 3 roll ;")
    stk = stack(rsp)
    assert_equal([2, 3, 4, 1], stk)
  end

  def test_stack32_007_2
    rsp = exec(": test 1 2 3 4 -3 roll ;")
    stk = stack(rsp)
    assert_equal([4, 1, 2, 3], stk)
  end

  def test_stack32_007_3
    rsp = exec(": test 1 2 3 4 0 roll ;")
    stk = stack(rsp)
    assert_equal([1, 2, 3, 4], stk)
  end

  def test_stack32_007_4
    rsp = exec(": test 1 2 3 4 1 roll ;")
    stk = stack(rsp)
    assert_equal([1, 2, 4, 3], stk)
  end

# pick
  def test_stack32_011_1
    rsp = exec(": test 1 2 3 0 pick ;")
    stk = stack(rsp)
    assert_equal([1, 2, 3, 3], stk)
  end

  def test_stack32_011_2
    rsp = exec(": test 1 2 3 1 pick ;")
    stk = stack(rsp)
    assert_equal([1, 2, 3, 2], stk)
  end

  def test_stack32_011_3
    rsp = exec(": test 1 2 3 2 pick ;")
    stk = stack(rsp)
    assert_equal([1, 2, 3, 1], stk)
  end

# two_star
  def test_stack32_012
    rsp = exec(": test 4 2* ;")
    stk = stack(rsp)
    assert_equal([8], stk)
  end

# two_slash
  def test_stack32_013
    rsp = exec(": test 4 2/ ;")
    stk = stack(rsp)
    assert_equal([2], stk)
  end

  def test_stack32_013_1
    rsp = exec(": test -1 2/ ;")
    stk = stack(rsp)
    assert_equal([-1], stk)
  end

# depth - no kernel, may need user
  def off_test_stack32_014
    rsp = exec(": test 2 4 6 depth ;")
    stk = stack(rsp)
    assert_equal([2, 4, 6, 3], stk)
  end

# d_plus
  def test_stack32_015
    rsp = exec(": test 2 3 1 2 d+ ;")
    stk = stack(rsp)
    assert_equal([3, 5], stk)
  end

# d_minus
  def test_stack32_016
    rsp = exec(": test 2 4 1 2 d- ;")
    stk = stack(rsp)
    assert_equal([1, 2], stk)
  end

# um_star
  def test_stack32_017
    rsp = exec(": test 5 7 um* ;")
    stk = stack(rsp)
    assert_equal([35, 0], stk)
  end

# star_slash
  def test_stack32_018
    rsp = exec(": test 2 5 3 */ ;")
    stk = stack(rsp)
    assert_equal([3], stk)
  end

# star_slash_mod
  def test_stack32_019
    rsp = exec(": test 2 5 3 */mod ;")
    stk = stack(rsp)
    assert_equal([1, 3], stk)
  end

# slash
  def test_stack32_020
    rsp = exec(": test 10 3 / ;")
    stk = stack(rsp)
    assert_equal([3], stk)
  end

# slash_mod
  def test_stack32_021
    rsp = exec(": test 10 3 /mod ;")
    stk = stack(rsp)
    assert_equal([1, 3], stk)
  end

# u_two_slash
  def test_stack32_022
    rsp = exec(": test 4 u2/ ;")
    stk = stack(rsp)
    assert_equal([2], stk)
  end

  def test_stack32_022_1
    rsp = exec(": test -1 u2/ ;")
    stk = stack(rsp)
    assert_equal([2147483647], stk)
  end

# *
  def test_stack32_023
    n2 = signed((@n*@n)     & @m1)
    n3 = signed(((@n+1)*@n) & @m1)
    n4 = signed(((@n+2)*@n) & @m1)

    rsp = exec <<EOF
: test
  #{@n} #{@n+2} *
  #{@n}   #{@n} *
  #{@n}       1 *
  #{@n}       0 *
  #{@n} #{@n+1} *
      1      -1 *
     -1       1 *
     -2      -2 * 
;
EOF
    stk = stack(rsp)
    assert_equal([n4, n2, @n, 0, n3, -1, -1, 4], stk)
  end

# +
  def test_stack32_024
    rsp = exec <<EOF
: test
  #{@n} 1 +
  0 0 +
  0 1 +
  1 0 +
 -1 1 +
 -2 -2 +
;
EOF
    stk = stack(rsp)
    assert_equal([signed(@n+1), 0, 1, 1, 0, -4], stk)
  end

# -
  def test_stack32_025
    rsp = exec <<EOF
: test
  #{@n} 1 -
  1 #{@n} -
  0 0 -
  0 1 -
  1 0 -
;
EOF
    stk = stack(rsp)
    assert_equal([signed(@n-1), signed(1-@n), 0, -1 , 1], stk)
  end


# 0<
  def test_stack32_026
    rsp = exec <<EOF
: test
     0 0<
     1 0<
    -1 0<
 #{@m} 0<
 #{@n} 0<
;
EOF
    stk = stack(rsp)
    assert_equal([0, 0, -1, -1, 0], stk)
  end

# 0=
  def test_stack32_027
    # ( -- t f f )
    rsp = exec(": test 0 0= 1 0= -1 0= ;")
    stk = stack(rsp)
    assert_equal([-1, 0, 0], stk)
  end

# >r
# r>
  def test_stack32_028
    rsp = exec(": test 1 >r -1 >r 0 >r r> r> r> ;")
    stk = stack(rsp)
    assert_equal([0, -1, 1], stk)
  end


# r@
  def test_stack32_029
    rsp = exec(": test 1 >r r@ -1 >r r@ r> r> ;")
    stk = stack(rsp)
    assert_equal([1, -1, -1, 1], stk)
  end

# 2>r
# 2r@
  def test_stack32_030
    rsp = exec(": test 1 2 2>r 2r@ r> r> ;")
    stk = stack(rsp)
    assert_equal([1, 2, 2, 1], stk)
  end

# 2r>
  def test_stack32_031
    rsp = exec(": test 1 2 2>r 2r> ;")
    stk = stack(rsp)
    assert_equal([1, 2], stk)
  end

# <
  def test_stack32_032
    rsp = exec <<EOF
: test
     0     0 <
     0     1 <
     1 #{@n} <
 #{@n} #{@m} <
 #{@m}    -2 <
    -2    -1 <
;
EOF
    stk = stack(rsp)
    assert_equal([0, -1, -1, 0, -1, -1], stk)
  end

# u<
  def test_stack32_033
    rsp = exec <<EOF
: test
     0     0 u<
     0     1 u<
     1 #{@n} u<
 #{@n} #{@m} u<
 #{@m}    -2 u<
    -2    -1 u<
;
EOF
    stk = stack(rsp)
    assert_equal([0, -1, -1, -1, -1, -1], stk)
  end

# drop
  def test_stack32_034
    rsp = exec(": test 1 -1 0 drop drop ;")
    stk = stack(rsp)
    assert_equal([1], stk)
  end

# invert
  def test_stack32_035
    rsp = exec <<EOF
: test
     0 invert
     1 invert
    -1 invert
 #{@n} invert
 #{@m} invert
;
EOF
    stk = stack(rsp)
    assert_equal([-1, -2, 0, signed(@m), @n], stk)
  end

# and
  def test_stack32_036
    rsp = exec(": test -1  1 and  1 -1 and ;")
    stk = stack(rsp)
    assert_equal([1, 1], stk)
  end

# or
  def test_stack32_037
    rsp = exec(": test 0  1 or  1 -1 or ;")
    stk = stack(rsp)
    assert_equal([1, -1], stk)
  end

# xor
  def test_stack32_038
    rsp = exec(": test 0  1 or  1 -1 xor ;")
    stk = stack(rsp)
    assert_equal([1, -2], stk)
  end

# m+
  def test_stack32_039_1
    rsp = exec(": test 0. 1 m+ ;")
    stk = stack(rsp)
    assert_equal([1, 0], stk)
  end

  def test_stack32_039_2
    rsp = exec(": test 0. -1 m+ ;")
    stk = stack(rsp)
    assert_equal([-1, -1], stk)
  end

  def test_stack32_039_3
    rsp = exec(": test -1. 1 m+ ;")
    stk = stack(rsp)
    assert_equal([0, 0], stk)
  end

# n>r
# nr>
  def test_stack32_040
    rsp = exec(": test 10 11 12 3 n>r nr> ;")
    stk = stack(rsp)
    assert_equal([10, 11, 12, 3], stk)
  end

  def test_stack32_040_1
    rsp = exec(": test 1 2 10 11 12 13 4 n>r 3 nr> ;")
    stk = stack(rsp)
    assert_equal([1, 2, 3, 10, 11, 12, 13, 4], stk)
  end

# um/mod
  def test_stack32_041_1
    rsp = exec(": test 10 0 5 um/mod ;")
    stk = stack(rsp)
    assert_equal([0, 2], stk)
  end

  def test_stack32_041_2
    rsp = exec(": test 10 0 4 um/mod ;")
    stk = stack(rsp)
    assert_equal([2, 2], stk)
  end

  # SIGFPE
  def off_test_stack32_041_3
    rsp = exec(": test -1 -1 -1 um/mod ;")
    stk = stack(rsp)
    assert_equal([0, 1], stk)
  end




end
