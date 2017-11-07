#
#  vmmath.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#

# Generic math tests
#
# stack width is no wider then @vm.databytes

module VMMath

  extend NoRedef
  
  # +
  def test_vmmath_001
    @vm.push(1)
    @vm.vm_dup
    @vm.vm_plus
    assert_equal(1, @vm.depth)
    assert_equal(1+1, @vm.tos)
  end

  # largest positive
  def test_vmmath_001a
    @vm.push(@vm.max_uint/2)
    @vm.vm_dup
    @vm.vm_plus
    assert_equal(1, @vm.depth)
    assert_equal(@vm.max_uint-1, @vm.tos)
  end

  # largest positive, unsigned
  def test_vmmath_001b
    @vm.push(@vm.max_uint/2)
    @vm.push(@vm.max_uint)
    @vm.vm_plus
    assert_equal(1, @vm.depth)
    assert_equal((@vm.max_uint/2)-1, @vm.tos)
  end

  # largest unsigned
  def test_vmmath_001c
    @vm.push(@vm.max_uint)
    @vm.vm_dup
    @vm.vm_plus
    assert_equal(1, @vm.depth)
    assert_equal(@vm.max_uint-1, @vm.tos)
  end

  # vm_minus
  def test_vmmath_002
    @vm.push(3)
    @vm.push(1)
    @vm.vm_minus
    assert_equal(1, @vm.depth)
    assert_equal(3-1, @vm.tos)
  end

  # vm_and
  def test_vmmath_003
    @vm.push(3)
    @vm.push(1)
    @vm.vm_and
    assert_equal(1, @vm.depth)
    assert_equal(1&3, @vm.tos)
  end

  # vm_or
  def test_vmmath_004
    @vm.push(5)
    @vm.push(2)
    @vm.vm_or
    assert_equal(1, @vm.depth)
    assert_equal(5|2, @vm.tos)
  end

  # vm_xor
  def test_vmmath_005
    @vm.push(5)
    @vm.push(2)
    @vm.vm_xor
    assert_equal(1, @vm.depth)
    assert_equal(5^2, @vm.tos)
  end

  def test_vmmath_006
    # unused
  end

  # vm_star
  def test_vmmath_007
    @vm.push(2)
    @vm.push(5)
    @vm.vm_star
    assert_equal(1, @vm.depth)
    assert_equal(10, @vm.tos)
  end

  # vm_slash
  def test_vmmath_008
    @vm.push(10)
    @vm.push(3)
    @vm.vm_slash
    assert_equal(1, @vm.depth)
    assert_equal(3, @vm.tos)
  end

  # vm_star_slash
  def test_vmmath_009
    @vm.push(2)
    @vm.push(5)
    @vm.push(3)
    @vm.vm_star_slash
    assert_equal(1, @vm.depth)
    assert_equal(3, @vm.tos)
  end

  # vm_star_slash_mod
  def test_vmmath_010
    @vm.push(2)
    @vm.push(5)
    @vm.push(3)
    @vm.vm_star_slash_mod
    assert_equal(2, @vm.depth)
    assert_equal(3, @vm.tos)
    assert_equal(1, @vm.nos)
  end

  # vm_slash_mod
  def test_vmmath_011
    @vm.push(2*5)
    @vm.push(3)
    @vm.vm_slash_mod
    assert_equal(2, @vm.depth)
    assert_equal(3, @vm.tos)
    assert_equal(1, @vm.nos)
  end

  # boolean primitive
  def test_vmmath_011a
    assert_equal(0, @vm.boolean(false))
    assert_equal(@vm.max_uint, @vm.boolean(true))
    assert_equal(0, @vm.boolean(0))
    assert_equal(@vm.max_uint, @vm.boolean(1))
    assert_equal(@vm.max_uint, @vm.boolean(-1))
    assert_equal(@vm.max_uint, @vm.boolean(@vm.max_uint))
    assert_equal(@vm.max_uint, @vm.boolean(-@vm.max_uint))
  end

  # max_uint and -1 should be equivalent
  def test_vmmath_011b
    @vm.push(-1)
    @vm.push(@vm.max_uint)
    @vm.vm_minus
    assert_equal(0, @vm.tos)
  end

  # vm_uless
  def test_vmmath_012
    @vm.push(2)
    @vm.push(1)
    # -- 2 1
    @vm.vm_uless
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_drop
    
    @vm.push(1)
    @vm.push(2)
    # -- 1 2
    @vm.vm_uless
    assert_equal(1, @vm.depth)
    assert_equal(@vm.max_uint, @vm.tos)
    @vm.vm_drop
    
    @vm.push(0)
    @vm.push(@vm.max_uint)
    # -- 0 -1
    @vm.vm_uless
    assert_equal(1, @vm.depth)
    assert_equal(@vm.max_uint, @vm.tos)
    @vm.vm_drop
    
    @vm.push(@vm.max_uint)
    @vm.push(0)
    # -- -1 0
    @vm.vm_uless
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_drop
    
  end

  # vm_um_star
  def test_vmmath_013
    @vm.push(2)
    @vm.push(5)
    @vm.vm_um_star
    assert_equal(2, @vm.depth)
    assert_equal(0, @vm.tos)
    assert_equal(10, @vm.nos)
  end

  # vm_um_slash_mod
  def test_vmmath_014
    @vm.push(2*5)
    @vm.push(0)
    @vm.push(3)
    @vm.vm_um_slash_mod
    assert_equal(2, @vm.depth)
    assert_equal(3, @vm.tos)
    assert_equal(1, @vm.nos)
  end

  # vm_zero_equal
  def test_vmmath_015
    @vm.push(0)
    @vm.vm_zero_equal
    assert_equal(1, @vm.depth)
    assert_equal(@vm.boolean(true), @vm.tos)

    @vm.vm_zero_equal
    assert_equal(1, @vm.depth)
    assert_equal(@vm.boolean(false), @vm.tos)
    @vm.vm_drop

    @vm.push(1)
    @vm.vm_zero_equal
    assert_equal(1, @vm.depth)
    assert_equal(@vm.boolean(false), @vm.tos)
    @vm.vm_drop

    @vm.push(-2)
    @vm.vm_zero_equal
    assert_equal(1, @vm.depth)
    assert_equal(@vm.boolean(false), @vm.tos)
    @vm.vm_drop
  end

  # vm_zero_less
  def test_vmmath_016
    @vm.push(0)
    @vm.vm_zero_less
    assert_equal(1, @vm.depth)
    assert_equal(@vm.boolean(false), @vm.tos)

    @vm.vm_zero_less
    assert_equal(1, @vm.depth)
    assert_equal(@vm.boolean(false), @vm.tos)
    @vm.vm_drop

    @vm.push(1)
    @vm.vm_zero_less
    assert_equal(1, @vm.depth)
    assert_equal(@vm.boolean(false), @vm.tos)
    @vm.vm_drop

    @vm.push(-2)
    @vm.vm_zero_less
    assert_equal(1, @vm.depth)
    assert_equal(@vm.boolean(true), @vm.tos)
    @vm.vm_drop
  end

  # vm_less
  def test_vmmath_017
    @vm.push(2)
    @vm.push(1)
    # -- 2 1
    @vm.vm_less
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_drop
    
    @vm.push(1)
    @vm.push(2)
    # -- 1 2
    @vm.vm_less
    assert_equal(1, @vm.depth)
    assert_equal(@vm.max_uint, @vm.tos)
    @vm.vm_drop
    
    @vm.push(0)
    @vm.push(@vm.max_uint)
    # -- 0 -1
    @vm.vm_less
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_drop
    
    @vm.push(@vm.max_uint)
    @vm.push(0)
    # -- -1 0
    @vm.vm_less
    assert_equal(1, @vm.depth)
    assert_equal(@vm.max_uint, @vm.tos)
    @vm.vm_drop
    
  end

  # vm_two_star
  def test_vmmath_018
    @vm.push(0)
    @vm.vm_two_star
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_drop
    
    @vm.push(1)
    @vm.vm_two_star
    assert_equal(1, @vm.depth)
    assert_equal(2, @vm.tos)
    @vm.vm_drop
    
    @vm.push(2)
    @vm.vm_two_star
    assert_equal(1, @vm.depth)
    assert_equal(4, @vm.tos)
    @vm.vm_drop
    
  end

  # vm_two_slash
  def test_vmmath_019
    @vm.push(0)
    @vm.vm_two_slash
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_drop
    
    @vm.push(1)
    @vm.vm_two_slash
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_drop
    
    @vm.push(2)
    @vm.vm_two_slash
    assert_equal(1, @vm.depth)
    assert_equal(1, @vm.tos)
    @vm.vm_drop
    
    @vm.push(-1)
    @vm.vm_two_slash
    assert_equal(1, @vm.depth)
    assert_equal(-1, @vm.signed(@vm.tos))
    @vm.vm_drop
    
  end

  # vm_u_two_slash
  def test_vmmath_020
    @vm.push(0)
    @vm.vm_u_two_slash
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_drop
    
    @vm.push(1)
    @vm.vm_u_two_slash
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_drop
    
    @vm.push(2)
    @vm.vm_u_two_slash
    assert_equal(1, @vm.depth)
    assert_equal(1, @vm.tos)
    @vm.vm_drop
    
    @vm.push(-1)
    @vm.vm_u_two_slash
    assert_equal(1, @vm.depth)
    assert_equal(@vm.max_uint/2, @vm.tos)
    @vm.vm_drop
    
  end


end
