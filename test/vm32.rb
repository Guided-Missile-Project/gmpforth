#
#  vm32.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#
# 32bit VM tests includable in different configurations

module VM32

  extend NoRedef

  def byte(v,n)
    (v>>(n*8)) & 0xff
  end

  # Does VM have expected properties?
  def test_vm32_000
    assert(!@vm.nil?)
    assert_equal(4, @vm.addrbytes)
    assert_equal(4, @vm.databytes)
    assert_equal(32, @vm.addrbits)
    assert_equal(32, @vm.databits)
  end

  # quickie assembler test
  def test_vm32_001
    @vm.dot = 0
    @vm.asm(:vm_nop)
    assert_equal(1, @vm.dot)
  end

  # fetch/store/c_fetch/c_store
  def test_vm32_002
    a = 0
    v0 = 0x12345678
    v1 = 0x13345678
    v2 = 0x13355678
    v3 = 0x13355778
    v4 = 0x13355779

    @vm.store(a, v0)
    assert_equal(v0, @vm.fetch(a))
    if @vm.bigendian
      assert_equal(byte(v0,3), @vm.c_fetch(a))
      assert_equal(byte(v0,2), @vm.c_fetch(a+1))
      assert_equal(byte(v0,1), @vm.c_fetch(a+2))
      assert_equal(byte(v0,0), @vm.c_fetch(a+3))
    else
      assert_equal(byte(v0,0), @vm.c_fetch(a))
      assert_equal(byte(v0,1), @vm.c_fetch(a+1))
      assert_equal(byte(v0,2), @vm.c_fetch(a+2))
      assert_equal(byte(v0,3), @vm.c_fetch(a+3))
    end

    if @vm.bigendian
      @vm.c_store(a, byte(v1,3))
      assert_equal(v1, @vm.fetch(a))
      assert_equal(byte(v1,3), @vm.c_fetch(a))
      assert_equal(byte(v1,2), @vm.c_fetch(a+1))
      assert_equal(byte(v1,1), @vm.c_fetch(a+2))
      assert_equal(byte(v1,0), @vm.c_fetch(a+3))
    else
      @vm.c_store(a+3, byte(v1,3))
      assert_equal(v1, @vm.fetch(a))
      assert_equal(byte(v1,0), @vm.c_fetch(a))
      assert_equal(byte(v1,1), @vm.c_fetch(a+1))
      assert_equal(byte(v1,2), @vm.c_fetch(a+2))
      assert_equal(byte(v1,3), @vm.c_fetch(a+3))
    end

    if @vm.bigendian
      @vm.c_store(a+1, byte(v2,2))
      assert_equal(v2, @vm.fetch(a))
      assert_equal(byte(v2,3), @vm.c_fetch(a))
      assert_equal(byte(v2,2), @vm.c_fetch(a+1))
      assert_equal(byte(v2,1), @vm.c_fetch(a+2))
      assert_equal(byte(v2,0), @vm.c_fetch(a+3))
    else
      @vm.c_store(a+2, byte(v2,2))
      assert_equal(v2, @vm.fetch(a))
      assert_equal(byte(v2,0), @vm.c_fetch(a))
      assert_equal(byte(v2,1), @vm.c_fetch(a+1))
      assert_equal(byte(v2,2), @vm.c_fetch(a+2))
      assert_equal(byte(v2,3), @vm.c_fetch(a+3))
    end

    if @vm.bigendian
      @vm.c_store(a+2, byte(v3,1))
      assert_equal(v3, @vm.fetch(a))
      assert_equal(byte(v3,3), @vm.c_fetch(a))
      assert_equal(byte(v3,2), @vm.c_fetch(a+1))
      assert_equal(byte(v3,1), @vm.c_fetch(a+2))
      assert_equal(byte(v3,0), @vm.c_fetch(a+3))
    else
      @vm.c_store(a+1, byte(v3,1))
      assert_equal(v3, @vm.fetch(a))
      assert_equal(byte(v3,0), @vm.c_fetch(a))
      assert_equal(byte(v3,1), @vm.c_fetch(a+1))
      assert_equal(byte(v3,2), @vm.c_fetch(a+2))
      assert_equal(byte(v3,3), @vm.c_fetch(a+3))
    end

    if @vm.bigendian
      @vm.c_store(a+3, byte(v4,0))
      assert_equal(v4, @vm.fetch(a))
      assert_equal(byte(v4,3), @vm.c_fetch(a))
      assert_equal(byte(v4,2), @vm.c_fetch(a+1))
      assert_equal(byte(v4,1), @vm.c_fetch(a+2))
      assert_equal(byte(v4,0), @vm.c_fetch(a+3))
    else
      @vm.c_store(a, byte(v4,0))
      assert_equal(v4, @vm.fetch(a))
      assert_equal(byte(v4,0), @vm.c_fetch(a))
      assert_equal(byte(v4,1), @vm.c_fetch(a+1))
      assert_equal(byte(v4,2), @vm.c_fetch(a+2))
      assert_equal(byte(v4,3), @vm.c_fetch(a+3))
    end
  end

  def test_vm32_002_1
    a = 0
    v0 = 0xa5a5a5a5
    v1 = 0x5a5a5a5a

    # make sure memory is initially uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vm.c_fetch(a)
    end
    assert_raise GMPForth::MemoryUninitializedError do
      @vm.c_fetch(a+1)
    end
    assert_raise GMPForth::MemoryUninitializedError do
      @vm.c_fetch(a+2)
    end
    assert_raise GMPForth::MemoryUninitializedError do
      @vm.c_fetch(a+3)
    end
    @vm.c_store(a+0, byte(v0,3))
    @vm.c_store(a+1, byte(v0,2))
    @vm.c_store(a+2, byte(v0,1))
    @vm.c_store(a+3, byte(v0,0))
    assert_equal(v0, @vm.fetch(a))
    assert_equal(byte(v0,3), @vm.c_fetch(a))
    assert_equal(byte(v0,2), @vm.c_fetch(a+1))
    assert_equal(byte(v0,1), @vm.c_fetch(a+2))
    assert_equal(byte(v0,0), @vm.c_fetch(a+3))

    @vm.c_store(a+0, byte(v1,3))
    @vm.c_store(a+1, byte(v1,2))
    @vm.c_store(a+2, byte(v1,1))
    @vm.c_store(a+3, byte(v1,0))
    assert_equal(v1, @vm.fetch(a))
    assert_equal(byte(v1,3), @vm.c_fetch(a))
    assert_equal(byte(v1,2), @vm.c_fetch(a+1))
    assert_equal(byte(v1,1), @vm.c_fetch(a+2))
    assert_equal(byte(v1,0), @vm.c_fetch(a+3))
  end

  # store address alignment exceptions
  def test_vm32_003
    assert_raise GMPForth::MemoryAlignmentError do
      @vm.store(1, 0)
    end
    assert_raise GMPForth::MemoryAlignmentError do 
      @vm.store(2, 0)
    end
    assert_raise GMPForth::MemoryAlignmentError do 
      @vm.store(3, 0)
    end
    assert_raise GMPForth::MemoryAlignmentError do 
      @vm.store(5, 0)
    end
    assert_raise GMPForth::MemoryAlignmentError do 
      @vm.store(-1, 0)
    end
  end


  # unimplemented
  def test_vm32_004
    assert_raise GMPForth::UnimplementedError do 
      @vm.unimplemented
    end
  end

  # empty stacks
  def test_vm32_005
    assert_equal(0, @vm.depth)
    assert_raise GMPForth::StackEmptyError do 
      @vm.tos
    end
    assert_raise GMPForth::StackShallowError do 
      @vm.nos
    end
    assert_raise GMPForth::StackEmptyError do 
      @vm.rtos
    end
    assert_raise GMPForth::StackShallowError do 
      @vm.rnos
    end
  end

  # pstack bounds
  def test_vm32_006
    @vm.pstack_size.times { |n| @vm.push(n) }
    assert_equal(@vm.pstack_size, @vm.depth)
    assert_raise GMPForth::StackFullError do 
      @vm.push(-1)
    end
    assert_equal(@vm.pstack_size, @vm.depth)
    @vm.pstack_size.times  do |n| 
      assert_equal(@vm.pstack_size - n - 1, @vm.pop) 
    end
    assert_equal(0, @vm.depth)
    assert_raise GMPForth::StackEmptyError do 
      @vm.pop
    end
    assert_equal(0, @vm.depth)
    assert_raise GMPForth::StackEmptyError do 
      @vm.pop
    end
    assert_equal(0, @vm.depth)

  end
    
  # rstack bounds
  def test_vm32_007
    @vm.rstack_size.times { |n| @vm.rpush(n) }
    assert_equal(@vm.rstack_size, @vm.rdepth)
    assert_raise GMPForth::StackFullError do 
      @vm.rpush(-1)
    end
    assert_equal(@vm.rstack_size, @vm.rdepth)
    @vm.rstack_size.times  do |n| 
      assert_equal(@vm.rstack_size - n - 1, @vm.rpop) 
    end
    assert_equal(0, @vm.rdepth)
    assert_raise GMPForth::StackEmptyError do 
      @vm.rpop
    end
    assert_equal(0, @vm.rdepth)
    assert_raise GMPForth::StackEmptyError do 
      @vm.rpop
    end
    assert_equal(0, @vm.rdepth)
  end
    
  # memory bounds
  def test_vm32_008
    @vm.store(0, 0)
    mwa = @vm.mem_size * @vm.databytes
    assert_raise GMPForth::MemoryBoundsError do 
      @vm.store(-@vm.databytes, 0)
    end
    assert_raise GMPForth::MemoryBoundsError do 
      @vm.store(mwa, 0)
    end
    assert_raise GMPForth::MemoryBoundsError do 
      @vm.store(mwa+@vm.databytes, 0)
    end
    @vm.store(mwa-@vm.databytes, 0)
  end

  # uninitialized memory
  def test_vm32_009
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.fetch(0)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(0)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(1)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(2)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(3)
    end
  end

  # partial byte stores
  def test_vm32_010
    v0 = 0x55
    v1 = 0xaa
    v2 = 0x37
    v3 = 0x73
    if @vm.bigendian
      vw = ((v0<<24) | (v1<<16) | (v2<<8) | v3)
    else
      vw = ((v3<<24) | (v2<<16) | (v1<<8) | v0)
    end

    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.fetch(0)
    end
    @vm.c_store(0, v0);
    assert_equal(v0, @vm.c_fetch(0))
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.fetch(0)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(1)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(2)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(3)
    end

    @vm.c_store(1, v1);
    assert_equal(v0, @vm.c_fetch(0))
    assert_equal(v1, @vm.c_fetch(1))
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.fetch(0)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(2)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(3)
    end

    @vm.c_store(2, v2);
    assert_equal(v0, @vm.c_fetch(0))
    assert_equal(v1, @vm.c_fetch(1))
    assert_equal(v2, @vm.c_fetch(2))
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.fetch(0)
    end
    assert_raise GMPForth::MemoryUninitializedError do 
      @vm.c_fetch(3)
    end

    @vm.c_store(3, v3);
    assert_equal(v0, @vm.c_fetch(0))
    assert_equal(v1, @vm.c_fetch(1))
    assert_equal(v2, @vm.c_fetch(2))
    assert_equal(v3, @vm.c_fetch(3))
    assert_equal(vw, @vm.fetch(0))

  end

  # vm_store
  def test_vm32_011
    mwa = @vm.mem_size * @vm.databytes
    v = 0xa55ac77c

    assert_raise GMPForth::MemoryAlignmentError do
      @vm.push(v)
      @vm.push(1)
      @vm.vm_store
    end
    @vm.vm_reset

    assert_raise GMPForth::MemoryBoundsError do
      @vm.push(v)
      @vm.push(-mwa)
      @vm.vm_store
    end
    @vm.vm_reset

    assert_raise GMPForth::MemoryBoundsError do
      @vm.push(v)
      @vm.push(mwa)
      @vm.vm_store
    end
    @vm.vm_reset
    
    a = @vm.databytes
    @vm.push(v)
    @vm.push(a)
    @vm.vm_store
    assert_equal(v, @vm.fetch(a))
    
  end

  # vm_fetch
  def test_vm32_012
    mwa = @vm.mem_size * @vm.databytes
    v = 0xa55ac77c

    assert_raise GMPForth::MemoryAlignmentError do
      @vm.push(1)
      @vm.vm_fetch
    end
    @vm.vm_reset

    assert_raise GMPForth::MemoryBoundsError do
      @vm.push(-mwa)
      @vm.vm_fetch
    end
    @vm.vm_reset

    assert_raise GMPForth::MemoryBoundsError do
      @vm.push(mwa)
      @vm.vm_fetch
    end
    @vm.vm_reset
    
    a = @vm.databytes
    assert_raise GMPForth::MemoryUninitializedError do
      @vm.push(a)
      @vm.vm_fetch
    end
    @vm.vm_reset
    
    @vm.store(a, v)
    @vm.push(a)
    @vm.vm_fetch
    assert_equal(v, @vm.tos)
    
  end
  
  # vm_c_store
  def test_vm32_013
    mwa = @vm.mem_size * @vm.databytes
    v = 0xa5

    @vm.push(v)
    @vm.push(1)
    @vm.vm_c_store

    assert_raise GMPForth::MemoryBoundsError do
      @vm.push(v)
      @vm.push(-mwa)
      @vm.vm_c_store
    end
    @vm.vm_reset

    assert_raise GMPForth::MemoryBoundsError do
      @vm.push(v)
      @vm.push(mwa)
      @vm.vm_c_store
    end
    @vm.vm_reset
    
    a = @vm.databytes
    @vm.push(v)
    @vm.push(a)
    @vm.vm_c_store
    assert_equal(v, @vm.c_fetch(a))
    
  end

  # vm_c_fetch
  def test_vm32_014
    mwa = @vm.mem_size * @vm.databytes
    v = 0x7c

    assert_raise GMPForth::MemoryUninitializedError do
      @vm.push(1)
      @vm.vm_c_fetch
    end
    @vm.vm_reset

    assert_raise GMPForth::MemoryBoundsError do
      @vm.push(-mwa)
      @vm.vm_c_fetch
    end
    @vm.vm_reset

    assert_raise GMPForth::MemoryBoundsError do
      @vm.push(mwa)
      @vm.vm_c_fetch
    end
    @vm.vm_reset
    
    a = @vm.databytes
    assert_raise GMPForth::MemoryUninitializedError do
      @vm.push(a)
      @vm.vm_c_fetch
    end
    @vm.vm_reset
    
    @vm.c_store(a, v)
    @vm.push(a)
    @vm.vm_c_fetch
    assert_equal(v, @vm.tos)
    
    assert_raise GMPForth::MemoryUninitializedError do
      @vm.push(a)
      @vm.vm_fetch
    end

  end

  # word_addr
  def test_vm32_015
    assert_equal(0, @vm.word_addr(0))
    assert_equal(0, @vm.word_addr(1))
    assert_equal(0, @vm.word_addr(2))
    assert_equal(0, @vm.word_addr(3))
    assert_equal(1, @vm.word_addr(4))
    assert_equal(1, @vm.word_addr(5))
    assert_equal(1, @vm.word_addr(6))
    assert_equal(1, @vm.word_addr(7))
    assert_raise GMPForth::MemoryBoundsError do
      @vm.word_addr(-1)
    end
    assert_raise GMPForth::MemoryBoundsError do
      @vm.word_addr(@vm.mem_size * @vm.databytes)
    end
  end

  # word_align
  def test_vm32_016
  end
  
  # byte_mask
  def test_vm32_017
  end

  # word_aligned?
  def test_vm32_018
  end

  # aligned_word_addr
  def test_vm32_019
  end

  # aligned_byte_addr
  def test_vm32_020
  end

end
