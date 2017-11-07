#
#  xdict.rb
#
#  Copyright (c) 2015 by Daniel Kelley
#
#

module XDict

  extend NoRedef

# empty function for stat baseline
def test_empty_colondef
    rsp = exec(": test ;")
    stk = stack(rsp)
    assert_equal([], stk)
end

# digit
def test_stack_108_01
    rsp = exec(": test [char] 0 2 digit ;")
    stk = stack(rsp)
    assert_equal([0, -1], stk)
end

def test_stack_108_02
    rsp = exec(": test [char] 0 toupper ;")
    stk = stack(rsp)
    assert_equal([48], stk)
end

def test_stack_108_03
    rsp = exec(": test [char] 0 [char] a [char] { within ;")
    stk = stack(rsp)
    assert_equal([0], stk)
end

# >number
  def test_stack_109
    rsp = exec <<EOF

: test 0. s" 123" >number ;

EOF
    stk = stack(rsp)
    assert_equal(4, stk.length)
    assert_equal(0, stk[3])
    assert_not_equal(0, stk[2])
    assert_equal(0, stk[1])
    assert_equal(123, stk[0])
    # assert_equal(4, @vc.vm.tos)
    # assert_not_equal(0, @vc.vm.nos)
    # assert_equal(0, @vc.vm.pick(2))
    # assert_equal(123, @vc.vm.pick(3))
  end


  def test_stack_109_1
    rsp = exec <<EOF

: test 0. s" .123" >number ;

EOF
    stk = stack(rsp)
    assert_equal(4, stk.length)
    assert_equal(4, stk[3])
    assert_not_equal(0, stk[2])
    assert_equal(0, stk[1])
    assert_equal(0, stk[0])
    # assert_equal(4, @vc.vm.tos)
    # assert_not_equal(0, @vc.vm.nos)
    # assert_equal(0, @vc.vm.pick(2))
    # assert_equal(0, @vc.vm.pick(3))
  end

  def test_stack_109_2
    rsp = exec <<EOF

: test 0. s" 1.23" >number ;

EOF
    stk = stack(rsp)
    assert_equal(4, stk.length)
    assert_equal(3, stk[3])
    assert_not_equal(0, stk[2])
    assert_equal(0, stk[1])
    assert_equal(1, stk[0])
    # assert_equal(3, @vc.vm.tos)
    # assert_not_equal(0, @vc.vm.nos)
    # assert_equal(0, @vc.vm.pick(2))
    # assert_equal(1, @vc.vm.pick(3))
  end

  def test_stack_109_3
    rsp = exec <<EOF

: test 0. s" 12.3" >number ;

EOF
    stk = stack(rsp)
    assert_equal(4, stk.length)
    assert_equal(2, stk[3])
    assert_not_equal(0, stk[2])
    assert_equal(0, stk[1])
    assert_equal(12, stk[0])
    # assert_equal(2, @vc.vm.tos)
    # assert_not_equal(0, @vc.vm.nos)
    # assert_equal(0, @vc.vm.pick(2))
    # assert_equal(12, @vc.vm.pick(3))
  end

  def test_stack_109_4
    rsp = exec <<EOF

: test 0. s" 123." >number ;

EOF
    stk = stack(rsp)
    assert_equal(4, stk.length)
    assert_equal(1, stk[3])
    assert_not_equal(0, stk[2])
    assert_equal(0, stk[1])
    assert_equal(123, stk[0])
    # assert_equal(1, @vc.vm.tos)
    # assert_not_equal(0, @vc.vm.nos)
    # assert_equal(0, @vc.vm.pick(2))
    # assert_equal(123, @vc.vm.pick(3))
  end

# sgn
  def test_stack_110
    rsp = exec(": test -100 sgn 0 sgn 2 sgn ;")
    stk = stack(rsp)
    assert_equal([-1, 0, 1], stk)
    # assert_equal(1, @vc.vm.tos)
    # assert_equal(0, @vc.vm.nos)
    # assert_equal(-1, @vc.vm.signed(@vc.vm.pick(2)))
  end

