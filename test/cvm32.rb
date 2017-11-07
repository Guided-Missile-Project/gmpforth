#
#  cvm32.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# 

module CVM32

  extend NoRedef

  def test_cvm32_000
    n = 0
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_01
    n = 1
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_02
    n = 2
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_03
    n = 4
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_04
    n = 7
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_05
    n = -1
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_06
    n = -2
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_07
    n = -4
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_08
    n = -7
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_09
    n = -8
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_10
    n = 2**4
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def no_test_cvm32_000_11
    n = 2**5 # is just the sign bit set (0100_0000), so, sign extended
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([-n], stk)
  end

  def test_cvm32_000_12
    # 2**6 is no longer representable 
    # for small pushes so will come out zero
    n = 2**6
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([0], stk)
  end

  def test_cvm32_000_37
    n = -2**4
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_38
    n = -2**5
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  # not representable using a large push with no extension
  def no_test_cvm32_000_39
    n = -2**6
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_65
    n = (2**5)-1
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_000_66
    # this will be signed extended to -1
    n = (2**6)-1
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([-1], stk)
  end

  def test_cvm32_000_67
    # this also will be signed extended to -1
    # but is not representable for small pushes
    n = (2**7)-1
    rsp = exec("#{n}")
    stk = stack(rsp)
    assert_equal([-1], stk)
  end

  def test_cvm32_001
    rsp = exec("1 2")
    stk = stack(rsp)
    assert_equal([1, 2], stk)
  end

# vm_swap
  def test_cvm32_002
    rsp = exec("1 2 vm_swap")
    stk = stack(rsp)
    assert_equal([2, 1], stk)
  end

# vm_dup
  def test_cvm32_003
    rsp = exec("1 vm_dup")
    stk = stack(rsp)
    assert_equal([1, 1], stk)
  end

# vm_over
  def test_cvm32_004
    rsp = exec("1 2 vm_over")
    stk = stack(rsp)
    assert_equal([1, 2, 1], stk)
  end

# vm_rot
  def test_cvm32_005
    rsp = exec("1 2 3 vm_rot")
    stk = stack(rsp)
    assert_equal([2, 3, 1], stk)
  end

# vm_dash_rot
  def test_cvm32_006
    rsp = exec("1 2 3 vm_dash_rot")
    stk = stack(rsp)
    assert_equal([3, 1, 2], stk)
  end

# vm_roll unsupported

# vm_nop
  def test_cvm32_008
    rsp = exec("vm_nop")
    stk = stack(rsp)
    assert_equal([], stk)
  end

# vm_store
# vm_fetch
  def test_cvm32_009
    rsp = exec("1 4 vm_store 4 vm_fetch")
    stk = stack(rsp)
    assert_equal([1], stk)
  end

# vm_c_store
# vm_c_fetch
  def test_cvm32_010_1
    n = 1
    rsp = exec("#{n} 4 vm_c_store 4 vm_c_fetch")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_010_2
    n = 2
    rsp = exec("#{n} 5 vm_c_store 5 vm_c_fetch")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_010_3
    n = 3
    rsp = exec("#{n} 6 vm_c_store 6 vm_c_fetch")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

  def test_cvm32_010_4
    n = 4
    rsp = exec("#{n} 7 vm_c_store 7 vm_c_fetch")
    stk = stack(rsp)
    assert_equal([n], stk)
  end

# vm_pick
  def test_cvm32_011_1
    rsp = exec("1 2 3 0 vm_pick")
    stk = stack(rsp)
    assert_equal([1, 2, 3, 3], stk)
  end

  def test_cvm32_011_2
    rsp = exec("1 2 3 1 vm_pick")
    stk = stack(rsp)
    assert_equal([1, 2, 3, 2], stk)
  end

  def test_cvm32_011_3
    rsp = exec("1 2 3 2 vm_pick")
    stk = stack(rsp)
    assert_equal([1, 2, 3, 1], stk)
  end

# vm_two_star
  def test_cvm32_012
    rsp = exec("4 vm_two_star")
    stk = stack(rsp)
    assert_equal([8], stk)
  end

# vm_two_slash
  def test_cvm32_013
    rsp = exec("4 vm_two_slash")
    stk = stack(rsp)
    assert_equal([2], stk)
  end

  def test_cvm32_013_1
    rsp = exec("-1 vm_two_slash")
    stk = stack(rsp)
    assert_equal([-1], stk)
  end

# vm_depth
  def test_cvm32_014
    rsp = exec("2 4 6 vm_depth")
    stk = stack(rsp)
    assert_equal([2, 4, 6, 3], stk)
  end

# vm_d_plus
  def test_cvm32_015
    rsp = exec("2 3 1 2 vm_d_plus")
    stk = stack(rsp)
    assert_equal([3, 5], stk)
  end

# vm_d_minus
  def test_cvm32_016
    rsp = exec("2 4 1 2 vm_d_minus")
    stk = stack(rsp)
    assert_equal([1, 2], stk)
  end

# vm_um_star
  def test_cvm32_017
    rsp = exec("5 7 vm_um_star")
    stk = stack(rsp)
    assert_equal([35, 0], stk)
  end

# vm_star_slash
  def test_cvm32_018
    rsp = exec("2 5 3 vm_star_slash")
    stk = stack(rsp)
    assert_equal([3], stk)
  end

# vm_star_slash_mod
  def test_cvm32_019
    rsp = exec("2 5 3 vm_star_slash_mod")
    stk = stack(rsp)
    assert_equal([1, 3], stk)
  end

# vm_slash
  def test_cvm32_020
    rsp = exec("10 3 vm_slash")
    stk = stack(rsp)
    assert_equal([3], stk)
  end

# vm_slash_mod
  def test_cvm32_021
    rsp = exec("10 3 vm_slash_mod")
    stk = stack(rsp)
    assert_equal([1, 3], stk)
  end

# vm_u_two_slash
  def test_cvm32_022
    rsp = exec("4 vm_u_two_slash")
    stk = stack(rsp)
    assert_equal([2], stk)
  end

  def test_cvm32_022_1
    rsp = exec("-1 vm_u_two_slash")
    stk = stack(rsp)
    assert_equal([2147483647], stk)
  end


# vm_reset
#   TODO: store something interesting to execute in loc 0
# vm_star
# vm_plus
# vm_minus
# vm_n_to_r
# vm_and
# vm_drop
# vm_execute
# vm_i
# vm_j
# vm_or
# vm_n_r_from
# vm_r_fetch
# vm_uless
# vm_um_slash_mod
# vm_xor
# vm_plus_loop
# vm_question_do
# vm_do
# vm_docol
# vm_does
# vm_dovar
# vm_dolit
# vm_leave
# vm_loop
# vm_rp_fetch
# vm_rp_store
# vm_s_quote
# vm_sp_fetch
# vm_sp_store
# vm_io
# vm_exit
# vm_branch
# vm_zero_branch_no_pop
# vm_zero_branch
# vm_zero_equal
# vm_zero_less
# vm_less
# vm_m_star_slash

end
