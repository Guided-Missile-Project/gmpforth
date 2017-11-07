#
#  vmop.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#

module VMOp

  extend NoRedef

  def teardown
#    GMPForth::VM.opcode_coverage
  end

  def trace(n=100)
      n.times { puts @vm.step }
  end
  
  # vm_reset
  def test_vmop_001
    @vm.vm_reset
    assert_equal(0, @vm.pc)
  end

  # vm_halt
  def test_vmop_002
    catch :halt do
      @vm.vm_halt
    end
    assert(true)
    assert_equal(:halt, @vm.state)
  end

  # assemble simple code word
  def test_vmop_003
    @vm.asm(@vm.databytes)
    @vm.asm(:vm_nop)
    @vm.asm(:vm_nop)
    @vm.asm(:vm_halt)

    @vm.push(0)
    @vm.vm_execute
    assert_equal(@vm.databytes, @vm.w)
    assert_equal(@vm.databytes, @vm.pc)

    # 1st nop
    @vm.step
    assert_equal(@vm.databytes, @vm.w)
    assert_equal(@vm.databytes+1, @vm.pc)

    # 2nd nop
    @vm.step
    assert_equal(@vm.databytes, @vm.w)
    assert_equal(@vm.databytes+2, @vm.pc)

    # 3rd push
    @vm.step
    assert_equal(@vm.databytes, @vm.w)
    assert_equal(@vm.databytes+3, @vm.pc)

    # IO op halt
    catch :halt do
      @vm.step
    end
    assert_equal(:halt, @vm.state)

  end


  # simple colon definition
  def test_vmop_004
    # compile code words
    _nop  = @vm.asm(@vm.dot + @vm.databytes)
    _nop0 = @vm.asm(:vm_nop)
    _nop1 = @vm.asm(:vm_nop)
    _nop2 = @vm.asm(:vm_nop)
    _nop3 = @vm.asm(:vm_nop)
    _nop4 = @vm.asm(:vm_nop)
    _nop5 = @vm.asm(:vm_nop)
    _nop6 = @vm.asm(:vm_nop)
    _nop7 = @vm.asm(:vm_next)

    @vm.aligned_dot
    _halt  = @vm.asm(@vm.dot + @vm.databytes)
    _halt0 = @vm.asm(:vm_halt)
    @vm.asm(:vm_next)

    @vm.aligned_dot
    _docol  = @vm.asm(@vm.dot + @vm.databytes)
    _docol0 = @vm.asm(:vm_docol)
    _docol1 = @vm.asm(:vm_next)

    @vm.aligned_dot
    _exit  = @vm.asm(@vm.dot + @vm.databytes)
    _exit0 = @vm.asm(:vm_exit)
    _exit1 = @vm.asm(:vm_next)

    # create colon definitions
    _h_nop = @vm.aligned_dot
    @vm.asm(_docol + @vm.databytes)
    @vm.asm(_nop)
    @vm.asm(_exit)

    _h_halt = @vm.aligned_dot
    @vm.asm(_docol + @vm.databytes)
    @vm.asm(_halt)
    @vm.asm(_exit)

    _h_test = @vm.aligned_dot
    @vm.asm(_docol + @vm.databytes)
    @vm.asm(_h_nop)
    @vm.asm(_h_nop)
    @vm.asm(_h_nop)
    @vm.asm(_h_halt)
    @vm.asm(_exit)

    @vm.boot(_h_test)

    catch :halt do
                assert_equal(_docol0, @vm.pc) # vm_docol
      @vm.step; assert_equal(_docol1, @vm.pc) # vm_next
      @vm.step; assert_equal(_docol0, @vm.pc) # vm_docol
      @vm.step; assert_equal(_docol1, @vm.pc) # vm_next
      @vm.step; assert_equal(_nop0,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop1,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop2,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop3,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop4,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop5,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop6,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop7,   @vm.pc) # vm_next
      @vm.step; assert_equal(_exit0,  @vm.pc) # vm_exit
      @vm.step; assert_equal(_exit1,  @vm.pc) # vm_next
      @vm.step; assert_equal(_docol0, @vm.pc) # vm_docol
      @vm.step; assert_equal(_docol1, @vm.pc) # vm_next
      @vm.step; assert_equal(_nop0,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop1,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop2,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop3,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop4,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop5,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop6,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop7,   @vm.pc) # vm_next
      @vm.step; assert_equal(_exit0,  @vm.pc) # vm_exit
      @vm.step; assert_equal(_exit1,  @vm.pc) # vm_next
      @vm.step; assert_equal(_docol0, @vm.pc) # vm_docol
      @vm.step; assert_equal(_docol1, @vm.pc) # vm_next
      @vm.step; assert_equal(_nop0,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop1,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop2,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop3,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop4,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop5,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop6,   @vm.pc) # vm_nop
      @vm.step; assert_equal(_nop7,   @vm.pc) # vm_next
      @vm.step; assert_equal(_exit0,  @vm.pc) # vm_exit
      @vm.step; assert_equal(_exit1,  @vm.pc) # vm_next
      @vm.step; assert_equal(_docol0, @vm.pc) # vm_docol
      @vm.step; assert_equal(_docol1, @vm.pc) # vm_next
      @vm.step; assert_equal(_halt0,  @vm.pc) # vm_halt
      @vm.step # push
      @vm.step # io
    end
    assert_equal(:halt, @vm.state)

  end

  # test_vmop_005 was vm_jmp

  # vm_branch
  def test_vmop_006
    _nop  = @vm.compile(nil, nil, :vm_nop, :vm_next)
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _branch = @vm.compile(nil, nil, :vm_branch, :vm_next)
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _branch,
                  '@L1',
                  'L2',
                  _nop,
                  _branch,
                  '@L3',
                  'L1',
                  _branch,
                  '@L2',
                  'L3',
                  _halt,
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_branch,  @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_branch,  @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_branch,  @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(:halt, @vm.state)
  end

  # vm_zero_branch
  def test_vmop_007
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _0branch = @vm.compile(nil, nil, :vm_zero_branch, :vm_next)
    _0 = @vm.compile(nil, nil, :vm_push_0, :vm_next)
    _1 = @vm.compile(nil, nil, :vm_push_1, :vm_next)
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _0,
                  _0branch,
                  '@L1',
                  'L2',
                  _1,
                  _0branch,
                  '@L3',
                  _halt,
                  'L1',
                  _0,
                  _0branch,
                  '@L2',
                  'L3',
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(:vm_docol,        @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_push,         @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_zero_branch,  @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_push,         @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_zero_branch,  @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_push,         @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_zero_branch,  @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_push,         @vm.step)
      assert_equal(:vm_io,           @vm.step)
    end
    assert_equal(0, @vm.depth)
    assert_equal(:halt, @vm.state)
  end

  # vm_zero_branch_no_pop
  def test_vmop_008
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _0branchnp = @vm.compile(nil, nil, :vm_zero_branch_no_pop, :vm_next)
    _0 = @vm.compile(nil, nil, :vm_push_0, :vm_next)
    _1plus = @vm.compile(nil, nil, :vm_push_1, :vm_plus, :vm_next)
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _0,
                  _0branchnp,
                  '@L1',
                  'L2',
                  _1plus,
                  _0branchnp,
                  '@L3',
                  _halt,
                  'L1',
                  _0branchnp,
                  '@L2',
                  'L3',
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(:vm_docol,        @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_push,         @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_zero_branch_no_pop,  @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_zero_branch_no_pop,  @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_push,         @vm.step)
      assert_equal(:vm_plus,         @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_zero_branch_no_pop,  @vm.step)
      assert_equal(:vm_nop,          @vm.step)

      assert_equal(:vm_push,         @vm.step)
      assert_equal(:vm_io,           @vm.step)
    end
    assert_equal(1, @vm.depth)
    assert_equal(:halt, @vm.state)
  end

  # vm_dolit
  def test_vmop_009
    value = 1000
    _dolit  = @vm.compile(nil, nil, :vm_dolit, :vm_next)
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _dolit,
                  value,
                  _halt,
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(:vm_docol, @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(value,     @vm.tos)
      assert_equal(1,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(:vm_push,  @vm.step)
      assert_equal(:vm_io,    @vm.step)
    end
    assert_equal(:halt, @vm.state)
  end

  # test_vmop_010 was vm_call vm_return

  # vm_do
  # vm_i
  # vm_loop
  def test_vmop_011
    _dolit  = @vm.compile(nil, nil, :vm_dolit, :vm_next)
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _do = @vm.compile(nil, nil, :vm_do, :vm_next)
    _loop = @vm.compile(nil, nil, :vm_loop, :vm_next)
    _i = @vm.compile(nil, nil, :vm_i, :vm_next)
    _drop = @vm.compile(nil, nil, :vm_drop, :vm_next)
    # : test 10 0 do i drop loop halt ;
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _dolit,
                  10,
                  _dolit,
                  0,
                  _do,
                  '@L2',
                  'L1',
                  _i,
                  _drop,
                  _loop,
                  '@L1',
                  'L2',
                  _halt,
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(0,         @vm.rdepth)
      # docol
      assert_equal(:vm_docol, @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(1,         @vm.rdepth)
      # 10
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(10,        @vm.tos)
      assert_equal(1,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # 0
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(0,         @vm.tos)
      assert_equal(2,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # do
      assert_equal(:vm_do,    @vm.step)
      assert_equal(4,         @vm.rdepth)
      assert_equal(10,        @vm.rnos)
      assert_equal(0,         @vm.rtos)
      assert_equal(:vm_nop,   @vm.step)

      # i (0)
      assert_equal(:vm_r_fetch, @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(0,         @vm.tos)

      # drop (0)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (0)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (1)
      assert_equal(:vm_r_fetch, @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(1,         @vm.tos)

      # drop (1)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (1)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (2)
      assert_equal(:vm_r_fetch, @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(2,         @vm.tos)

      # drop (2)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (2)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (3)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(3,         @vm.tos)

      # drop (3)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (3)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (4)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(4,         @vm.tos)

      # drop (4)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (4)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (5)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(5,         @vm.tos)

      # drop (5)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (5)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (6)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(6,         @vm.tos)

      # drop (6)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (6)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (7)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(7,         @vm.tos)

      # drop (7)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (7)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (8)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(8,         @vm.tos)

      # drop (8)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (8)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (9)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(9,         @vm.tos)

      # drop (9)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (9)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      assert_equal(1,         @vm.rdepth)
      assert_equal(0,         @vm.depth)
      assert_equal(:vm_push,  @vm.step)
      assert_equal(:vm_io,    @vm.step)
    end
    assert_equal(:halt, @vm.state)
  end

  # vm_plus_loop
  def test_vmop_012
    _dolit  = @vm.compile(nil, nil, :vm_dolit, :vm_next)
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _do = @vm.compile(nil, nil, :vm_do, :vm_next)
    _plus_loop = @vm.compile(nil, nil, :vm_plus_loop, :vm_next)
    _i = @vm.compile(nil, nil, :vm_i, :vm_next)
    # : test 10 1 do i +loop halt ; 1 2 4 8
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _dolit,
                  10,
                  _dolit,
                  1,
                  _do,
                  '@L2',
                  'L1',
                  _i,
                  _plus_loop,
                  '@L1',
                  'L2',
                  _halt,
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(0,         @vm.rdepth)
      # docol
      assert_equal(:vm_docol, @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(1,         @vm.rdepth)
      # 10
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(10,        @vm.tos)
      assert_equal(1,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # 1
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(1,         @vm.tos)
      assert_equal(2,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # do
      assert_equal(:vm_do,    @vm.step)
      assert_equal(4,         @vm.rdepth)
      assert_equal(10,        @vm.rnos)
      assert_equal(1,         @vm.rtos)
      assert_equal(:vm_nop,   @vm.step)

      # i (1)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(1,         @vm.tos)

      # +loop (1)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_plus_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (2)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(2,         @vm.tos)

      # +loop (2)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_plus_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (4)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(4,         @vm.tos)

      # +loop (4)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_plus_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (8)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(8,         @vm.tos)

      # +loop (8)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_plus_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # halt
      assert_equal(1,         @vm.rdepth)
      assert_equal(0,         @vm.depth)
      assert_equal(:vm_push,  @vm.step)
      assert_equal(:vm_io,    @vm.step)
    end
    assert_equal(:halt, @vm.state)
  end

  # vm_j
  def test_vmop_013
    _dolit  = @vm.compile(nil, nil, :vm_dolit, :vm_next)
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _do = @vm.compile(nil, nil, :vm_do, :vm_next)
    _loop = @vm.compile(nil, nil, :vm_loop, :vm_next)
    _i = @vm.compile(nil, nil, :vm_i, :vm_next)
    _j = @vm.compile(nil, nil, :vm_j, :vm_next)
    _drop = @vm.compile(nil, nil, :vm_drop, :vm_next)
    # : test 2 0 do 2 0 do i j drop drop loop loop halt ;
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _dolit,
                  2,
                  _dolit,
                  0,
                  _do,
                  '@L2',
                  'L1',
                  _dolit,
                  2,
                  _dolit,
                  0,
                  _do,
                  '@L4',
                  'L3',
                  _i,
                  _j,
                  _drop,
                  _drop,
                  _loop,
                  '@L3',
                  'L4',
                  _loop,
                  '@L1',
                  'L2',
                  _halt,
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_do,      @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_do,      @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_r_fetch, @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_j,       @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      # i,j = 0,0
      assert_equal(0,           @vm.nos)
      assert_equal(0,           @vm.tos)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_loop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_r_fetch, @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_j,       @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      # i,j = 1,0
      assert_equal(1,           @vm.nos)
      assert_equal(0,           @vm.tos)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_loop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_loop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_do,      @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_r_fetch, @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_j,       @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      # i,j = 0,1
      assert_equal(0,           @vm.nos)
      assert_equal(1,           @vm.tos)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_loop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_r_fetch, @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_j,       @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      # i,j = 1,1
      assert_equal(1,           @vm.nos)
      assert_equal(1,           @vm.tos)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_loop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_loop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(:halt, @vm.state)
  end

  # vm_leave
  def test_vmop_014
    _dolit  = @vm.compile(nil, nil, :vm_dolit, :vm_next)
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _do = @vm.compile(nil, nil, :vm_do, :vm_next)
    _loop = @vm.compile(nil, nil, :vm_loop, :vm_next)
    _i = @vm.compile(nil, nil, :vm_i, :vm_next)
    _drop = @vm.compile(nil, nil, :vm_drop, :vm_next)
    _leave = @vm.compile(nil, nil, :vm_leave, :vm_next)
    # : test 10 0 do i drop leave 5 loop halt ;
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _dolit,
                  10,
                  _dolit,
                  0,
                  _do,
                  '@L2',
                  'L1',
                  _i,
                  _drop,
                  _leave,
                  5,
                  _dolit,
                  _loop,
                  '@L1',
                  'L2',
                  _halt,
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(0,         @vm.rdepth)
      # docol
      assert_equal(:vm_docol, @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(1,         @vm.rdepth)
      # 10
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(10,        @vm.tos)
      assert_equal(1,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # 0
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(0,         @vm.tos)
      assert_equal(2,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # do
      assert_equal(:vm_do,    @vm.step)
      assert_equal(4,         @vm.rdepth)
      assert_equal(10,        @vm.rnos)
      assert_equal(0,         @vm.rtos)
      assert_equal(:vm_nop,   @vm.step)

      # i (0)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(0,         @vm.tos)

      # drop (0)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # leave (0)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_leave, @vm.step)
      assert_equal(:vm_nop,   @vm.step)


      # halt
      assert_equal(1,         @vm.rdepth)
      assert_equal(0,         @vm.depth)
      assert_equal(:vm_push,  @vm.step)
      assert_equal(:vm_io,    @vm.step)
    end
    assert_equal(:halt, @vm.state)
  end
  
  # test_vmop_015 was vm_unloop

  # vm_question_do (positive through-loop case)
  def test_vmop_016
    _dolit  = @vm.compile(nil, nil, :vm_dolit, :vm_next)
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _qdo = @vm.compile(nil, nil, :vm_question_do, :vm_next)
    _loop = @vm.compile(nil, nil, :vm_loop, :vm_next)
    _i = @vm.compile(nil, nil, :vm_i, :vm_next)
    _drop = @vm.compile(nil, nil, :vm_drop, :vm_next)
    # : test 10 0 ?do i drop loop halt ;
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _dolit,
                  10,
                  _dolit,
                  0,
                  _qdo,
                  '@L2',
                  'L1',
                  _i,
                  _drop,
                  _loop,
                  '@L1',
                  'L2',
                  _halt,
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(0,         @vm.rdepth)
      # docol
      assert_equal(:vm_docol, @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(1,         @vm.rdepth)
      # 10
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(10,        @vm.tos)
      assert_equal(1,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # 0
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(0,         @vm.tos)
      assert_equal(2,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # ?do
      assert_equal(:vm_question_do,    @vm.step)
      assert_equal(4,         @vm.rdepth)
      assert_equal(10,        @vm.rnos)
      assert_equal(0,         @vm.rtos)
      assert_equal(:vm_nop,   @vm.step)

      # i (0)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(0,         @vm.tos)

      # drop (0)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (0)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (1)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(1,         @vm.tos)

      # drop (1)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (1)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (2)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(2,         @vm.tos)

      # drop (2)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (2)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (3)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(3,         @vm.tos)

      # drop (3)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (3)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (4)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(4,         @vm.tos)

      # drop (4)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (4)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (5)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(5,         @vm.tos)

      # drop (5)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (5)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (6)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(6,         @vm.tos)

      # drop (6)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (6)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (7)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(7,         @vm.tos)

      # drop (7)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (7)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (8)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(8,         @vm.tos)

      # drop (8)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (8)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # i (9)
      assert_equal(:vm_r_fetch,     @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(9,         @vm.tos)

      # drop (9)
      assert_equal(:vm_drop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      # loop (9)
      assert_equal(4,         @vm.rdepth)
      assert_equal(:vm_loop,  @vm.step)
      assert_equal(:vm_nop,   @vm.step)

      assert_equal(1,         @vm.rdepth)
      assert_equal(0,         @vm.depth)
      assert_equal(:vm_push,  @vm.step)
      assert_equal(:vm_io,    @vm.step)
    end
    assert_equal(:halt, @vm.state)
  end

  # vm_question_do (negative no-loop case)
  def test_vmop_017
    _dolit  = @vm.compile(nil, nil, :vm_dolit, :vm_next)
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _qdo = @vm.compile(nil, nil, :vm_question_do, :vm_next)
    _loop = @vm.compile(nil, nil, :vm_loop, :vm_next)
    _i = @vm.compile(nil, nil, :vm_i, :vm_next)
    _drop = @vm.compile(nil, nil, :vm_drop, :vm_next)
    # : test 0 0 ?do i drop loop halt ;
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  _dolit,
                  0,
                  _dolit,
                  0,
                  _qdo,
                  '@L2',
                  'L1',
                  _i,
                  _drop,
                  _loop,
                  '@L1',
                  'L2',
                  _halt,
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(0,         @vm.rdepth)
      # docol
      assert_equal(:vm_docol, @vm.step)
      assert_equal(:vm_nop,   @vm.step)
      assert_equal(1,         @vm.rdepth)
      # 0
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(0,         @vm.tos)
      assert_equal(1,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # 0
      assert_equal(:vm_dolit, @vm.step)
      assert_equal(0,         @vm.tos)
      assert_equal(2,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)
      # ?do
      assert_equal(:vm_question_do,    @vm.step)
      assert_equal(1,         @vm.rdepth)
      assert_equal(0,         @vm.depth)
      assert_equal(:vm_nop,   @vm.step)

      # halt
      assert_equal(1,         @vm.rdepth)
      assert_equal(0,         @vm.depth)
      assert_equal(:vm_push,  @vm.step)
      assert_equal(:vm_io,    @vm.step)
    end
    assert_equal(:halt, @vm.state)
  end


  # test_vmop_018 - was vm_catch
  # test_vmop_019 - was vm_catch - 0 throw
  # test_vmop_020 - was vm_catch - 1 throw

  # vm_s_quote
  def test_vmop_021
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _dosq  = @vm.compile(nil, nil, :vm_s_quote, :vm_next)
    _drop  = @vm.compile(nil, nil, :vm_drop, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    a = []
    s = "abcdefghijk"
    a << @vm.compile(nil, 
                     @vm.fetch(_docol), 
                     _dosq, 
                     '',
                     _drop,
                     _drop,
                     _exit)
    9.times do |n|

      a << @vm.compile(nil, 
                       @vm.fetch(_docol), 
                       _dosq, 
                       s[0..n],
                       _drop,
                       _drop,
                       _exit)
    end
    _test = 
      @vm.compile(nil, 
                  @vm.fetch(_docol), 
                  a[0],
                  a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],
                  _halt,
                  _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(0,           @vm.tos)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(1,           @vm.tos)
      assert_equal(s[0].ord,    @vm.c_fetch(@vm.nos))
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(2,           @vm.tos)
      assert_equal(s[0].ord,    @vm.c_fetch(@vm.nos))
      assert_equal(s[1].ord,    @vm.c_fetch(@vm.nos + 1))
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(3,           @vm.tos)
      assert_equal(s[0].ord,    @vm.c_fetch(@vm.nos))
      assert_equal(s[1].ord,    @vm.c_fetch(@vm.nos + 1))
      assert_equal(s[2].ord,    @vm.c_fetch(@vm.nos + 2))
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(4,           @vm.tos)
      assert_equal(s[0].ord,    @vm.c_fetch(@vm.nos))
      assert_equal(s[1].ord,    @vm.c_fetch(@vm.nos + 1))
      assert_equal(s[2].ord,    @vm.c_fetch(@vm.nos + 2))
      assert_equal(s[3].ord,    @vm.c_fetch(@vm.nos + 3))
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(5,           @vm.tos)
      assert_equal(s[0].ord,    @vm.c_fetch(@vm.nos))
      assert_equal(s[1].ord,    @vm.c_fetch(@vm.nos + 1))
      assert_equal(s[2].ord,    @vm.c_fetch(@vm.nos + 2))
      assert_equal(s[3].ord,    @vm.c_fetch(@vm.nos + 3))
      assert_equal(s[4].ord,    @vm.c_fetch(@vm.nos + 4))
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(6,           @vm.tos)
      assert_equal(s[0].ord,    @vm.c_fetch(@vm.nos))
      assert_equal(s[1].ord,    @vm.c_fetch(@vm.nos + 1))
      assert_equal(s[2].ord,    @vm.c_fetch(@vm.nos + 2))
      assert_equal(s[3].ord,    @vm.c_fetch(@vm.nos + 3))
      assert_equal(s[4].ord,    @vm.c_fetch(@vm.nos + 4))
      assert_equal(s[5].ord,    @vm.c_fetch(@vm.nos + 5))
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(7,           @vm.tos)
      assert_equal(s[0].ord,    @vm.c_fetch(@vm.nos))
      assert_equal(s[1].ord,    @vm.c_fetch(@vm.nos + 1))
      assert_equal(s[2].ord,    @vm.c_fetch(@vm.nos + 2))
      assert_equal(s[3].ord,    @vm.c_fetch(@vm.nos + 3))
      assert_equal(s[4].ord,    @vm.c_fetch(@vm.nos + 4))
      assert_equal(s[5].ord,    @vm.c_fetch(@vm.nos + 5))
      assert_equal(s[6].ord,    @vm.c_fetch(@vm.nos + 6))
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(8,           @vm.tos)
      assert_equal(s[0].ord,    @vm.c_fetch(@vm.nos))
      assert_equal(s[1].ord,    @vm.c_fetch(@vm.nos + 1))
      assert_equal(s[2].ord,    @vm.c_fetch(@vm.nos + 2))
      assert_equal(s[3].ord,    @vm.c_fetch(@vm.nos + 3))
      assert_equal(s[4].ord,    @vm.c_fetch(@vm.nos + 4))
      assert_equal(s[5].ord,    @vm.c_fetch(@vm.nos + 5))
      assert_equal(s[6].ord,    @vm.c_fetch(@vm.nos + 6))
      assert_equal(s[7].ord,    @vm.c_fetch(@vm.nos + 7))
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_s_quote, @vm.step)
      assert_equal(2,           @vm.depth)
      assert_equal(9,           @vm.tos)
      assert_equal(s[0].ord,    @vm.c_fetch(@vm.nos))
      assert_equal(s[1].ord,    @vm.c_fetch(@vm.nos + 1))
      assert_equal(s[2].ord,    @vm.c_fetch(@vm.nos + 2))
      assert_equal(s[3].ord,    @vm.c_fetch(@vm.nos + 3))
      assert_equal(s[4].ord,    @vm.c_fetch(@vm.nos + 4))
      assert_equal(s[5].ord,    @vm.c_fetch(@vm.nos + 5))
      assert_equal(s[6].ord,    @vm.c_fetch(@vm.nos + 6))
      assert_equal(s[7].ord,    @vm.c_fetch(@vm.nos + 7))
      assert_equal(s[8].ord,    @vm.c_fetch(@vm.nos + 8))
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(0,           @vm.depth)
    assert_equal(:halt, @vm.state)
  end

  # vm_does
  #
  # defining word:
  #   create <whatever> does> <colon-def> ;
  #   
  # 
  def test_vmop_022
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _plus  = @vm.compile(nil, nil, :vm_plus, :vm_next)
    _c_fetch  = @vm.compile(nil, nil, :vm_c_fetch, :vm_next)
    _drop  = @vm.compile(nil, nil, :vm_drop, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _dolit = @vm.compile(nil, nil, :vm_dolit, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _doer = @vm.compile(nil, nil, 
                        :vm_does, :vm_next, :vm_nop,
                        _plus, _c_fetch, _exit)
    _defn = @vm.compile(nil, @vm.fetch(_doer), 0x12345678)
    _test = @vm.compile(nil, @vm.fetch(_docol),
                        _dolit, 0, _defn, _drop,
                        _dolit, 1, _defn, _drop,
                        _dolit, 2, _defn, _drop,
                        _dolit, 3, _defn, _drop,
                        _halt,
                        _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_does,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_plus,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_c_fetch, @vm.step)
      assert_equal(1,           @vm.depth)
      if @vm.bigendian
        assert_equal(0x12,        @vm.tos)
      else
        assert_equal(0x78,        @vm.tos)
      end
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_does,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_plus,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_c_fetch, @vm.step)
      assert_equal(1,           @vm.depth)
      if @vm.bigendian
        assert_equal(0x34,        @vm.tos)
      else
        assert_equal(0x56,        @vm.tos)
      end
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_does,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_plus,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_c_fetch, @vm.step)
      assert_equal(1,           @vm.depth)
      if @vm.bigendian
        assert_equal(0x56,        @vm.tos)
      else
        assert_equal(0x34,        @vm.tos)
      end
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_does,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_plus,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_c_fetch, @vm.step)
      assert_equal(1,           @vm.depth)
      if @vm.bigendian
        assert_equal(0x78,        @vm.tos)
      else
        assert_equal(0x12,        @vm.tos)
      end
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_exit,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(0,           @vm.depth)
    assert_equal(:halt,       @vm.state)
  end

  # vm_c_fetch
  # vm_c_store
  # vm_fetch
  # vm_store
  # vm_and
  # vm_or
  # vm_xor
  # vm_minus
  # vm_plus
  # vm_star
  # vm_star_slash
  # vm_star_slash_mod
  # vm_depth
  # vm_uless
  # vm_slash
  # vm_slash_mod
  # vm_dash_rot
  # vm_rot
  # vm_drop
  # vm_pick
  # vm_dup
  # vm_swap
  # vm_over
  # vm_to_r
  # vm_r_fetch
  # vm_r_from
  # 
  def test_vmop_023
    @vm.asm(0) # scratch space
    
    _halt = @vm.compile(nil, nil, :vm_halt, :vm_next)
    _c_fetch = @vm.compile(nil, nil, :vm_c_fetch, :vm_next)
    _c_store = @vm.compile(nil, nil, :vm_c_store, :vm_next)
    _fetch = @vm.compile(nil, nil, :vm_fetch, :vm_next)
    _store = @vm.compile(nil, nil, :vm_store, :vm_next)
    _and = @vm.compile(nil, nil, :vm_and, :vm_next)
    _or = @vm.compile(nil, nil, :vm_or, :vm_next)
    _xor = @vm.compile(nil, nil, :vm_xor, :vm_next)
    _minus = @vm.compile(nil, nil, :vm_minus, :vm_next)
    _plus = @vm.compile(nil, nil, :vm_plus, :vm_next)
    _star = @vm.compile(nil, nil, :vm_star, :vm_next)
    _star_slash = @vm.compile(nil, nil, :vm_star_slash, :vm_next)
    _star_slash_mod = @vm.compile(nil, nil, :vm_star_slash_mod, :vm_next)
    _depth = @vm.compile(nil, nil, :vm_depth, :vm_next)
    _uless = @vm.compile(nil, nil, :vm_uless, :vm_next)
    _slash = @vm.compile(nil, nil, :vm_slash, :vm_next)
    _slash_mod = @vm.compile(nil, nil, :vm_slash_mod, :vm_next)
    _dash_rot = @vm.compile(nil, nil, :vm_dash_rot, :vm_next)
    _rot = @vm.compile(nil, nil, :vm_rot, :vm_next)
    _drop = @vm.compile(nil, nil, :vm_drop, :vm_next)
    _pick = @vm.compile(nil, nil, :vm_pick, :vm_next)
    _dup = @vm.compile(nil, nil, :vm_dup, :vm_next)
    _swap = @vm.compile(nil, nil, :vm_swap, :vm_next)
    _over = @vm.compile(nil, nil, :vm_over, :vm_next)
    _to_r = @vm.compile(nil, nil, :vm_to_r, :vm_next)
    _r_fetch = @vm.compile(nil, nil, :vm_r_fetch, :vm_next)
    _r_from = @vm.compile(nil, nil, :vm_r_from, :vm_next)
    _docol = @vm.compile(nil, nil, :vm_docol, :vm_next)
    _dolit = @vm.compile(nil, nil, :vm_dolit, :vm_next)
    _exit = @vm.compile(nil, nil, :vm_exit, :vm_next)
    _test = @vm.compile(nil, @vm.fetch(_docol),
                        _dolit, 0,
                        _dolit, 1,
                        _dolit, 2,
                        _dolit, 2,
                        _and,
                        _dash_rot,
                        _c_store,
                        _drop,
                        _dolit, 0,
                        _c_fetch, _drop,
                        _depth,
                        _drop,
                        _dolit, 0,
                        _dup,
                        _fetch,
                        _swap,
                        _store,
                        _dolit, 0,
                        _dup,
                        _minus,
                        _dup,
                        _dup,
                        _dup,
                        _or,
                        _rot,
                        _dolit, 1,
                        _pick,
                        _over,
                        _dolit, 1,
                        _plus,
                        _slash_mod,
                        _xor,
                        _star,
                        _uless,
                        _dolit, 1,
                        _plus,
                        _slash,
                        _to_r,
                        _r_fetch,
                        _r_from,
                        _dup,
                        _dolit, 1,
                        _plus,
                        _star_slash_mod,
                        _dup,
                        _dolit, 1,
                        _plus,
                        _star_slash,
                        _drop,
                        _halt,
                        _exit)
    @vm.boot(_test)
    catch :halt do
      assert_equal(:vm_docol,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_and,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dash_rot,        @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_c_store, @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_c_fetch, @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_depth,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dup,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_fetch,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_swap,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_store,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dup,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_minus,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dup,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dup,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dup,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_or,      @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_rot,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_pick,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_over,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_plus,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_slash_mod,       @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_xor,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_star,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_uless,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_plus,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_slash,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_to_r,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_r_fetch, @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_r_from,  @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dup,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_plus,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_star_slash_mod,  @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dup,     @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_dolit,   @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_plus,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_star_slash,      @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_drop,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(0,           @vm.depth)
    assert_equal(:halt,       @vm.state)
  end

  # vm_push
  def test_vmop_024
    v = 0
    @vm.asm(@vm.databytes)
    @vm.asm(:vm_push, v)
    @vm.asm(:vm_nop)
    @vm.asm(:vm_halt)
    @vm.boot(0)

    catch :halt do
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(:halt,       @vm.state)
    assert_equal(1,           @vm.depth)
    assert_equal(v,           @vm.tos)
  end

  def test_vmop_025
    v = 1
    @vm.asm(@vm.databytes)
    @vm.asm(:vm_push, v)
    @vm.asm(:vm_nop)
    @vm.asm(:vm_halt)
    @vm.boot(0)

    catch :halt do
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(:halt,       @vm.state)
    assert_equal(1,           @vm.depth)
    assert_equal(v,           @vm.tos)
  end


  def test_vmop_026
    v = -1
    @vm.asm(@vm.databytes)
    @vm.asm(:vm_push, v)
    @vm.asm(:vm_nop)
    @vm.asm(:vm_halt)
    @vm.boot(0)

    catch :halt do
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(:halt,       @vm.state)
    assert_equal(1,           @vm.depth)
    assert_equal(v,           @vm.signed(@vm.tos))
  end

  # test_vmop_027 was vm_push(256)
  # test_vmop_028 was vm_push raise IllegalExtensionError

  def test_vmop_029
    v = -1
    @vm.asm(@vm.databytes)
    @vm.asm(:vm_push, v)
    @vm.asm(:vm_nop)
    @vm.asm(:vm_halt)
    @vm.boot(0)
    catch :halt do
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(:halt,       @vm.state)
    assert_equal(1,           @vm.depth)
    assert_equal(-1,          @vm.signed(@vm.tos))
  end

  def test_vmop_030
    v = -2
    @vm.asm(@vm.databytes)
    @vm.asm(:vm_push, v)
    @vm.asm(:vm_nop)
    @vm.asm(:vm_halt)
    @vm.boot(0)
    catch :halt do
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_nop,     @vm.step)
      assert_equal(:vm_push,    @vm.step)
      assert_equal(:vm_io,      @vm.step)
    end
    assert_equal(:halt,       @vm.state)
    assert_equal(1,           @vm.depth)
    assert_equal(-2,          @vm.signed(@vm.tos))
  end


# vm_dovar
# vm_io
# vm_reset
# vm_rp_store
# vm_sp_store


end