# D+
  def test_stack_112
    rsp = exec ": test 0. 1. d+ ;"
    stk = stack(rsp)
    assert_equal([1, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(1, @vc.vm.nos)
  end

  def test_stack_112_1
    rsp = exec ": test 0. -1. d+ ;"
    stk = stack(rsp)
    assert_equal([-1, -1], stk)
    # assert_equal(@m1, @vc.vm.tos)
    # assert_equal(@m1, @vc.vm.nos)
  end

  def test_stack_112_2
    rsp = exec ": test -1. 1. d+ ;"
    stk = stack(rsp)
    assert_equal([0, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(0, @vc.vm.nos)
  end

# D-
  def test_stack_113
    rsp = exec ": test 0. 1. d- ;"
    stk = stack(rsp)
    assert_equal([-1, -1], stk)
    # assert_equal(@m1, @vc.vm.tos)
    # assert_equal(@m1, @vc.vm.nos)
  end

  def test_stack_113_1
    rsp = exec ": test 0. -1. d- ;"
    stk = stack(rsp)
    assert_equal([1, 0], stk)
  end

  def test_stack_113_2
    rsp = exec ": test 2. 1. d- ;"
    stk = stack(rsp)
    assert_equal([1, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(1, @vc.vm.nos)
  end

# dnegate
  def test_stack_114
    rsp = exec ": test 0. dnegate ;"
    stk = stack(rsp)
    assert_equal([0, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(0, @vc.vm.nos)
  end

  def test_stack_114_1
    rsp = exec ": test 1. dnegate ;"
    stk = stack(rsp)
    assert_equal([-1, -1], stk)
    # assert_equal(@m1, @vc.vm.tos)
    # assert_equal(@m1, @vc.vm.nos)
  end

  def test_stack_114_2
    rsp = exec ": test -1. dnegate ;"
    stk = stack(rsp)
    assert_equal([1, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(1, @vc.vm.nos)
  end

# n>r
# nr>
  def test_stack_115

    rsp = exec <<EOF

: test
   10 11 12 3 n>r nr>
;

EOF
    stk = stack(rsp)
    assert_equal([10, 11, 12, 3], stk)
    # assert_equal(3, @vc.vm.tos)
    # assert_equal(12, @vc.vm.nos)
    # assert_equal(11, @vc.vm.pick(2))
    # assert_equal(10, @vc.vm.pick(3))
  end

# rp@
  def test_stack_116
    rsp = exec ": test rp@ ;"
    stk = stack(rsp)
    assert_equal(1, stk.length)
  end

  def test_stack_116_1
    rsp = exec ": test 1 >r rp@ r> drop rp@ swap - (cell) /mod ;"
    stk = stack(rsp)
    assert_equal([0,1], stk)
  end

  def test_stack_116_2
    rsp = exec ": test 1 2 2>r rp@ 2r> 2drop rp@ swap - (cell) /mod ;"
    stk = stack(rsp)
    assert_equal([0,2], stk)
  end

# sp@
  def test_stack_117
    rsp = exec ": test sp@ ;"
    stk = stack(rsp)
    assert_equal(1, stk.length)
  end

  def test_stack_117_1
    rsp = exec ": test 1 sp@ >r drop sp@ r> - (cell) /mod ;"
    stk = stack(rsp)
    assert_equal([0,1], stk)
  end

  def test_stack_117_2
    rsp = exec ": test 1 2 sp@ >r 2drop sp@ r> - (cell) /mod ;"
    stk = stack(rsp)
    assert_equal([0,2], stk)
  end

# +-
  def test_stack_118_1
    rsp = exec ": test 10 1 +- ;"
    stk = stack(rsp)
    assert_equal([10], stk)
    # assert_equal(10, @vc.vm.tos)
  end

  def test_stack_118_2
    rsp = exec ": test 10 0 +- ;"
    stk = stack(rsp)
    assert_equal([10], stk)
    # assert_equal(10, @vc.vm.tos)
  end

  def test_stack_118_3
    rsp = exec ": test 10 -1 +- ;"
    stk = stack(rsp)
    assert_equal([-10], stk)
    # assert_equal(-10, @vc.vm.signed(@vc.vm.tos))
  end

  def test_stack_118_4
    rsp = exec ": test 10 -195 +- ;"
    stk = stack(rsp)
    assert_equal([-10], stk)
    # assert_equal(-10, @vc.vm.signed(@vc.vm.tos))
  end

# D+-
  def test_stack_119_1
    rsp = exec ": test 10. 1 d+- ;"
    stk = stack(rsp)
    assert_equal([10, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(10, @vc.vm.nos)
  end

  def test_stack_119_2
    rsp = exec ": test 10. 0 d+- ;"
    stk = stack(rsp)
    assert_equal([10, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(10, @vc.vm.nos)
  end

  def test_stack_119_3
    rsp = exec ": test 10. -1 d+- ;"
    stk = stack(rsp)
    assert_equal([-10, -1], stk)
    # assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    # assert_equal(-10, @vc.vm.signed(@vc.vm.nos))
  end

  def test_stack_119_4
    rsp = exec ": test 10. -1999 d+- ;"
    stk = stack(rsp)
    assert_equal([-10, -1], stk)
    # assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    # assert_equal(-10, @vc.vm.signed(@vc.vm.nos))
  end

# ut*
  def test_stack_120_1
    rsp = exec ": test 10. 5 ut* ;"
    stk = stack(rsp)
    assert_equal([50, 0, 0], stk)
    # assert_equal(0,  @vc.vm.tos)
    # assert_equal(0,  @vc.vm.nos)
    # assert_equal(50,  @vc.vm.pick(2))
  end

  # these fail, but x86_64 gives same answers as failed ones...
  def off_test_stack_120_2
    rsp = exec ": test #{@m} 0 #{@n} ut* ;"
    stk = stack(rsp)
    assert_equal([@m, @n/2, 0], stk)
    # assert_equal(0,  @vc.vm.tos)
    # assert_equal(@n/2,  @vc.vm.nos)
    # assert_equal(@m,  @vc.vm.pick(2))
  end

  # 3fffffff 7fffffff 80000001
  def off_test_stack_120_3
    rsp = exec ": test #{@nn}. #{@n} ut* ;"
    stk = stack(rsp)
    assert_equal([@n+2, @n, @n/2], stk)
    # assert_equal(@n/2,  @vc.vm.tos)
    # assert_equal(@n,  @vc.vm.nos)
    # assert_equal(@n+2,  @vc.vm.pick(2))
  end


# ut/mod
  def test_stack_121_1
    rsp = exec ": test 10 0 0 5 ut/mod ;"
    stk = stack(rsp)
    assert_equal([0, 2, 0, 0], stk)
    # assert_equal(0,  @vc.vm.tos)
    # assert_equal(0,  @vc.vm.nos)
    # assert_equal(2,  @vc.vm.pick(2))
    # assert_equal(0,  @vc.vm.pick(3))
  end

  def test_stack_121_2
    rsp = exec ": test 10 0 0 4 ut/mod ;"
    stk = stack(rsp)
    assert_equal([2, 2, 0, 0], stk)
    # assert_equal(0,  @vc.vm.tos)
    # assert_equal(0,  @vc.vm.nos)
    # assert_equal(2,  @vc.vm.pick(2))
    # assert_equal(2,  @vc.vm.pick(3))
  end

  def test_stack_121_3
    rsp = exec ": test -1 -1 -1 -1 ut/mod ;"
    stk = stack(rsp)
    assert_equal([0, 1, 1, 1], stk)
    # assert_equal(1,  @vc.vm.tos)
    # assert_equal(1,  @vc.vm.nos)
    # assert_equal(1,  @vc.vm.pick(2))
    # assert_equal(0,  @vc.vm.pick(3))
  end

# dabs
  def test_stack_122_1
    rsp = exec ": test 0. dabs ;"
    stk = stack(rsp)
    assert_equal([0, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(0, @vc.vm.nos)
  end

  def test_stack_122_2
    rsp = exec ": test 1. dabs ;"
    stk = stack(rsp)
    assert_equal([1, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(1, @vc.vm.nos)
  end

  def test_stack_122_3
    rsp = exec ": test -1. dabs ;"
    stk = stack(rsp)
    assert_equal([1, 0], stk)
    # assert_equal(0, @vc.vm.tos)
    # assert_equal(1, @vc.vm.nos)
  end

# bounds
  def test_stack_123
    rsp = exec ": test 10 1 bounds ;"
    stk = stack(rsp)
    assert_equal([11, 10], stk)
    # assert_equal(10, @vc.vm.tos)
    # assert_equal(11, @vc.vm.nos)
  end

# (number?)
  def test_xdict_001_01
    rsp = exec(': test s" x" (number?) ;')
    stk = stack(rsp)
    assert_equal([0], stk)
    # assert_equal(0, @vc.vm.tos)
  end

  def test_xdict_001_02
    rsp = exec(': test s" 2" (number?) ;')
    stk = stack(rsp)
    assert_equal([2, 1], stk)
    # assert_equal(1, @vc.vm.tos)
    # assert_equal(2, @vc.vm.nos)
  end

  def test_xdict_001_03
    rsp = exec(': test s" 4." (number?) ;')
    stk = stack(rsp)
    assert_equal([4, 0, 2], stk)
    # assert_equal(2, @vc.vm.tos)
    # assert_equal(0, @vc.vm.nos)
    # assert_equal(4, @vc.vm.pick(2))
  end

  def test_xdict_001_04
    rsp = exec(': test s" 3.x" (number?) ;')
    stk = stack(rsp)
    assert_equal([0], stk)
    # assert_equal(0, @vc.vm.tos)
  end

  def test_xdict_001_05
    rsp = exec(': test s" -" (number?) ;')
    stk = stack(rsp)
    assert_equal([0], stk)
    # assert_equal(0, @vc.vm.tos)
  end

  def test_xdict_001_06
    rsp = exec(': test s" -2" (number?) ;')
    stk = stack(rsp)
    assert_equal([-2, 1], stk)
    # assert_equal(1, @vc.vm.tos)
    # assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
  end

  def test_xdict_001_07
    rsp = exec(': test s" -3." (number?) ;')
    stk = stack(rsp)
    assert_equal([-3, -1, 2], stk)
    # assert_equal(2, @vc.vm.tos)
    # assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
    # assert_equal(-3, @vc.vm.signed(@vc.vm.pick(2)))
  end

  def test_xdict_001_08
    rsp = exec(': test s" -3.x" (number?) ;')
    stk = stack(rsp)
    assert_equal([0], stk)
    # assert_equal(0, @vc.vm.tos)
  end

# number?
  def test_xdict_002_01
    rsp = exec(': test s" x" number? ;')
    stk = stack(rsp)
    assert_equal([0], stk)
    # assert_equal(0, @vc.vm.tos)
  end

  def test_xdict_002_02
    rsp = exec(': test s" 2" number? ;')
    stk = stack(rsp)
    assert_equal([2, 1], stk)
    # assert_equal(1, @vc.vm.tos)
    # assert_equal(2, @vc.vm.nos)
  end

  def test_xdict_002_03
    rsp = exec(': test s" 4." number? ;')
    stk = stack(rsp)
    assert_equal([4, 0, 2], stk)
    # assert_equal(2, @vc.vm.tos)
    # assert_equal(0, @vc.vm.nos)
    # assert_equal(4, @vc.vm.pick(2))
  end

  def test_xdict_002_04
    rsp = exec(': test s" 3.x" number? ;')
    stk = stack(rsp)
    assert_equal([0], stk)
    # assert_equal(0, @vc.vm.tos)
  end

  def test_xdict_002_05
    rsp = exec(': test s" -" number? ;')
    stk = stack(rsp)
    assert_equal([0], stk)
    # assert_equal(0, @vc.vm.tos)
  end

  def test_xdict_002_06
    rsp = exec(': test s" -2" number? ;')
    stk = stack(rsp)
    assert_equal([-2, 1], stk)
    # assert_equal(1, @vc.vm.tos)
    # assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
  end

  def test_xdict_002_07
    rsp = exec(': test s" -4." number? ;')
    stk = stack(rsp)
    assert_equal([-4, -1, 2], stk)
    # assert_equal(2, @vc.vm.tos)
    # assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
    # assert_equal(-4, @vc.vm.signed(@vc.vm.pick(2)))
  end

  def test_xdict_002_08
    rsp = exec(': test s" -3.x" number? ;')
    stk = stack(rsp)
    assert_equal([0], stk)
    # assert_equal(0, @vc.vm.tos)
  end

  def test_xdict_002_09
    rsp = exec(': test s" \'x\'" number? ;')
    stk = stack(rsp)
    assert_equal([120, 1], stk)
    # assert_equal(1, @vc.vm.tos)
    # assert_equal(120, @vc.vm.nos)
  end

  def test_xdict_002_10
    rsp = exec(': test s" %1011" number? base @ ;')
    stk = stack(rsp)
    assert_equal([11, 1, 10], stk)
    # assert_equal(10, @vc.vm.tos)
    # assert_equal(1, @vc.vm.nos)
    # assert_equal(11, @vc.vm.pick(2))
  end

  def test_xdict_002_11
    rsp = exec(': test s" %1010.1010" number? ;')
    stk = stack(rsp)
    assert_equal([0xaa, 0, 2], stk)
    # assert_equal(2, @vc.vm.tos)
    # assert_equal(0, @vc.vm.nos)
    # assert_equal(0xaa, @vc.vm.pick(2))
  end

  def test_xdict_002_12
    rsp = exec(': test s" $27" number? base @ ;')
    stk = stack(rsp)
    assert_equal([0x27, 1, 10], stk)
    # assert_equal(10, @vc.vm.tos)
    # assert_equal(1, @vc.vm.nos)
    # assert_equal(0x27, @vc.vm.pick(2))
  end

  def test_xdict_002_13
    rsp = exec(': test hex s" #27" number? base @ ;')
    stk = stack(rsp)
    assert_equal([27, 1, 16], stk)
    # assert_equal(16, @vc.vm.tos)
    # assert_equal(1, @vc.vm.nos)
    # assert_equal(27, @vc.vm.pick(2))
  end

  def test_xdict_003_01
    rsp = exec(': test 1 0 3 2 2swap 0= ;')
    stk = stack(rsp)
    assert_equal([3, 2, 1, -1], stk)
  end

end
