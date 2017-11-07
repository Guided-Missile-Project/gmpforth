#
#  vmstack.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#
# Generic stack tests
#
# stack width is no wider then @vm.databytes

module VMStack

  extend NoRedef

  # stack data width should be at least 16 bits wide
  # and equal to @vm.databytes
  def test_vmstack_000

    assert(@vm.databytes >= 2)

    max_int = 2**(@vm.databytes)-1
    @vm.push(max_int)
    assert_equal(max_int, @vm.tos)
    @vm.push(-max_int)
    assert_equal(-max_int, @vm.signed(@vm.tos))
    
  end

  # vm_sp_store
  def test_vmstack_001
    @vm.push(@vm.mem_size)
    @vm.push(GMPForth::VM::REG_SP)
    @vm.vm_reg_store
    assert_equal(@vm.mem_size, @vm.depth)
  end

  # vm_rp_store
  def test_vmstack_002
    @vm.push(@vm.mem_size - @vm.pstack_size)
    @vm.push(GMPForth::VM::REG_RP)
    @vm.vm_reg_store
    assert_equal(0, @vm.depth)
  end

  # vm_up_store
  def test_vmstack_002_02
    @vm.push(@vm.dot)
    @vm.push(GMPForth::VM::REG_UP)
    @vm.vm_reg_store
    assert_equal(0, @vm.depth)
  end

  # vm_sp_fetch
  def test_vmstack_002_03
    @vm.push(GMPForth::VM::REG_SP)
    @vm.vm_reg_fetch
    assert_equal(1, @vm.depth)
  end

  # vm_rp_fetch
  def test_vmstack_002_04
    @vm.push(GMPForth::VM::REG_RP)
    @vm.vm_reg_fetch
    assert_equal(1, @vm.depth)
  end

  # vm_up_fetch
  def test_vmstack_002_05
    @vm.push(GMPForth::VM::REG_UP)
    @vm.vm_reg_fetch
    assert_equal(1, @vm.depth)
  end

  # vm_drop
  def test_vmstack_003
    @vm.push(1)
    @vm.push(2)
    assert_equal(2, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(1, @vm.nos)
    @vm.vm_drop
    assert_equal(1, @vm.depth)
    assert_equal(1, @vm.tos)
    @vm.vm_drop
    assert_equal(0, @vm.depth)
  end

  # vm_swap
  def test_vmstack_003a
    @vm.push(1)
    @vm.push(2)
    assert_equal(2, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(1, @vm.nos)
    @vm.vm_swap
    assert_equal(2, @vm.depth)
    assert_equal(1, @vm.tos)
    assert_equal(2, @vm.nos)
    @vm.vm_swap
    assert_equal(2, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(1, @vm.nos)
    @vm.vm_drop
    assert_equal(1, @vm.depth)
    assert_equal(1, @vm.tos)
    @vm.vm_drop
    assert_equal(0, @vm.depth)
  end

  # vm_dup
  def test_vmstack_004
    @vm.push(1)
    @vm.vm_dup
    assert_equal(2, @vm.depth)
    assert_equal(1, @vm.tos)
    assert_equal(1, @vm.nos)
    @vm.vm_drop
    assert_equal(1, @vm.depth)
    assert_equal(1, @vm.tos)
    @vm.vm_drop
    assert_equal(0, @vm.depth)
  end

  # vm_depth
  def test_vmstack_005
    @vm.vm_depth
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.tos)
    @vm.vm_depth
    assert_equal(2, @vm.depth)
    assert_equal(1, @vm.tos)
    assert_equal(0, @vm.nos)
  end

  # vm_over
  def test_vmstack_006
    @vm.push(1)
    @vm.push(2)
    @vm.vm_over
    assert_equal(3, @vm.depth)
    assert_equal(1, @vm.tos)
    assert_equal(2, @vm.nos)
    @vm.vm_drop
    assert_equal(2, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(1, @vm.nos)
  end

  # vm_rot
  def test_vmstack_007
    @vm.push(1)
    @vm.push(2)
    @vm.push(3)
    # -- 1 2 3
    assert_equal(3, @vm.depth)
    assert_equal(3, @vm.tos)
    assert_equal(2, @vm.nos)

    @vm.vm_rot
    # -- 2 3 1
    assert_equal(3, @vm.depth)
    assert_equal(1, @vm.tos)
    assert_equal(3, @vm.nos)

    @vm.vm_rot
    # -- 3 1 2
    assert_equal(3, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(1, @vm.nos)

    @vm.vm_rot
    # -- 1 2 3
    assert_equal(3, @vm.depth)
    assert_equal(3, @vm.tos)
    assert_equal(2, @vm.nos)

    @vm.vm_drop
    # -- 2 1
    assert_equal(2, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(1, @vm.nos)

    @vm.vm_drop
    # -- 1
    assert_equal(1, @vm.depth)
    assert_equal(1, @vm.tos)

    @vm.vm_drop
    # -- 
    assert_equal(0, @vm.depth)

  end

  # vm_dash_rot
  def test_vmstack_008
    @vm.push(1)
    @vm.push(2)
    @vm.push(3)
    # -- 1 2 3
    assert_equal(3, @vm.depth)
    assert_equal(3, @vm.tos)
    assert_equal(2, @vm.nos)

    @vm.vm_dash_rot
    # -- 3 1 2
    assert_equal(3, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(1, @vm.nos)

    @vm.vm_dash_rot
    # -- 2 3 1
    assert_equal(3, @vm.depth)
    assert_equal(1, @vm.tos)
    assert_equal(3, @vm.nos)

    @vm.vm_dash_rot
    # -- 1 2 3
    assert_equal(3, @vm.depth)
    assert_equal(3, @vm.tos)
    assert_equal(2, @vm.nos)

    @vm.vm_drop
    # -- 2 1
    assert_equal(2, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(1, @vm.nos)

    @vm.vm_drop
    # -- 1
    assert_equal(1, @vm.depth)
    assert_equal(1, @vm.tos)

    @vm.vm_drop
    # -- 
    assert_equal(0, @vm.depth)

  end

  # vm_n_to_r
  # vm_n_r_from
  def test_vmstack_009
    @vm.push(2)
    assert_equal(1, @vm.depth)
    @vm.push(1)
    @vm.vm_n_to_r
    assert_equal(0, @vm.depth)
    assert_equal(2, @vm.rdepth)
    @vm.vm_n_r_from
    assert_equal(2, @vm.depth)
    assert_equal(0, @vm.rdepth)
    assert_equal(1, @vm.tos)
    assert_equal(2, @vm.nos)
    @vm.vm_drop
    @vm.vm_drop
    assert_equal(0, @vm.depth)
  end

  def test_vmstack_009_2
    @vm.push(5)
    @vm.push(4)
    @vm.push(2)
    assert_equal(3, @vm.depth)
    @vm.vm_n_to_r
    assert_equal(0, @vm.depth)
    assert_equal(3, @vm.rdepth)
    @vm.vm_n_r_from
    assert_equal(3, @vm.depth)
    assert_equal(0, @vm.rdepth)
    assert_equal(2, @vm.tos)
    assert_equal(4, @vm.nos)
    assert_equal(5, @vm.pick(2))
    @vm.vm_drop
    @vm.vm_drop
    @vm.vm_drop
    assert_equal(0, @vm.depth)
  end

  # vm_to_r
  # vm_r_fetch
  # vm_r_from
  def test_vmstack_009_3
    @vm.push(2)
    assert_equal(1, @vm.depth)
    @vm.vm_to_r
    assert_equal(0, @vm.depth)
    assert_equal(1, @vm.rdepth)
    @vm.vm_r_fetch
    assert_equal(1, @vm.depth)
    assert_equal(1, @vm.rdepth)
    assert_equal(2, @vm.tos)
    @vm.vm_drop
    assert_equal(0, @vm.depth)
    @vm.vm_r_from
    assert_equal(1, @vm.depth)
    assert_equal(0, @vm.rdepth)
    assert_equal(2, @vm.tos)
    @vm.vm_drop
    assert_equal(0, @vm.depth)
  end

  # vm_pick
  def test_vmstack_010
    @vm.push(1)
    @vm.push(2)
    @vm.push(3)
    @vm.push(4)
    assert_equal(4, @vm.depth)

    # 0 pick
    # -- 1 2 3 4
    @vm.push(0)
    # -- 1 2 3 4 0
    @vm.vm_pick
    # -- 1 2 3 4 4
    assert_equal(5, @vm.depth)
    assert_equal(4, @vm.tos)
    assert_equal(4, @vm.nos)
    @vm.vm_drop
    # -- 1 2 3 4
    assert_equal(4, @vm.depth)
    assert_equal(4, @vm.tos)
    assert_equal(3, @vm.nos)

    # 1 pick
    # -- 1 2 3 4
    @vm.push(1)
    # -- 1 2 3 4 1
    @vm.vm_pick
    # -- 1 2 3 4 3
    assert_equal(5, @vm.depth)
    assert_equal(3, @vm.tos)
    assert_equal(4, @vm.nos)
    @vm.vm_drop
    # -- 1 2 3 4
    assert_equal(4, @vm.depth)
    assert_equal(4, @vm.tos)
    assert_equal(3, @vm.nos)

    # 2 pick
    # -- 1 2 3 4
    @vm.push(2)
    # -- 1 2 3 4 2
    @vm.vm_pick
    # -- 1 2 3 4 2
    assert_equal(5, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(4, @vm.nos)
    @vm.vm_drop
    # -- 1 2 3 4
    assert_equal(4, @vm.depth)
    assert_equal(4, @vm.tos)
    assert_equal(3, @vm.nos)

    # 3 pick
    # -- 1 2 3 4
    @vm.push(3)
    # -- 1 2 3 4 3
    @vm.vm_pick
    # -- 1 2 3 4 1
    assert_equal(5, @vm.depth)
    assert_equal(1, @vm.tos)
    assert_equal(4, @vm.nos)
    @vm.vm_drop
    # -- 1 2 3 4
    assert_equal(4, @vm.depth)
    assert_equal(4, @vm.tos)
    assert_equal(3, @vm.nos)

    # 4 pick
    # -- 1 2 3 4
    # this will probably turn into a throw at some point
    @vm.push(4)
    # -- 1 2 3 4 4
    assert_raise GMPForth::StackShallowError do 
      @vm.vm_pick
    end
    assert_equal(5, @vm.depth)
    assert_equal(4, @vm.tos)
    assert_equal(4, @vm.nos)

    # -1 pick
    # not sure what's supposed to happen
    # -- 1 2 3 4
    # this will probably turn into a throw at some point
    # @vm.push(-1)
    # -- 1 2 3 4 -1
    # assert_raise GMPForth::StackShallowError do 
    #   @vm.vm_pick
    # end
    # assert_equal(5, @vm.depth)
    # assert_equal(4, @vm.tos)
    # assert_equal(4, @vm.nos)

    @vm.vm_drop
    # -- 1 2 3 4
    assert_equal(4, @vm.depth)
    assert_equal(4, @vm.tos)
    assert_equal(3, @vm.nos)

    @vm.vm_drop
    # -- 1 2 3
    assert_equal(3, @vm.depth)
    assert_equal(3, @vm.tos)
    assert_equal(2, @vm.nos)

    @vm.vm_drop
    # -- 1 2
    assert_equal(2, @vm.depth)
    assert_equal(2, @vm.tos)
    assert_equal(1, @vm.nos)

    @vm.vm_drop
    # -- 1
    assert_equal(1, @vm.depth)
    assert_equal(1, @vm.tos)

    @vm.vm_drop
    # -- 
    assert_equal(0, @vm.depth)

  end

  # vm_roll unsupported

end
