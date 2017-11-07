#
#  vmcompiler.rb
#
#  Copyright (c) 2011 by Daniel Kelley
#
#  $Id:$
#
# Generic compiler tests


module VMCompiler

  extend NoRedef

  NUMU = 36

  def test_bwr
    @vc.parse(': test begin 0 while repeat ;')
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
  end

  def test_vm_0
    # smoke test
    @vc.compile
  end

  def test_decimal_num
    @vc.parse <<EOF

: test
    #{@n} 0 10 100 1000 10001
;

EOF

    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(10001, @vc.vm.tos)
    assert_equal(1000, @vc.vm.nos)
    assert_equal(100, @vc.vm.pick(2))
    assert_equal(10, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(@n, @vc.vm.pick(5))
  end

  def test_decimal_num_1

    @vc.parse <<EOF

: test
    100002 -1 -2 -10 -100 -1000
;

EOF

    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(-1000, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-100, @vc.vm.signed(@vc.vm.nos))
    assert_equal(-10, @vc.vm.signed(@vc.vm.pick(2)))
    assert_equal(-2, @vc.vm.signed(@vc.vm.pick(3)))
    assert_equal(-1, @vc.vm.signed(@vc.vm.pick(4)))
    assert_equal(100002, @vc.vm.pick(5))
  end

  def test_double_num
    @vc.parse(": test 10001. ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10001, @vc.vm.nos)
  end

  def test_double_num_1
    @vc.parse(": test -1. ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
  end

  def test_double_num_2
    @vc.parse(": test 1.1.1 ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.signed(@vc.vm.tos))
    assert_equal(111, @vc.vm.signed(@vc.vm.nos))
  end

  def test_double_num_3
    @vc.parse(": test .1 ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.signed(@vc.vm.tos))
    assert_equal(1, @vc.vm.signed(@vc.vm.nos))
  end


  def test_hex_num
    @vc.parse <<EOF

: test
    $#{@n.to_s(16)} $0 $10 $10f $10af $ffff
;

EOF

    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(0xffff, @vc.vm.tos)
    assert_equal(0x10af, @vc.vm.nos)
    assert_equal(0x10f, @vc.vm.pick(2))
    assert_equal(0x10, @vc.vm.pick(3))
    assert_equal(0x0, @vc.vm.pick(4))
    assert_equal(@n, @vc.vm.pick(5))
  end

  def test_hex_double_num
    @vc.parse(": test $a5.5a ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0xa55a, @vc.vm.nos)
  end


  def test_fwdref_colon
    @vc.parse <<EOF
: test0  test1 ;
: test1  1 ;
: test   test0 ;
EOF

    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
  end

  def test_fwdref_constant
    @vc.parse <<EOF
: test0  test1 ;
1 constant test1
: test   test0 ;
EOF

    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
  end

  def test_fwdref_variable
    @vc.parse <<EOF
: test0  test1 ;
variable test1
: test   test0 ;
EOF

    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.pfa('test1'), @vc.vm.tos)
    assert_equal(0, @vc.fetch('test1'))
  end

  # Stack
  # ---------------

  # 0=
  def test_stack_000
    # ( --- t f f )
    @vc.parse(': test 0 0= 1 0= -1 0= ;')
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
  end

  # -
  def test_stack_001
    @vc.parse <<EOF

: test

  #{@n} 1 -
  1 #{@n} -
  0 0 -
  0 1 -
  1 0 -

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(1 - @n, @vc.vm.signed(@vc.vm.pick(3)))
    assert_equal(@n - 1, @vc.vm.pick(4))
  end

  # +
  def test_stack_002
    @vc.parse <<EOF

: test

  #{@n} 1 +
  0 0 +
  0 1 +
  1 0 +
 -1 1 +
 -2 -2 +

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(-4, @vc.vm.signed(@vc.vm.tos))
    assert_equal(0, @vc.vm.nos)
    assert_equal(1, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(@n + 1, @vc.vm.pick(5))
  end

  # =
  def test_stack_003
    @vc.parse <<EOF

: test

  0 0 =
  0 1 =
  1 0 =
 -1 1 =
 -2 -2 =

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(@m1, @vc.vm.pick(4))
  end

# >r
# r>
  def test_stack_004
    @vc.parse <<EOF

: test

  1 >r
 -1 >r
  0 >r
  r>
  r>
  r>

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
    assert_equal(0, @vc.vm.pick(2))
  end

# r> 'stack empty'
  def test_stack_005
    @vc.parse <<EOF

: test
  >r
;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

# drop
  def test_stack_006
    @vc.parse <<EOF

: test

  1
 -1
  0
  drop
  drop

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
  end

# drop 'stack empty'
  def test_stack_007
    @vc.parse <<EOF

: test
  drop
;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

# char+
  def test_stack_008
    @vc.parse <<EOF

: test

  #{@n} char+
  0 char+
  1 char+
 -1 char+
 -2 char+

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(0, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
    assert_equal(@n + 1, @vc.vm.pick(4))
  end

# 1+
  def test_stack_009
    @vc.parse <<EOF

: test

  #{@m} 1+
  0 1+
  1 1+
 -1 1+
 -2 1+

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(0, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
    assert_equal(@m + 1, @vc.vm.pick(4))
  end

# swap
  def test_stack_010
    @vc.parse <<EOF

: test

  0 1 swap

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

# r@
  def test_stack_011
    @vc.parse <<EOF

: test

  1 >r
 -1 >r
  0 >r
  r@  0 =
  r@ r> =
  r@ -1 =
  r@ r> =
  r@  1 =
  r@ r> =

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal(@m1, @vc.vm.pick(3))
    assert_equal(@m1, @vc.vm.pick(4))
    assert_equal(@m1, @vc.vm.pick(5))
  end

# 1-
  def test_stack_012
    @vc.parse <<EOF

: test

  #{@m} 1-
  0 1-
  1 1-
 -1 1-
 -2 1-

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(-3, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(-1, @vc.vm.signed(@vc.vm.pick(3)))
    assert_equal(@m - 1, @vc.vm.pick(4))
  end

# dup
  def test_stack_013

    @vc.parse <<EOF

: test

  0 dup 1+
    dup 1+
    dup 1+

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
    assert_equal(1, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
  end

  def test_stack_013_1

    @vc.parse(": test dup ;")
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

# base

  def test_stack_014_2
    @vc.parse(": test base ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
  end


  def test_stack_014_3
    @vc.parse(": test  base @ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
  end

# @
# !
  def test_stack_015

    @vc.parse <<EOF

: test

  base @ 32 =
  32 base !
  base @ 32 =

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
  end

  def test_stack_015_1

    @vc.parse <<EOF

: test

  @

;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

  def test_stack_015_2

    @vc.parse <<EOF

: test

  0 !

;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

  def test_stack_015_3

    @vc.parse <<EOF

: test

  !

;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

# (here)
# here
  def test_stack_016

    @vc.parse(': test here ;')
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.vm.dot, @vc.vm.tos)
  end


# rot
  def test_stack_017

    @vc.parse <<EOF

: test
    1 2 3 rot
;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(3, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
  end

  def test_stack_018
    @vc.parse <<EOF

: test
  1 2 rot
;

EOF
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end


# <>
  def test_stack_019
    @vc.parse <<EOF

: test

  0 0 <>
  0 1 <>
  1 0 <>
 -1 1 <>
 -2 -2 <>

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal(@m1, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
  end

# *
  def test_stack_020
    n2 = (@n*@n)     & @m1
    n3 = ((@n+1)*@n) & @m1
    n4 = ((@n+2)*@n) & @m1

    @vc.parse <<EOF

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
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(8,  @vc.vm.depth)
    assert_equal(4,  @vc.vm.tos)
    assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
    assert_equal(-1, @vc.vm.signed(@vc.vm.pick(2)))
    assert_equal(n3, @vc.vm.pick(3))
    assert_equal(0,  @vc.vm.pick(4))
    assert_equal(@n, @vc.vm.pick(5))
    assert_equal(n2, @vc.vm.pick(6))
    assert_equal(n4, @vc.vm.pick(7))
  end

# 2r@
  def test_stack_021

    @vc.parse <<EOF

: test

  1 >r 2 >r 2r@ r> r>

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

# over
  def test_stack_022

    @vc.parse <<EOF

: test

  1 2 over

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
    assert_equal(1, @vc.vm.pick(2))
  end

  def test_stack_023
    @vc.parse <<EOF

: test
  1 over
;

EOF
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end


# 2drop
  def test_stack_024

    @vc.parse <<EOF

: test

  1 2 3 4 2drop

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

  def test_stack_025
    @vc.parse <<EOF

: test
  1 2drop
;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end


# -rot
  def test_stack_026

    @vc.parse <<EOF

: test
    1 2 3 -rot
;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
  end

  def test_stack_027
    @vc.parse <<EOF

: test
  1 2 -rot
;

EOF
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end


# /string
  def test_stack_028

    @vc.parse <<EOF

: test
    100 50 3 /string
;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(47, @vc.vm.tos)
    assert_equal(103, @vc.vm.nos)
  end

  def test_stack_029
    @vc.parse <<EOF

: test
  1 2 /string
;

EOF
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end


  def test_stack_030

    @vc.parse <<EOF

: test
    100 50 51 /string
;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(151, @vc.vm.nos)
  end


# 2>r
  def test_stack_031

    @vc.parse <<EOF

: test
    1 2 2>r 2r@ r> r>
;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

  def test_stack_032
    @vc.parse <<EOF

: test
  1 2>r
;

EOF
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end


# c@
# c!
  def test_stack_033

    @vc.parse <<EOF

: test

  base c@ 32 =
  32 base c!
  base c@ 32 =

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
  end

  def test_stack_033_1

    @vc.parse <<EOF

: test

  c@

;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

  def test_stack_033_2

    @vc.parse <<EOF

: test

  0 c!

;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

  def test_stack_032_3

    @vc.parse <<EOF

: test

  c!

;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

# 2r>
  def test_stack_034

    @vc.parse <<EOF

: test
    1 2 2>r 2r>
;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

  def test_stack_034_1

    @vc.parse <<EOF

: test

  2r>

;

EOF
    @vc.compile
    assert_raise GMPForth::StackEmptyError do
      @vc.run
    end
  end

# +!
  def test_stack_035

    @vc.parse <<EOF

: test

  base @ 32 =
  32 base !
  31 base +!
  base @ 63 =

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
  end

# ?dup
  def test_stack_036_1

    @vc.parse <<EOF

: test

  0 ?dup

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_stack_036_2

    @vc.parse <<EOF

: test

  1 ?dup

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

# 0<>
  def test_stack_037
    # ( --- t f f )
    @vc.parse(': test 0 0<> 1 0<> -1 0<> ;')
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
  end

# (cell)
  def test_stack_038
    @vc.parse(': test (cell) ;')
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.vm.databytes, @vc.vm.tos)
  end

# cells
  def test_stack_039

    @vc.parse <<EOF

: test

  -2 cells
  -1 cells
   0 cells
   1 cells
   2 cells

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(@vc.cells(2), @vc.vm.tos)
    assert_equal(@vc.cells(1), @vc.vm.nos)
    assert_equal(@vc.cells(0), @vc.vm.pick(2))
    assert_equal(@vc.cells(-1), @vc.vm.signed(@vc.vm.pick(3)))
    assert_equal(@vc.cells(-2), @vc.vm.signed(@vc.vm.pick(4)))
  end

# and
  def test_stack_040
    @vc.parse <<EOF

: test

  -1  1 and
   1 -1 and

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

# aligned
  def test_stack_041
    @vc.parse <<EOF

: test

  1 aligned
  0 aligned

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(@vc.vm.databytes, @vc.vm.nos)
  end

  def test_stack_041_1
    n = @vc.vm.databytes
    @vc.parse <<EOF

: test

    #{n+1} aligned
    #{n}   aligned

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(n, @vc.vm.tos)
    assert_equal(n*2, @vc.vm.nos)
  end

# allot
  def test_stack_042

    @vc.parse <<EOF

: test

  0 allot here
 10 allot here
 -5 allot here

;

EOF
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(here +  5, @vc.vm.tos)
    assert_equal(here + 10, @vc.vm.nos)
    assert_equal(here,      @vc.vm.pick(2))
  end


# um/mod
  def test_stack_043
    @vc.parse ": test 10 0 5 um/mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
    assert_equal(0,  @vc.vm.nos)
  end

  def test_stack_043_1
    @vc.parse ": test 10 0 4 um/mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
    assert_equal(2,  @vc.vm.nos)
  end

  def test_stack_043_2
    @vc.parse ": test -1 -1 -1 um/mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
    assert_equal(0,  @vc.vm.nos)
  end

# 0<
  def test_stack_044
    @vc.parse <<EOF

: test

     0 0<
     1 0<
    -1 0<
 #{@m} 0<
 #{@n} 0<

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
  end

# u<
  def test_stack_045
    @vc.parse <<EOF

: test

     0     0 u<
     0     1 u<
     1 #{@n} u<
 #{@n} #{@m} u<
 #{@m}    -2 u<
    -2    -1 u<

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal(@m1, @vc.vm.pick(3))
    assert_equal(@m1, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

  def test_stack_045_1
    @vc.parse <<EOF

: test

 #{@n} #{@n} u<
     1     0 u<
 #{@n}     1 u<
 #{@m} #{@n} u<
    -2 #{@m} u<
    -1    -2 u<

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

# ud/mod
  def test_stack_046
    @vc.parse ": test 10. 5 ud/mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(2,  @vc.vm.nos)
    assert_equal(0,  @vc.vm.pick(2))
  end

  def test_stack_046_1
    @vc.parse ": test 10. 4 ud/mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(2,  @vc.vm.nos)
    assert_equal(2,  @vc.vm.pick(2))
  end

  def test_stack_046_2
    @vc.parse ": test -1. -1 ud/mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
    assert_equal(1,  @vc.vm.nos)
    assert_equal(0,  @vc.vm.pick(2))
  end

# <
  def test_stack_047
    @vc.parse <<EOF

: test

     0     0 <
     0     1 <
     1 #{@n} <
 #{@n} #{@m} <
 #{@m}    -2 <
    -2    -1 <

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(@m1, @vc.vm.pick(3))
    assert_equal(@m1, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

  def test_stack_047_1
    @vc.parse <<EOF

: test

 #{@n} #{@n} <
     1     0 <
 #{@n}     1 <
 #{@m} #{@n} <
    -2 #{@m} <
    -1    -2 <

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

  def test_stack_047_2
    @vc.parse <<EOF

: test

 #{@m} #{@n} <

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
  end

# or
  def test_stack_048
    @vc.parse <<EOF

: test

   0  1 or
   1 -1 or

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

# roll
  def test_stack_049

    @vc.parse(": test 1 2 3 4 0 roll ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
    assert_equal(3, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

  def test_stack_049_1

    @vc.parse(": test 1 2 3 4 1 roll ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

  def test_stack_049_2

    @vc.parse(": test 1 2 3 4 2 roll ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

  def test_stack_049_3

    @vc.parse(": test 1 2 3 4 3 roll ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
  end

  def test_stack_049_4

    @vc.parse(": test 1 2 3 4 4 roll ;")
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end

# negative roll no longer supported

# 2dup
  def test_stack_050

    @vc.parse <<EOF

: test

  0. 2dup 1+
     2dup 1+
     2dup 1+

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(8, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(1, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
    assert_equal(0, @vc.vm.pick(6))
    assert_equal(0, @vc.vm.pick(7))
  end

  def test_stack_050_1

    @vc.parse(": test 2dup ;")
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end

  def test_stack_050_2

    @vc.parse(": test 0 2dup ;")
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end

# /
  def test_stack_051
    @vc.parse ": test 10 5 / ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
  end

  def test_stack_051_1
    @vc.parse ": test 10 4 / ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
  end

  def test_stack_051_2
    @vc.parse ": test -1 -1 / ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
  end

  def test_stack_051_3
    @vc.parse ": test -10 4 / ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(-3,  @vc.vm.signed(@vc.vm.tos))
  end

  def test_stack_051_4
    @vc.parse ": test 10 -4 / ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(-3,  @vc.vm.signed(@vc.vm.tos))
  end

# cell+
  def test_stack_052
    @vc.parse <<EOF

: test

  #{@m} cell+
  0 cell+
  1 cell+
  2 cell+
  3 cell+

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(3 + @vc.vm.addrbytes, @vc.vm.tos)
    assert_equal(2 + @vc.vm.addrbytes, @vc.vm.nos)
    assert_equal(1 + @vc.vm.addrbytes, @vc.vm.pick(2))
    assert_equal(0 + @vc.vm.addrbytes, @vc.vm.pick(3))
    assert_equal(@m + @vc.vm.addrbytes, @vc.vm.pick(4))
  end


# 2/
  def test_stack_053

    @vc.parse <<EOF

: test

  0 2/
  1 2/
  2 2/
  7 2/

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
  end


# 2*
  def test_stack_054

    @vc.parse <<EOF

: test

  0 2*
  1 2*
  2 2*
  7 2*

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(14, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
  end


# >
  def test_stack_055
    @vc.parse <<EOF

: test

     0     0 >
     0     1 >
     1 #{@n} >
 #{@n} #{@m} >
 #{@m}    -2 >
    -2    -1 >

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

  def test_stack_055_1
    @vc.parse <<EOF

: test

 #{@n} #{@n} >
     1     0 >
 #{@n}     1 >
 #{@m} #{@n} >
    -2 #{@m} >
    -1    -2 >

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(@m1, @vc.vm.pick(3))
    assert_equal(@m1, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

  def test_stack_055_2
    @vc.parse <<EOF

: test

 #{@m} #{@n} >

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

# pick
  def test_stack_056

    @vc.parse(": test 2 3 4 0 pick ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
  end

  def test_stack_056_1

    @vc.parse(": test 2 3 4 1 pick ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
  end

  def test_stack_056_2

    @vc.parse(": test 2 3 4 2 pick ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
  end

  def test_stack_056_3

    @vc.parse(": test 2 3 4 3 pick ;")
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end

# negate
  def test_stack_057
    @vc.parse <<EOF

: test

    0 negate
    1 negate
   -1 negate
 #{@n} negate
 #{@m} negate

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(@m, @vc.vm.tos)
    assert_equal(-@n, @vc.vm.signed(@vc.vm.nos))
    assert_equal(1, @vc.vm.pick(2))
    assert_equal(-1, @vc.vm.signed(@vc.vm.pick(3)))
    assert_equal(0, @vc.vm.pick(4))
  end

# 2swap
  def test_stack_058
    @vc.parse <<EOF

: test

  0 1 2 3 2swap

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
  end

# s>d
  def test_stack_059
    @vc.parse <<EOF

: test

  0 s>d 1 s>d -2 s>d

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

# xor
  def test_stack_060
    @vc.parse <<EOF

: test

   0  1 xor
   1 -1 xor

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(-2, @vc.vm.signed(@vc.vm.tos))
    assert_equal(1, @vc.vm.nos)
  end

# um*
  def test_stack_061
    @vc.parse ": test 10 5 um* ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(50,  @vc.vm.nos)
  end

  def test_stack_061_1
    @vc.parse ": test #{@m} #{@n} um* ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(@n/2,  @vc.vm.tos)
    assert_equal(@m,  @vc.vm.nos)
  end

# rshift
  def test_stack_062
    @vc.parse ": test 1 0 rshift ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
  end

  def test_stack_062_1
    @vc.parse ": test 4 2 rshift ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
  end

  def test_stack_062_2
    @vc.parse ": test -1 1 rshift ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(@vc.vm.max_uint/2,  @vc.vm.tos)
  end

# lshift
  def test_stack_063
    @vc.parse ": test 1 0 lshift ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
  end

  def test_stack_063_1
    @vc.parse ": test 4 2 lshift ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(16,  @vc.vm.tos)
  end

# min
  def test_stack_064
    @vc.parse <<EOF

: test

     0     0 min
     0     1 min
 #{@n}     1 min
 #{@n} #{@m} min
    -2 #{@m} min
    -2    -1 min

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(-2, @vc.vm.signed(@vc.vm.tos))
    assert_equal(@m, @vc.vm.nos)
    assert_equal(@m, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

# max
  def test_stack_065
    @vc.parse <<EOF

: test

     0     0 max
     0     1 max
 #{@n}     1 max
 #{@n} #{@m} max
    -2 #{@m} max
    -2    -1 max

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
    assert_equal(@n,  @vc.vm.pick(2))
    assert_equal(@n, @vc.vm.pick(3))
    assert_equal(1, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

# invert
  def test_stack_066
    @vc.parse <<EOF

: test

     0 invert
     1 invert
    -1 invert
 #{@n} invert
 #{@m} invert

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(@n, @vc.vm.tos)
    assert_equal(@m, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(-2, @vc.vm.signed(@vc.vm.pick(3)))
    assert_equal(-1, @vc.vm.signed(@vc.vm.pick(4)))
  end

# cs-roll
  def test_stack_068

    @vc.parse(": test 1 2 3 4 0 cs-roll ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
    assert_equal(3, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

  def test_stack_068_1

    @vc.parse(": test 1 2 3 4 1 cs-roll ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

  def test_stack_068_2

    @vc.parse(": test 1 2 3 4 2 cs-roll ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

  def test_stack_068_3

    @vc.parse(": test 1 2 3 4 3 cs-roll ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
  end

  def test_stack_068_4

    @vc.parse(": test 1 2 3 4 4 cs-roll ;")
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end

# cs-pick
  def test_stack_069

    @vc.parse(": test 2 3 4 0 cs-pick ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
  end

  def test_stack_069_1

    @vc.parse(": test 2 3 4 1 cs-pick ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
  end

  def test_stack_069_2

    @vc.parse(": test 2 3 4 2 cs-pick ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
  end

  def test_stack_069_3

    @vc.parse(": test 2 3 4 3 cs-pick ;")
    @vc.compile
    assert_raise GMPForth::StackShallowError do
      @vc.run
    end
  end

# (pad)
# pad
  def test_stack_070

    @vc.parse(": test (pad) pad here - ;")
    @vc.compile

    p_pad = @vc.fetch('(pad)')
    assert_not_equal(0, p_pad)

    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(p_pad, @vc.vm.tos)
    assert_equal(p_pad, @vc.vm.nos)
  end


# count
  def test_stack_071
    n = 63
    @vc.parse(": test #{n} pad c! pad dup count >r swap - r> ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(n, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

# chars
  def test_stack_072
    @vc.parse <<EOF

: test

   -2 chars
   -1 chars
    0 chars
    1 chars
    2 chars
;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal( 5, @vc.vm.depth)
    assert_equal( 2, @vc.vm.tos)
    assert_equal( 1, @vc.vm.nos)
    assert_equal( 0, @vc.vm.pick(2))
    assert_equal(-1, @vc.vm.signed(@vc.vm.pick(3)))
    assert_equal(-2, @vc.vm.signed(@vc.vm.pick(4)))
  end

# align
  def test_stack_073
    @vc.parse(": test here align here - ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_stack_073_1
    @vc.parse(": test here 0 c, align here swap - ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.vm.databytes, @vc.vm.tos)
  end

# abs
  def test_stack_074
    @vc.parse <<EOF

: test

     0 abs
     1 abs
    -1 abs
 #{@m} abs
 #{@n} abs

;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(@n, @vc.vm.tos)
    assert_equal(@m, @vc.vm.nos)
    assert_equal(1, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
  end

# 2over
  def test_stack_075
    @vc.parse(": test 0 1 2 3 2over ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(6, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(3, @vc.vm.pick(2))
    assert_equal(2, @vc.vm.pick(3))
    assert_equal(1, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
  end

# 2!
  def test_stack_076
    n = 32
    @vc.parse(": test #{n}. pad 2! pad @ pad cell+ @ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(n, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
  end

# 2@
  def test_stack_077
    n = 32
    @vc.parse(": test #{n}. pad 2! pad 2@ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(n, @vc.vm.nos)
  end

# /mod
  def test_stack_078
    @vc.parse ": test 10 5 /mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
    assert_equal(0,  @vc.vm.nos)
  end

  def test_stack_078_1
    @vc.parse ": test 10 4 /mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
    assert_equal(2,  @vc.vm.nos)
  end

  def test_stack_078_2
    @vc.parse ": test -1 -1 /mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
    assert_equal(0,  @vc.vm.nos)
  end

  def test_stack_078_3
    @vc.parse ": test -10 4 /mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(-3, @vc.vm.signed(@vc.vm.tos))
    assert_equal(2,  @vc.vm.nos)
  end

  def test_stack_078_4
    @vc.parse ": test 10 -4 /mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(-3, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
  end

# */mod
  def test_stack_079
    n1 = @n-1
    div = (@n * @n) / n1
    mod = (@n * @n) % n1
    @vc.parse ": test #{@n} #{@n} #{n1} */mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(div,  @vc.vm.tos)
    assert_equal(mod,  @vc.vm.nos)
  end

  def test_stack_079_1
    @vc.parse ": test 1 10 4 */mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
    assert_equal(2,  @vc.vm.nos)
  end

  def test_stack_079_2
    @vc.parse ": test 2 -1 -1 */mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
    assert_equal(0,  @vc.vm.nos)
  end

  def test_stack_079_3
    @vc.parse ": test 2 -5 4 */mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(-3, @vc.vm.signed(@vc.vm.tos))
    assert_equal(2,  @vc.vm.nos)
  end

  def test_stack_079_4
    @vc.parse ": test 2 5 -4 */mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(-3, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
  end

# */
  def test_stack_080
    n1 = @n-1
    div = (@n * @n) / n1
    @vc.parse ": test #{@n} #{@n} #{n1} */ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(div,  @vc.vm.tos)
  end

  def test_stack_080_1
    @vc.parse ": test 1 10 4 */ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
  end

  def test_stack_080_2
    @vc.parse ": test 2 -1 -1 */ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(2,  @vc.vm.tos)
  end

  def test_stack_080_3
    @vc.parse ": test 2 -5 4 */ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(-3, @vc.vm.signed(@vc.vm.tos))
  end

  def test_stack_080_4
    @vc.parse ": test 2 5 -4 */ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(-3, @vc.vm.signed(@vc.vm.tos))
  end

# environment?
  def test_stack_081
    @vc.parse ": test   0 0 environment? ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
  end

# fill
  def test_stack_082
    p = 0xa5

    @vc.parse ": test   pad dup 5 #{p} fill ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(p,  @vc.vm.c_fetch(pad + 0))
    assert_equal(p,  @vc.vm.c_fetch(pad + 1))
    assert_equal(p,  @vc.vm.c_fetch(pad + 2))
    assert_equal(p,  @vc.vm.c_fetch(pad + 3))
    assert_equal(p,  @vc.vm.c_fetch(pad + 4))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + 5)
    end
  end

  def test_stack_082_1
    p = 0xa5
    q = 0x5a
    @vc.parse ": test   pad dup 5 #{p} fill pad 1+ 3 #{q} fill ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(p,  @vc.vm.c_fetch(pad + 0))
    assert_equal(q,  @vc.vm.c_fetch(pad + 1))
    assert_equal(q,  @vc.vm.c_fetch(pad + 2))
    assert_equal(q,  @vc.vm.c_fetch(pad + 3))
    assert_equal(p,  @vc.vm.c_fetch(pad + 4))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + 5)
    end
  end

# within
  def test_stack_083
    @vc.parse <<EOF
: test
    0 0 1 within
    2 2 3 within
    0 0 0 within
    1 0 1 within
    2 0 1 within
   -1 0 1 within
;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(6,   @vc.vm.depth)
    assert_equal(0,   @vc.vm.tos)
    assert_equal(0,   @vc.vm.nos)
    assert_equal(0,   @vc.vm.pick(2))
    assert_equal(0,   @vc.vm.pick(3))
    assert_equal(@m1, @vc.vm.pick(4))
    assert_equal(@m1, @vc.vm.pick(5))
  end


# cmove
  def test_stack_084
    @vc.parse <<EOF
: ifill  0 do i over c! 1+ loop drop ;
: test pad 10 ifill pad pad 5 + 4 cmove pad ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(0,  @vc.vm.c_fetch(pad + 0))
    assert_equal(1,  @vc.vm.c_fetch(pad + 1))
    assert_equal(2,  @vc.vm.c_fetch(pad + 2))
    assert_equal(3,  @vc.vm.c_fetch(pad + 3))
    assert_equal(4,  @vc.vm.c_fetch(pad + 4))
    assert_equal(0,  @vc.vm.c_fetch(pad + 5))
    assert_equal(1,  @vc.vm.c_fetch(pad + 6))
    assert_equal(2,  @vc.vm.c_fetch(pad + 7))
    assert_equal(3,  @vc.vm.c_fetch(pad + 8))
    assert_equal(9,  @vc.vm.c_fetch(pad + 9))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + 10)
    end
  end

  def test_stack_084_1
    # 'fill' behavior with overlapping regions
    @vc.parse <<EOF
: ifill  0 do i over c! 1+ loop drop ;
: test pad 10 ifill pad pad 1+ 4 cmove pad ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(0,  @vc.vm.c_fetch(pad + 0))
    assert_equal(0,  @vc.vm.c_fetch(pad + 1))
    assert_equal(0,  @vc.vm.c_fetch(pad + 2))
    assert_equal(0,  @vc.vm.c_fetch(pad + 3))
    assert_equal(0,  @vc.vm.c_fetch(pad + 4))
    assert_equal(5,  @vc.vm.c_fetch(pad + 5))
    assert_equal(6,  @vc.vm.c_fetch(pad + 6))
    assert_equal(7,  @vc.vm.c_fetch(pad + 7))
    assert_equal(8,  @vc.vm.c_fetch(pad + 8))
    assert_equal(9,  @vc.vm.c_fetch(pad + 9))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + 10)
    end
  end

  def test_stack_084_2
    # 'move' behavior with overlapping regions
    @vc.parse <<EOF
: ifill  0 do i over c! 1+ loop drop ;
: test pad 10 ifill pad 1+ pad 4 cmove pad ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(1,  @vc.vm.c_fetch(pad + 0))
    assert_equal(2,  @vc.vm.c_fetch(pad + 1))
    assert_equal(3,  @vc.vm.c_fetch(pad + 2))
    assert_equal(4,  @vc.vm.c_fetch(pad + 3))
    assert_equal(4,  @vc.vm.c_fetch(pad + 4))
    assert_equal(5,  @vc.vm.c_fetch(pad + 5))
    assert_equal(6,  @vc.vm.c_fetch(pad + 6))
    assert_equal(7,  @vc.vm.c_fetch(pad + 7))
    assert_equal(8,  @vc.vm.c_fetch(pad + 8))
    assert_equal(9,  @vc.vm.c_fetch(pad + 9))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + 10)
    end
  end

# cmove>
  def test_stack_085
    @vc.parse <<EOF
: ifill  0 do i over c! 1+ loop drop ;
: test pad 10 ifill pad pad 5 + 4 cmove> pad ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(0,  @vc.vm.c_fetch(pad + 0))
    assert_equal(1,  @vc.vm.c_fetch(pad + 1))
    assert_equal(2,  @vc.vm.c_fetch(pad + 2))
    assert_equal(3,  @vc.vm.c_fetch(pad + 3))
    assert_equal(4,  @vc.vm.c_fetch(pad + 4))
    assert_equal(0,  @vc.vm.c_fetch(pad + 5))
    assert_equal(1,  @vc.vm.c_fetch(pad + 6))
    assert_equal(2,  @vc.vm.c_fetch(pad + 7))
    assert_equal(3,  @vc.vm.c_fetch(pad + 8))
    assert_equal(9,  @vc.vm.c_fetch(pad + 9))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + 10)
    end
  end

  def test_stack_085_1
    # move' behavior with overlapping regions
    @vc.parse <<EOF
: ifill  0 do i over c! 1+ loop drop ;
: test pad 10 ifill pad pad 1+ 4 cmove> pad ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(0,  @vc.vm.c_fetch(pad + 0))
    assert_equal(0,  @vc.vm.c_fetch(pad + 1))
    assert_equal(1,  @vc.vm.c_fetch(pad + 2))
    assert_equal(2,  @vc.vm.c_fetch(pad + 3))
    assert_equal(3,  @vc.vm.c_fetch(pad + 4))
    assert_equal(5,  @vc.vm.c_fetch(pad + 5))
    assert_equal(6,  @vc.vm.c_fetch(pad + 6))
    assert_equal(7,  @vc.vm.c_fetch(pad + 7))
    assert_equal(8,  @vc.vm.c_fetch(pad + 8))
    assert_equal(9,  @vc.vm.c_fetch(pad + 9))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + 10)
    end
  end

  def test_stack_085_2
    # 'fill' behavior with overlapping regions
    @vc.parse <<EOF
: ifill  0 do i over c! 1+ loop drop ;
: test pad 10 ifill pad 1+ pad 4 cmove> pad ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(4,  @vc.vm.c_fetch(pad + 0))
    assert_equal(4,  @vc.vm.c_fetch(pad + 1))
    assert_equal(4,  @vc.vm.c_fetch(pad + 2))
    assert_equal(4,  @vc.vm.c_fetch(pad + 3))
    assert_equal(4,  @vc.vm.c_fetch(pad + 4))
    assert_equal(5,  @vc.vm.c_fetch(pad + 5))
    assert_equal(6,  @vc.vm.c_fetch(pad + 6))
    assert_equal(7,  @vc.vm.c_fetch(pad + 7))
    assert_equal(8,  @vc.vm.c_fetch(pad + 8))
    assert_equal(9,  @vc.vm.c_fetch(pad + 9))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + 10)
    end
  end

# move
  def test_stack_086
    @vc.parse <<EOF
: ifill  0 do i over c! 1+ loop drop ;
: test pad 10 ifill pad pad 5 + 4 move pad ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(0,  @vc.vm.c_fetch(pad + 0))
    assert_equal(1,  @vc.vm.c_fetch(pad + 1))
    assert_equal(2,  @vc.vm.c_fetch(pad + 2))
    assert_equal(3,  @vc.vm.c_fetch(pad + 3))
    assert_equal(4,  @vc.vm.c_fetch(pad + 4))
    assert_equal(0,  @vc.vm.c_fetch(pad + 5))
    assert_equal(1,  @vc.vm.c_fetch(pad + 6))
    assert_equal(2,  @vc.vm.c_fetch(pad + 7))
    assert_equal(3,  @vc.vm.c_fetch(pad + 8))
    assert_equal(9,  @vc.vm.c_fetch(pad + 9))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + @vc.cells(10))
    end
  end

  def test_stack_086_1
    @vc.parse <<EOF
: ifill  0 do i over c! 1+ loop drop ;
: test pad 10 ifill pad pad 1+ 4 move pad ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(0,  @vc.vm.c_fetch(pad + 0))
    assert_equal(0,  @vc.vm.c_fetch(pad + 1))
    assert_equal(1,  @vc.vm.c_fetch(pad + 2))
    assert_equal(2,  @vc.vm.c_fetch(pad + 3))
    assert_equal(3,  @vc.vm.c_fetch(pad + 4))
    assert_equal(5,  @vc.vm.c_fetch(pad + 5))
    assert_equal(6,  @vc.vm.c_fetch(pad + 6))
    assert_equal(7,  @vc.vm.c_fetch(pad + 7))
    assert_equal(8,  @vc.vm.c_fetch(pad + 8))
    assert_equal(9,  @vc.vm.c_fetch(pad + 9))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + @vc.cells(10))
    end
  end

  def test_stack_086_2
    @vc.parse <<EOF
: ifill  0 do i over c! 1+ loop drop ;
: test pad 10 ifill pad 1+ pad 4 move pad ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1,  @vc.vm.depth)

    pad = @vc.vm.tos
    # region before fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad - 1)
    end
    # fill region should match
    assert_equal(1,  @vc.vm.c_fetch(pad + 0))
    assert_equal(2,  @vc.vm.c_fetch(pad + 1))
    assert_equal(3,  @vc.vm.c_fetch(pad + 2))
    assert_equal(4,  @vc.vm.c_fetch(pad + 3))
    assert_equal(4,  @vc.vm.c_fetch(pad + 4))
    assert_equal(5,  @vc.vm.c_fetch(pad + 5))
    assert_equal(6,  @vc.vm.c_fetch(pad + 6))
    assert_equal(7,  @vc.vm.c_fetch(pad + 7))
    assert_equal(8,  @vc.vm.c_fetch(pad + 8))
    assert_equal(9,  @vc.vm.c_fetch(pad + 9))
    # region after fill should be uninitialized
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad + @vc.cells(10))
    end
  end

# depth
  def test_stack_087
    @vc.parse ": test depth depth depth ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
  end

# ,
  def test_stack_088
    @vc.parse ": test here dup , here , here , here ;"
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(here + @vc.cells(3), @vc.vm.tos)
    assert_equal(here + @vc.cells(0), @vc.vm.nos)
    assert_equal(here + @vc.cells(2), @vc.vm.fetch(here + @vc.cells(2)))
    assert_equal(here + @vc.cells(1), @vc.vm.fetch(here + @vc.cells(1)))
    assert_equal(here + @vc.cells(0), @vc.vm.fetch(here + @vc.cells(0)))
  end

# c,
  def test_stack_089
    @vc.parse ": test here 0 c, 1 c, 2 c, here ;"
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(here + 3, @vc.vm.tos)
    assert_equal(here + 0, @vc.vm.nos)
    assert_equal(2, @vc.vm.c_fetch(here + 2))
    assert_equal(1, @vc.vm.c_fetch(here + 1))
    assert_equal(0, @vc.vm.c_fetch(here + 0))
  end

# s"
  def test_stack_090
    s = "this is a test"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
    assert_equal(s[2].ord, @vc.vm.c_fetch(addr + 2))
    assert_equal(s[3].ord, @vc.vm.c_fetch(addr + 3))
    assert_equal(s[4].ord, @vc.vm.c_fetch(addr + 4))
    assert_equal(s[5].ord, @vc.vm.c_fetch(addr + 5))
    assert_equal(s[6].ord, @vc.vm.c_fetch(addr + 6))
    assert_equal(s[7].ord, @vc.vm.c_fetch(addr + 7))
    assert_equal(s[8].ord, @vc.vm.c_fetch(addr + 8))
    assert_equal(s[9].ord, @vc.vm.c_fetch(addr + 9))
    assert_equal(s[10].ord, @vc.vm.c_fetch(addr + 10))
    assert_equal(s[11].ord, @vc.vm.c_fetch(addr + 11))
    assert_equal(s[12].ord, @vc.vm.c_fetch(addr + 12))
    assert_equal(s[13].ord, @vc.vm.c_fetch(addr + 13))
  end

  def test_stack_090_01
    s = ""
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
  end

  def test_stack_090_02
    s = "a"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
  end

  def test_stack_090_03
    s = "ab"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
  end

  def test_stack_090_04
    s = "abc"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
    assert_equal(s[2].ord, @vc.vm.c_fetch(addr + 2))
  end

  def test_stack_090_05
    s = "abcd"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
    assert_equal(s[2].ord, @vc.vm.c_fetch(addr + 2))
    assert_equal(s[3].ord, @vc.vm.c_fetch(addr + 3))
  end

  def test_stack_090_06
    s = "abcde"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
    assert_equal(s[2].ord, @vc.vm.c_fetch(addr + 2))
    assert_equal(s[3].ord, @vc.vm.c_fetch(addr + 3))
    assert_equal(s[4].ord, @vc.vm.c_fetch(addr + 4))
  end

  def test_stack_090_07
    s = "abdcdef"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
    assert_equal(s[2].ord, @vc.vm.c_fetch(addr + 2))
    assert_equal(s[3].ord, @vc.vm.c_fetch(addr + 3))
    assert_equal(s[4].ord, @vc.vm.c_fetch(addr + 4))
    assert_equal(s[5].ord, @vc.vm.c_fetch(addr + 5))
  end

  def test_stack_090_08
    s = "abcdefg"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
    assert_equal(s[2].ord, @vc.vm.c_fetch(addr + 2))
    assert_equal(s[3].ord, @vc.vm.c_fetch(addr + 3))
    assert_equal(s[4].ord, @vc.vm.c_fetch(addr + 4))
    assert_equal(s[5].ord, @vc.vm.c_fetch(addr + 5))
    assert_equal(s[6].ord, @vc.vm.c_fetch(addr + 6))
  end

  def test_stack_090_09
    s = "abcdefgh"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
    assert_equal(s[2].ord, @vc.vm.c_fetch(addr + 2))
    assert_equal(s[3].ord, @vc.vm.c_fetch(addr + 3))
    assert_equal(s[4].ord, @vc.vm.c_fetch(addr + 4))
    assert_equal(s[5].ord, @vc.vm.c_fetch(addr + 5))
    assert_equal(s[6].ord, @vc.vm.c_fetch(addr + 6))
    assert_equal(s[7].ord, @vc.vm.c_fetch(addr + 7))
  end

  def test_stack_090_10
    s = "abcdefghi"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
    assert_equal(s[2].ord, @vc.vm.c_fetch(addr + 2))
    assert_equal(s[3].ord, @vc.vm.c_fetch(addr + 3))
    assert_equal(s[4].ord, @vc.vm.c_fetch(addr + 4))
    assert_equal(s[5].ord, @vc.vm.c_fetch(addr + 5))
    assert_equal(s[6].ord, @vc.vm.c_fetch(addr + 6))
    assert_equal(s[7].ord, @vc.vm.c_fetch(addr + 7))
    assert_equal(s[8].ord, @vc.vm.c_fetch(addr + 8))
  end

  def test_stack_090_11
    s = "catch"
    @vc.parse ": test s\" #{s}\" 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(s.length, @vc.vm.nos)
    addr = @vc.vm.pick(2)
    assert_equal(s[0].ord, @vc.vm.c_fetch(addr + 0))
    assert_equal(s[1].ord, @vc.vm.c_fetch(addr + 1))
    assert_equal(s[2].ord, @vc.vm.c_fetch(addr + 2))
    assert_equal(s[3].ord, @vc.vm.c_fetch(addr + 3))
    assert_equal(s[4].ord, @vc.vm.c_fetch(addr + 4))
  end

# decimal
  def test_stack_091
    @vc.parse ": test decimal base @ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
  end

# hex
  def test_stack_092
    @vc.parse ": test hex base @ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(16, @vc.vm.tos)
  end

# [char]
  def test_stack_093
    @vc.parse ": test [char] 0 [char] - [char] X 1 ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(?X.ord, @vc.vm.nos)
    assert_equal(?-.ord, @vc.vm.pick(2))
    assert_equal(?0.ord, @vc.vm.pick(3))
  end

#
# Note: 'hold' will do a throw on pad underflow, but these tests are not
# prepared for that condition. Doing a quick test on "throw" ensures that
# the non-error condition is OK.
#
# 0 throw
  def test_stack_094
    @vc.parse ": test 1 0 throw ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
  end

# <#
  def test_stack_095
    @vc.parse ": test <# pad (hld) @ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@vc.vm.tos, @vc.vm.nos)
  end

# #>
  def test_stack_096
    @vc.parse ": test 0. <# #> pad ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.nos)
    assert_equal(@vc.vm.tos, @vc.vm.pick(2))
  end

# hold
  def test_stack_097
    @vc.parse ": test 0. <# [char] X hold #> ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    str = @vc.vm.nos
    assert_equal(?X.ord, @vc.vm.c_fetch(str))
  end

  def test_stack_097_1
    @vc.parse ": test 0. <# [char] X hold [char] Y hold #> ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    str = @vc.vm.nos
    assert_equal(?Y.ord, @vc.vm.c_fetch(str))
    assert_equal(?X.ord, @vc.vm.c_fetch(str + 1))
  end

# sign
  def test_stack_098
    @vc.parse ": test 0. <# dup sign #> ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_stack_098_1
    @vc.parse ": test 1. <# dup sign #> ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_stack_098_2
    @vc.parse ": test -1. <# dup sign #> ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    str = @vc.vm.nos
    assert_equal(?-.ord, @vc.vm.c_fetch(str))
  end

# #
  def test_stack_099
    @vc.parse ": test decimal 123. <# # # # # #> ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
    str = @vc.vm.nos
    assert_equal(?0.ord, @vc.vm.c_fetch(str + 0))
    assert_equal(?1.ord, @vc.vm.c_fetch(str + 1))
    assert_equal(?2.ord, @vc.vm.c_fetch(str + 2))
    assert_equal(?3.ord, @vc.vm.c_fetch(str + 3))
  end

# #s
  def test_stack_100
    @vc.parse ": test decimal 123. <# #s #> ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    str = @vc.vm.nos
    assert_equal(?1.ord, @vc.vm.c_fetch(str + 0))
    assert_equal(?2.ord, @vc.vm.c_fetch(str + 1))
    assert_equal(?3.ord, @vc.vm.c_fetch(str + 2))
  end

# rp!
  def test_stack_101
    assert_equal(true, @vc.vm.sepstack)
    @vc.parse ": test 0 rp! ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(0, @vc.vm.rdepth)
  end

  def test_stack_101_1
    assert_equal(true, @vc.vm.sepstack)
    @vc.parse ": test 1 rp! ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(1, @vc.vm.rdepth)
  end

  def test_stack_101_2
    assert_equal(true, @vc.vm.sepstack)
    @vc.parse ": test 1 >r 2 >r 3 >r 1 rp! ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(1, @vc.vm.rdepth)
  end

# sp!
  def test_stack_102
    assert_equal(true, @vc.vm.sepstack)
    @vc.parse ": test 0 sp! ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
  end

  def test_stack_102_1
    assert_equal(true, @vc.vm.sepstack)
    @vc.parse ": test 1 sp! ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
  end

  def test_stack_102_2
    assert_equal(true, @vc.vm.sepstack)
    @vc.parse ": test 1 2 3 1 sp! ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
  end

# (reset)
  def test_stack_103
    assert_equal(true, @vc.vm.sepstack)
    @vc.parse ": test (reset) ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
  end

# (does,)
  def test_stack_104
    @vc.parse ": test here (does,) here swap - ;"
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.vm.databytes, @vc.vm.signed(@vc.vm.tos))
    # test needs update for other machine sizes
    assert_equal(4, @vc.vm.databytes)
    op_does = GMPForth::VM::OPCODE0.index(:vm_does)
    op_nop = GMPForth::VM::OPCODE0.index(:vm_nop)
    assert_not_nil(op_does)
    assert_not_nil(op_nop)
    op_does += GMPForth::VM::OP_R
    assert_equal(op_does, @vc.vm.c_fetch(here))
    assert_equal(op_nop, @vc.vm.c_fetch(here+1))
    assert_equal(op_nop, @vc.vm.c_fetch(here+2))
    assert_equal(op_nop, @vc.vm.c_fetch(here+3))
  end

# M+
  def test_stack_105
    @vc.parse ": test 0. 1 m+ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

  def test_stack_105_1
    @vc.parse ": test 0. -1 m+ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
  end

  def test_stack_105_2
    @vc.parse ": test -1. 1 m+ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
  end

# M*/
  def test_stack_106
    n1 = @n-1
    div = (@n * @n) / n1
    @vc.parse ": test #{@n}. #{@n} #{n1} m*/ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(div,  @vc.vm.nos)
  end

  def test_stack_106_1
    @vc.parse ": test 1. 10 4 m*/ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(2,  @vc.vm.nos)
  end

  def test_stack_106_2
    @vc.parse ": test 2. -1 -1 m*/ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(2,  @vc.vm.nos)
  end

  def test_stack_106_3
    @vc.parse ": test 2. -5 4 m*/ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(@m1,  @vc.vm.tos)
    assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
  end

  def test_stack_106_4
    @vc.parse ": test 2. 5 -4 m*/ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(@m1,  @vc.vm.tos)
    assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
  end

  def test_stack_106_5
    @vc.parse ": test 100000000000000000. 314159265 1000000000 m*/ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2,  @vc.vm.depth)
    assert_equal(7314590,  @vc.vm.tos)
    assert_equal(1666351360, @vc.vm.nos)
  end

# toupper
  def test_stack_107
    @vc.parse ": test 256 0 do i toupper c, loop ;"
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run_limit = @vc.run_limit * 100
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(  0, @vc.vm.c_fetch(here +   0)) # "\000"
    assert_equal(  1, @vc.vm.c_fetch(here +   1)) # "\001"
    assert_equal(  2, @vc.vm.c_fetch(here +   2)) # "\002"
    assert_equal(  3, @vc.vm.c_fetch(here +   3)) # "\003"
    assert_equal(  4, @vc.vm.c_fetch(here +   4)) # "\004"
    assert_equal(  5, @vc.vm.c_fetch(here +   5)) # "\005"
    assert_equal(  6, @vc.vm.c_fetch(here +   6)) # "\006"
    assert_equal(  7, @vc.vm.c_fetch(here +   7)) # "\a"
    assert_equal(  8, @vc.vm.c_fetch(here +   8)) # "\b"
    assert_equal(  9, @vc.vm.c_fetch(here +   9)) # "\t"
    assert_equal( 10, @vc.vm.c_fetch(here +  10)) # "\n"
    assert_equal( 11, @vc.vm.c_fetch(here +  11)) # "\v"
    assert_equal( 12, @vc.vm.c_fetch(here +  12)) # "\f"
    assert_equal( 13, @vc.vm.c_fetch(here +  13)) # "\r"
    assert_equal( 14, @vc.vm.c_fetch(here +  14)) # "\016"
    assert_equal( 15, @vc.vm.c_fetch(here +  15)) # "\017"
    assert_equal( 16, @vc.vm.c_fetch(here +  16)) # "\020"
    assert_equal( 17, @vc.vm.c_fetch(here +  17)) # "\021"
    assert_equal( 18, @vc.vm.c_fetch(here +  18)) # "\022"
    assert_equal( 19, @vc.vm.c_fetch(here +  19)) # "\023"
    assert_equal( 20, @vc.vm.c_fetch(here +  20)) # "\024"
    assert_equal( 21, @vc.vm.c_fetch(here +  21)) # "\025"
    assert_equal( 22, @vc.vm.c_fetch(here +  22)) # "\026"
    assert_equal( 23, @vc.vm.c_fetch(here +  23)) # "\027"
    assert_equal( 24, @vc.vm.c_fetch(here +  24)) # "\030"
    assert_equal( 25, @vc.vm.c_fetch(here +  25)) # "\031"
    assert_equal( 26, @vc.vm.c_fetch(here +  26)) # "\032"
    assert_equal( 27, @vc.vm.c_fetch(here +  27)) # "\e"
    assert_equal( 28, @vc.vm.c_fetch(here +  28)) # "\034"
    assert_equal( 29, @vc.vm.c_fetch(here +  29)) # "\035"
    assert_equal( 30, @vc.vm.c_fetch(here +  30)) # "\036"
    assert_equal( 31, @vc.vm.c_fetch(here +  31)) # "\037"
    assert_equal( 32, @vc.vm.c_fetch(here +  32)) # " "
    assert_equal( 33, @vc.vm.c_fetch(here +  33)) # "!"
    assert_equal( 34, @vc.vm.c_fetch(here +  34)) # "\""
    assert_equal( 35, @vc.vm.c_fetch(here +  35)) # "#"
    assert_equal( 36, @vc.vm.c_fetch(here +  36)) # "$"
    assert_equal( 37, @vc.vm.c_fetch(here +  37)) # "%"
    assert_equal( 38, @vc.vm.c_fetch(here +  38)) # "&"
    assert_equal( 39, @vc.vm.c_fetch(here +  39)) # "'"
    assert_equal( 40, @vc.vm.c_fetch(here +  40)) # "("
    assert_equal( 41, @vc.vm.c_fetch(here +  41)) # ")"
    assert_equal( 42, @vc.vm.c_fetch(here +  42)) # "*"
    assert_equal( 43, @vc.vm.c_fetch(here +  43)) # "+"
    assert_equal( 44, @vc.vm.c_fetch(here +  44)) # ","
    assert_equal( 45, @vc.vm.c_fetch(here +  45)) # "-"
    assert_equal( 46, @vc.vm.c_fetch(here +  46)) # "."
    assert_equal( 47, @vc.vm.c_fetch(here +  47)) # "/"
    assert_equal( 48, @vc.vm.c_fetch(here +  48)) # "0"
    assert_equal( 49, @vc.vm.c_fetch(here +  49)) # "1"
    assert_equal( 50, @vc.vm.c_fetch(here +  50)) # "2"
    assert_equal( 51, @vc.vm.c_fetch(here +  51)) # "3"
    assert_equal( 52, @vc.vm.c_fetch(here +  52)) # "4"
    assert_equal( 53, @vc.vm.c_fetch(here +  53)) # "5"
    assert_equal( 54, @vc.vm.c_fetch(here +  54)) # "6"
    assert_equal( 55, @vc.vm.c_fetch(here +  55)) # "7"
    assert_equal( 56, @vc.vm.c_fetch(here +  56)) # "8"
    assert_equal( 57, @vc.vm.c_fetch(here +  57)) # "9"
    assert_equal( 58, @vc.vm.c_fetch(here +  58)) # ":"
    assert_equal( 59, @vc.vm.c_fetch(here +  59)) # ";"
    assert_equal( 60, @vc.vm.c_fetch(here +  60)) # "<"
    assert_equal( 61, @vc.vm.c_fetch(here +  61)) # "="
    assert_equal( 62, @vc.vm.c_fetch(here +  62)) # ">"
    assert_equal( 63, @vc.vm.c_fetch(here +  63)) # "?"
    assert_equal( 64, @vc.vm.c_fetch(here +  64)) # "@"
    assert_equal( 65, @vc.vm.c_fetch(here +  65)) # "A"
    assert_equal( 66, @vc.vm.c_fetch(here +  66)) # "B"
    assert_equal( 67, @vc.vm.c_fetch(here +  67)) # "C"
    assert_equal( 68, @vc.vm.c_fetch(here +  68)) # "D"
    assert_equal( 69, @vc.vm.c_fetch(here +  69)) # "E"
    assert_equal( 70, @vc.vm.c_fetch(here +  70)) # "F"
    assert_equal( 71, @vc.vm.c_fetch(here +  71)) # "G"
    assert_equal( 72, @vc.vm.c_fetch(here +  72)) # "H"
    assert_equal( 73, @vc.vm.c_fetch(here +  73)) # "I"
    assert_equal( 74, @vc.vm.c_fetch(here +  74)) # "J"
    assert_equal( 75, @vc.vm.c_fetch(here +  75)) # "K"
    assert_equal( 76, @vc.vm.c_fetch(here +  76)) # "L"
    assert_equal( 77, @vc.vm.c_fetch(here +  77)) # "M"
    assert_equal( 78, @vc.vm.c_fetch(here +  78)) # "N"
    assert_equal( 79, @vc.vm.c_fetch(here +  79)) # "O"
    assert_equal( 80, @vc.vm.c_fetch(here +  80)) # "P"
    assert_equal( 81, @vc.vm.c_fetch(here +  81)) # "Q"
    assert_equal( 82, @vc.vm.c_fetch(here +  82)) # "R"
    assert_equal( 83, @vc.vm.c_fetch(here +  83)) # "S"
    assert_equal( 84, @vc.vm.c_fetch(here +  84)) # "T"
    assert_equal( 85, @vc.vm.c_fetch(here +  85)) # "U"
    assert_equal( 86, @vc.vm.c_fetch(here +  86)) # "V"
    assert_equal( 87, @vc.vm.c_fetch(here +  87)) # "W"
    assert_equal( 88, @vc.vm.c_fetch(here +  88)) # "X"
    assert_equal( 89, @vc.vm.c_fetch(here +  89)) # "Y"
    assert_equal( 90, @vc.vm.c_fetch(here +  90)) # "Z"
    assert_equal( 91, @vc.vm.c_fetch(here +  91)) # "["
    assert_equal( 92, @vc.vm.c_fetch(here +  92)) # "\\"
    assert_equal( 93, @vc.vm.c_fetch(here +  93)) # "]"
    assert_equal( 94, @vc.vm.c_fetch(here +  94)) # "^"
    assert_equal( 95, @vc.vm.c_fetch(here +  95)) # "_"
    assert_equal( 96, @vc.vm.c_fetch(here +  96)) # "`"
    assert_equal( 65, @vc.vm.c_fetch(here +  97)) # "a"
    assert_equal( 66, @vc.vm.c_fetch(here +  98)) # "b"
    assert_equal( 67, @vc.vm.c_fetch(here +  99)) # "c"
    assert_equal( 68, @vc.vm.c_fetch(here + 100)) # "d"
    assert_equal( 69, @vc.vm.c_fetch(here + 101)) # "e"
    assert_equal( 70, @vc.vm.c_fetch(here + 102)) # "f"
    assert_equal( 71, @vc.vm.c_fetch(here + 103)) # "g"
    assert_equal( 72, @vc.vm.c_fetch(here + 104)) # "h"
    assert_equal( 73, @vc.vm.c_fetch(here + 105)) # "i"
    assert_equal( 74, @vc.vm.c_fetch(here + 106)) # "j"
    assert_equal( 75, @vc.vm.c_fetch(here + 107)) # "k"
    assert_equal( 76, @vc.vm.c_fetch(here + 108)) # "l"
    assert_equal( 77, @vc.vm.c_fetch(here + 109)) # "m"
    assert_equal( 78, @vc.vm.c_fetch(here + 110)) # "n"
    assert_equal( 79, @vc.vm.c_fetch(here + 111)) # "o"
    assert_equal( 80, @vc.vm.c_fetch(here + 112)) # "p"
    assert_equal( 81, @vc.vm.c_fetch(here + 113)) # "q"
    assert_equal( 82, @vc.vm.c_fetch(here + 114)) # "r"
    assert_equal( 83, @vc.vm.c_fetch(here + 115)) # "s"
    assert_equal( 84, @vc.vm.c_fetch(here + 116)) # "t"
    assert_equal( 85, @vc.vm.c_fetch(here + 117)) # "u"
    assert_equal( 86, @vc.vm.c_fetch(here + 118)) # "v"
    assert_equal( 87, @vc.vm.c_fetch(here + 119)) # "w"
    assert_equal( 88, @vc.vm.c_fetch(here + 120)) # "x"
    assert_equal( 89, @vc.vm.c_fetch(here + 121)) # "y"
    assert_equal( 90, @vc.vm.c_fetch(here + 122)) # "z"
    assert_equal(123, @vc.vm.c_fetch(here + 123)) # "{"
    assert_equal(124, @vc.vm.c_fetch(here + 124)) # "|"
    assert_equal(125, @vc.vm.c_fetch(here + 125)) # "}"
    assert_equal(126, @vc.vm.c_fetch(here + 126)) # "~"
    assert_equal(127, @vc.vm.c_fetch(here + 127)) # "\177"
    assert_equal(128, @vc.vm.c_fetch(here + 128)) # "\200"
    assert_equal(129, @vc.vm.c_fetch(here + 129)) # "\201"
    assert_equal(130, @vc.vm.c_fetch(here + 130)) # "\202"
    assert_equal(131, @vc.vm.c_fetch(here + 131)) # "\203"
    assert_equal(132, @vc.vm.c_fetch(here + 132)) # "\204"
    assert_equal(133, @vc.vm.c_fetch(here + 133)) # "\205"
    assert_equal(134, @vc.vm.c_fetch(here + 134)) # "\206"
    assert_equal(135, @vc.vm.c_fetch(here + 135)) # "\207"
    assert_equal(136, @vc.vm.c_fetch(here + 136)) # "\210"
    assert_equal(137, @vc.vm.c_fetch(here + 137)) # "\211"
    assert_equal(138, @vc.vm.c_fetch(here + 138)) # "\212"
    assert_equal(139, @vc.vm.c_fetch(here + 139)) # "\213"
    assert_equal(140, @vc.vm.c_fetch(here + 140)) # "\214"
    assert_equal(141, @vc.vm.c_fetch(here + 141)) # "\215"
    assert_equal(142, @vc.vm.c_fetch(here + 142)) # "\216"
    assert_equal(143, @vc.vm.c_fetch(here + 143)) # "\217"
    assert_equal(144, @vc.vm.c_fetch(here + 144)) # "\220"
    assert_equal(145, @vc.vm.c_fetch(here + 145)) # "\221"
    assert_equal(146, @vc.vm.c_fetch(here + 146)) # "\222"
    assert_equal(147, @vc.vm.c_fetch(here + 147)) # "\223"
    assert_equal(148, @vc.vm.c_fetch(here + 148)) # "\224"
    assert_equal(149, @vc.vm.c_fetch(here + 149)) # "\225"
    assert_equal(150, @vc.vm.c_fetch(here + 150)) # "\226"
    assert_equal(151, @vc.vm.c_fetch(here + 151)) # "\227"
    assert_equal(152, @vc.vm.c_fetch(here + 152)) # "\230"
    assert_equal(153, @vc.vm.c_fetch(here + 153)) # "\231"
    assert_equal(154, @vc.vm.c_fetch(here + 154)) # "\232"
    assert_equal(155, @vc.vm.c_fetch(here + 155)) # "\233"
    assert_equal(156, @vc.vm.c_fetch(here + 156)) # "\234"
    assert_equal(157, @vc.vm.c_fetch(here + 157)) # "\235"
    assert_equal(158, @vc.vm.c_fetch(here + 158)) # "\236"
    assert_equal(159, @vc.vm.c_fetch(here + 159)) # "\237"
    assert_equal(160, @vc.vm.c_fetch(here + 160)) # "\240"
    assert_equal(161, @vc.vm.c_fetch(here + 161)) # "\241"
    assert_equal(162, @vc.vm.c_fetch(here + 162)) # "\242"
    assert_equal(163, @vc.vm.c_fetch(here + 163)) # "\243"
    assert_equal(164, @vc.vm.c_fetch(here + 164)) # "\244"
    assert_equal(165, @vc.vm.c_fetch(here + 165)) # "\245"
    assert_equal(166, @vc.vm.c_fetch(here + 166)) # "\246"
    assert_equal(167, @vc.vm.c_fetch(here + 167)) # "\247"
    assert_equal(168, @vc.vm.c_fetch(here + 168)) # "\250"
    assert_equal(169, @vc.vm.c_fetch(here + 169)) # "\251"
    assert_equal(170, @vc.vm.c_fetch(here + 170)) # "\252"
    assert_equal(171, @vc.vm.c_fetch(here + 171)) # "\253"
    assert_equal(172, @vc.vm.c_fetch(here + 172)) # "\254"
    assert_equal(173, @vc.vm.c_fetch(here + 173)) # "\255"
    assert_equal(174, @vc.vm.c_fetch(here + 174)) # "\256"
    assert_equal(175, @vc.vm.c_fetch(here + 175)) # "\257"
    assert_equal(176, @vc.vm.c_fetch(here + 176)) # "\260"
    assert_equal(177, @vc.vm.c_fetch(here + 177)) # "\261"
    assert_equal(178, @vc.vm.c_fetch(here + 178)) # "\262"
    assert_equal(179, @vc.vm.c_fetch(here + 179)) # "\263"
    assert_equal(180, @vc.vm.c_fetch(here + 180)) # "\264"
    assert_equal(181, @vc.vm.c_fetch(here + 181)) # "\265"
    assert_equal(182, @vc.vm.c_fetch(here + 182)) # "\266"
    assert_equal(183, @vc.vm.c_fetch(here + 183)) # "\267"
    assert_equal(184, @vc.vm.c_fetch(here + 184)) # "\270"
    assert_equal(185, @vc.vm.c_fetch(here + 185)) # "\271"
    assert_equal(186, @vc.vm.c_fetch(here + 186)) # "\272"
    assert_equal(187, @vc.vm.c_fetch(here + 187)) # "\273"
    assert_equal(188, @vc.vm.c_fetch(here + 188)) # "\274"
    assert_equal(189, @vc.vm.c_fetch(here + 189)) # "\275"
    assert_equal(190, @vc.vm.c_fetch(here + 190)) # "\276"
    assert_equal(191, @vc.vm.c_fetch(here + 191)) # "\277"
    assert_equal(192, @vc.vm.c_fetch(here + 192)) # "\300"
    assert_equal(193, @vc.vm.c_fetch(here + 193)) # "\301"
    assert_equal(194, @vc.vm.c_fetch(here + 194)) # "\302"
    assert_equal(195, @vc.vm.c_fetch(here + 195)) # "\303"
    assert_equal(196, @vc.vm.c_fetch(here + 196)) # "\304"
    assert_equal(197, @vc.vm.c_fetch(here + 197)) # "\305"
    assert_equal(198, @vc.vm.c_fetch(here + 198)) # "\306"
    assert_equal(199, @vc.vm.c_fetch(here + 199)) # "\307"
    assert_equal(200, @vc.vm.c_fetch(here + 200)) # "\310"
    assert_equal(201, @vc.vm.c_fetch(here + 201)) # "\311"
    assert_equal(202, @vc.vm.c_fetch(here + 202)) # "\312"
    assert_equal(203, @vc.vm.c_fetch(here + 203)) # "\313"
    assert_equal(204, @vc.vm.c_fetch(here + 204)) # "\314"
    assert_equal(205, @vc.vm.c_fetch(here + 205)) # "\315"
    assert_equal(206, @vc.vm.c_fetch(here + 206)) # "\316"
    assert_equal(207, @vc.vm.c_fetch(here + 207)) # "\317"
    assert_equal(208, @vc.vm.c_fetch(here + 208)) # "\320"
    assert_equal(209, @vc.vm.c_fetch(here + 209)) # "\321"
    assert_equal(210, @vc.vm.c_fetch(here + 210)) # "\322"
    assert_equal(211, @vc.vm.c_fetch(here + 211)) # "\323"
    assert_equal(212, @vc.vm.c_fetch(here + 212)) # "\324"
    assert_equal(213, @vc.vm.c_fetch(here + 213)) # "\325"
    assert_equal(214, @vc.vm.c_fetch(here + 214)) # "\326"
    assert_equal(215, @vc.vm.c_fetch(here + 215)) # "\327"
    assert_equal(216, @vc.vm.c_fetch(here + 216)) # "\330"
    assert_equal(217, @vc.vm.c_fetch(here + 217)) # "\331"
    assert_equal(218, @vc.vm.c_fetch(here + 218)) # "\332"
    assert_equal(219, @vc.vm.c_fetch(here + 219)) # "\333"
    assert_equal(220, @vc.vm.c_fetch(here + 220)) # "\334"
    assert_equal(221, @vc.vm.c_fetch(here + 221)) # "\335"
    assert_equal(222, @vc.vm.c_fetch(here + 222)) # "\336"
    assert_equal(223, @vc.vm.c_fetch(here + 223)) # "\337"
    assert_equal(224, @vc.vm.c_fetch(here + 224)) # "\340"
    assert_equal(225, @vc.vm.c_fetch(here + 225)) # "\341"
    assert_equal(226, @vc.vm.c_fetch(here + 226)) # "\342"
    assert_equal(227, @vc.vm.c_fetch(here + 227)) # "\343"
    assert_equal(228, @vc.vm.c_fetch(here + 228)) # "\344"
    assert_equal(229, @vc.vm.c_fetch(here + 229)) # "\345"
    assert_equal(230, @vc.vm.c_fetch(here + 230)) # "\346"
    assert_equal(231, @vc.vm.c_fetch(here + 231)) # "\347"
    assert_equal(232, @vc.vm.c_fetch(here + 232)) # "\350"
    assert_equal(233, @vc.vm.c_fetch(here + 233)) # "\351"
    assert_equal(234, @vc.vm.c_fetch(here + 234)) # "\352"
    assert_equal(235, @vc.vm.c_fetch(here + 235)) # "\353"
    assert_equal(236, @vc.vm.c_fetch(here + 236)) # "\354"
    assert_equal(237, @vc.vm.c_fetch(here + 237)) # "\355"
    assert_equal(238, @vc.vm.c_fetch(here + 238)) # "\356"
    assert_equal(239, @vc.vm.c_fetch(here + 239)) # "\357"
    assert_equal(240, @vc.vm.c_fetch(here + 240)) # "\360"
    assert_equal(241, @vc.vm.c_fetch(here + 241)) # "\361"
    assert_equal(242, @vc.vm.c_fetch(here + 242)) # "\362"
    assert_equal(243, @vc.vm.c_fetch(here + 243)) # "\363"
    assert_equal(244, @vc.vm.c_fetch(here + 244)) # "\364"
    assert_equal(245, @vc.vm.c_fetch(here + 245)) # "\365"
    assert_equal(246, @vc.vm.c_fetch(here + 246)) # "\366"
    assert_equal(247, @vc.vm.c_fetch(here + 247)) # "\367"
    assert_equal(248, @vc.vm.c_fetch(here + 248)) # "\370"
    assert_equal(249, @vc.vm.c_fetch(here + 249)) # "\371"
    assert_equal(250, @vc.vm.c_fetch(here + 250)) # "\372"
    assert_equal(251, @vc.vm.c_fetch(here + 251)) # "\373"
    assert_equal(252, @vc.vm.c_fetch(here + 252)) # "\374"
    assert_equal(253, @vc.vm.c_fetch(here + 253)) # "\375"
    assert_equal(254, @vc.vm.c_fetch(here + 254)) # "\376"
    assert_equal(255, @vc.vm.c_fetch(here + 255)) # "\377"
  end


# digit
  def test_stack_108
    @vc.parse ": test 256 0 do i 2 digit 0= if 255 then c, loop ;"
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run_limit = @vc.run_limit * 100
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(255, @vc.vm.c_fetch(here +   0)) # "\000"
    assert_equal(255, @vc.vm.c_fetch(here +   1)) # "\001"
    assert_equal(255, @vc.vm.c_fetch(here +   2)) # "\002"
    assert_equal(255, @vc.vm.c_fetch(here +   3)) # "\003"
    assert_equal(255, @vc.vm.c_fetch(here +   4)) # "\004"
    assert_equal(255, @vc.vm.c_fetch(here +   5)) # "\005"
    assert_equal(255, @vc.vm.c_fetch(here +   6)) # "\006"
    assert_equal(255, @vc.vm.c_fetch(here +   7)) # "\a"
    assert_equal(255, @vc.vm.c_fetch(here +   8)) # "\b"
    assert_equal(255, @vc.vm.c_fetch(here +   9)) # "\t"
    assert_equal(255, @vc.vm.c_fetch(here +  10)) # "\n"
    assert_equal(255, @vc.vm.c_fetch(here +  11)) # "\v"
    assert_equal(255, @vc.vm.c_fetch(here +  12)) # "\f"
    assert_equal(255, @vc.vm.c_fetch(here +  13)) # "\r"
    assert_equal(255, @vc.vm.c_fetch(here +  14)) # "\016"
    assert_equal(255, @vc.vm.c_fetch(here +  15)) # "\017"
    assert_equal(255, @vc.vm.c_fetch(here +  16)) # "\020"
    assert_equal(255, @vc.vm.c_fetch(here +  17)) # "\021"
    assert_equal(255, @vc.vm.c_fetch(here +  18)) # "\022"
    assert_equal(255, @vc.vm.c_fetch(here +  19)) # "\023"
    assert_equal(255, @vc.vm.c_fetch(here +  20)) # "\024"
    assert_equal(255, @vc.vm.c_fetch(here +  21)) # "\025"
    assert_equal(255, @vc.vm.c_fetch(here +  22)) # "\026"
    assert_equal(255, @vc.vm.c_fetch(here +  23)) # "\027"
    assert_equal(255, @vc.vm.c_fetch(here +  24)) # "\030"
    assert_equal(255, @vc.vm.c_fetch(here +  25)) # "\031"
    assert_equal(255, @vc.vm.c_fetch(here +  26)) # "\032"
    assert_equal(255, @vc.vm.c_fetch(here +  27)) # "\e"
    assert_equal(255, @vc.vm.c_fetch(here +  28)) # "\034"
    assert_equal(255, @vc.vm.c_fetch(here +  29)) # "\035"
    assert_equal(255, @vc.vm.c_fetch(here +  30)) # "\036"
    assert_equal(255, @vc.vm.c_fetch(here +  31)) # "\037"
    assert_equal(255, @vc.vm.c_fetch(here +  32)) # " "
    assert_equal(255, @vc.vm.c_fetch(here +  33)) # "!"
    assert_equal(255, @vc.vm.c_fetch(here +  34)) # "\""
    assert_equal(255, @vc.vm.c_fetch(here +  35)) # "#"
    assert_equal(255, @vc.vm.c_fetch(here +  36)) # "$"
    assert_equal(255, @vc.vm.c_fetch(here +  37)) # "%"
    assert_equal(255, @vc.vm.c_fetch(here +  38)) # "&"
    assert_equal(255, @vc.vm.c_fetch(here +  39)) # "'"
    assert_equal(255, @vc.vm.c_fetch(here +  40)) # "("
    assert_equal(255, @vc.vm.c_fetch(here +  41)) # ")"
    assert_equal(255, @vc.vm.c_fetch(here +  42)) # "*"
    assert_equal(255, @vc.vm.c_fetch(here +  43)) # "+"
    assert_equal(255, @vc.vm.c_fetch(here +  44)) # ","
    assert_equal(255, @vc.vm.c_fetch(here +  45)) # "-"
    assert_equal(255, @vc.vm.c_fetch(here +  46)) # "."
    assert_equal(255, @vc.vm.c_fetch(here +  47)) # "/"
    assert_equal(  0, @vc.vm.c_fetch(here +  48)) # "0"
    assert_equal(  1, @vc.vm.c_fetch(here +  49)) # "1"
    assert_equal(255, @vc.vm.c_fetch(here +  50)) # "2"
    assert_equal(255, @vc.vm.c_fetch(here +  51)) # "3"
    assert_equal(255, @vc.vm.c_fetch(here +  52)) # "4"
    assert_equal(255, @vc.vm.c_fetch(here +  53)) # "5"
    assert_equal(255, @vc.vm.c_fetch(here +  54)) # "6"
    assert_equal(255, @vc.vm.c_fetch(here +  55)) # "7"
    assert_equal(255, @vc.vm.c_fetch(here +  56)) # "8"
    assert_equal(255, @vc.vm.c_fetch(here +  57)) # "9"
    assert_equal(255, @vc.vm.c_fetch(here +  58)) # ":"
    assert_equal(255, @vc.vm.c_fetch(here +  59)) # ";"
    assert_equal(255, @vc.vm.c_fetch(here +  60)) # "<"
    assert_equal(255, @vc.vm.c_fetch(here +  61)) # "="
    assert_equal(255, @vc.vm.c_fetch(here +  62)) # ">"
    assert_equal(255, @vc.vm.c_fetch(here +  63)) # "?"
    assert_equal(255, @vc.vm.c_fetch(here +  64)) # "@"
    assert_equal(255, @vc.vm.c_fetch(here +  65)) # "A"
    assert_equal(255, @vc.vm.c_fetch(here +  66)) # "B"
    assert_equal(255, @vc.vm.c_fetch(here +  67)) # "C"
    assert_equal(255, @vc.vm.c_fetch(here +  68)) # "D"
    assert_equal(255, @vc.vm.c_fetch(here +  69)) # "E"
    assert_equal(255, @vc.vm.c_fetch(here +  70)) # "F"
    assert_equal(255, @vc.vm.c_fetch(here +  71)) # "G"
    assert_equal(255, @vc.vm.c_fetch(here +  72)) # "H"
    assert_equal(255, @vc.vm.c_fetch(here +  73)) # "I"
    assert_equal(255, @vc.vm.c_fetch(here +  74)) # "J"
    assert_equal(255, @vc.vm.c_fetch(here +  75)) # "K"
    assert_equal(255, @vc.vm.c_fetch(here +  76)) # "L"
    assert_equal(255, @vc.vm.c_fetch(here +  77)) # "M"
    assert_equal(255, @vc.vm.c_fetch(here +  78)) # "N"
    assert_equal(255, @vc.vm.c_fetch(here +  79)) # "O"
    assert_equal(255, @vc.vm.c_fetch(here +  80)) # "P"
    assert_equal(255, @vc.vm.c_fetch(here +  81)) # "Q"
    assert_equal(255, @vc.vm.c_fetch(here +  82)) # "R"
    assert_equal(255, @vc.vm.c_fetch(here +  83)) # "S"
    assert_equal(255, @vc.vm.c_fetch(here +  84)) # "T"
    assert_equal(255, @vc.vm.c_fetch(here +  85)) # "U"
    assert_equal(255, @vc.vm.c_fetch(here +  86)) # "V"
    assert_equal(255, @vc.vm.c_fetch(here +  87)) # "W"
    assert_equal(255, @vc.vm.c_fetch(here +  88)) # "X"
    assert_equal(255, @vc.vm.c_fetch(here +  89)) # "Y"
    assert_equal(255, @vc.vm.c_fetch(here +  90)) # "Z"
    assert_equal(255, @vc.vm.c_fetch(here +  91)) # "["
    assert_equal(255, @vc.vm.c_fetch(here +  92)) # "\\"
    assert_equal(255, @vc.vm.c_fetch(here +  93)) # "]"
    assert_equal(255, @vc.vm.c_fetch(here +  94)) # "^"
    assert_equal(255, @vc.vm.c_fetch(here +  95)) # "_"
    assert_equal(255, @vc.vm.c_fetch(here +  96)) # "`"
    assert_equal(255, @vc.vm.c_fetch(here +  97)) # "a"
    assert_equal(255, @vc.vm.c_fetch(here +  98)) # "b"
    assert_equal(255, @vc.vm.c_fetch(here +  99)) # "c"
    assert_equal(255, @vc.vm.c_fetch(here + 100)) # "d"
    assert_equal(255, @vc.vm.c_fetch(here + 101)) # "e"
    assert_equal(255, @vc.vm.c_fetch(here + 102)) # "f"
    assert_equal(255, @vc.vm.c_fetch(here + 103)) # "g"
    assert_equal(255, @vc.vm.c_fetch(here + 104)) # "h"
    assert_equal(255, @vc.vm.c_fetch(here + 105)) # "i"
    assert_equal(255, @vc.vm.c_fetch(here + 106)) # "j"
    assert_equal(255, @vc.vm.c_fetch(here + 107)) # "k"
    assert_equal(255, @vc.vm.c_fetch(here + 108)) # "l"
    assert_equal(255, @vc.vm.c_fetch(here + 109)) # "m"
    assert_equal(255, @vc.vm.c_fetch(here + 110)) # "n"
    assert_equal(255, @vc.vm.c_fetch(here + 111)) # "o"
    assert_equal(255, @vc.vm.c_fetch(here + 112)) # "p"
    assert_equal(255, @vc.vm.c_fetch(here + 113)) # "q"
    assert_equal(255, @vc.vm.c_fetch(here + 114)) # "r"
    assert_equal(255, @vc.vm.c_fetch(here + 115)) # "s"
    assert_equal(255, @vc.vm.c_fetch(here + 116)) # "t"
    assert_equal(255, @vc.vm.c_fetch(here + 117)) # "u"
    assert_equal(255, @vc.vm.c_fetch(here + 118)) # "v"
    assert_equal(255, @vc.vm.c_fetch(here + 119)) # "w"
    assert_equal(255, @vc.vm.c_fetch(here + 120)) # "x"
    assert_equal(255, @vc.vm.c_fetch(here + 121)) # "y"
    assert_equal(255, @vc.vm.c_fetch(here + 122)) # "z"
    assert_equal(255, @vc.vm.c_fetch(here + 123)) # "{"
    assert_equal(255, @vc.vm.c_fetch(here + 124)) # "|"
    assert_equal(255, @vc.vm.c_fetch(here + 125)) # "}"
    assert_equal(255, @vc.vm.c_fetch(here + 126)) # "~"
    assert_equal(255, @vc.vm.c_fetch(here + 127)) # "\177"
    assert_equal(255, @vc.vm.c_fetch(here + 128)) # "\200"
    assert_equal(255, @vc.vm.c_fetch(here + 129)) # "\201"
    assert_equal(255, @vc.vm.c_fetch(here + 130)) # "\202"
    assert_equal(255, @vc.vm.c_fetch(here + 131)) # "\203"
    assert_equal(255, @vc.vm.c_fetch(here + 132)) # "\204"
    assert_equal(255, @vc.vm.c_fetch(here + 133)) # "\205"
    assert_equal(255, @vc.vm.c_fetch(here + 134)) # "\206"
    assert_equal(255, @vc.vm.c_fetch(here + 135)) # "\207"
    assert_equal(255, @vc.vm.c_fetch(here + 136)) # "\210"
    assert_equal(255, @vc.vm.c_fetch(here + 137)) # "\211"
    assert_equal(255, @vc.vm.c_fetch(here + 138)) # "\212"
    assert_equal(255, @vc.vm.c_fetch(here + 139)) # "\213"
    assert_equal(255, @vc.vm.c_fetch(here + 140)) # "\214"
    assert_equal(255, @vc.vm.c_fetch(here + 141)) # "\215"
    assert_equal(255, @vc.vm.c_fetch(here + 142)) # "\216"
    assert_equal(255, @vc.vm.c_fetch(here + 143)) # "\217"
    assert_equal(255, @vc.vm.c_fetch(here + 144)) # "\220"
    assert_equal(255, @vc.vm.c_fetch(here + 145)) # "\221"
    assert_equal(255, @vc.vm.c_fetch(here + 146)) # "\222"
    assert_equal(255, @vc.vm.c_fetch(here + 147)) # "\223"
    assert_equal(255, @vc.vm.c_fetch(here + 148)) # "\224"
    assert_equal(255, @vc.vm.c_fetch(here + 149)) # "\225"
    assert_equal(255, @vc.vm.c_fetch(here + 150)) # "\226"
    assert_equal(255, @vc.vm.c_fetch(here + 151)) # "\227"
    assert_equal(255, @vc.vm.c_fetch(here + 152)) # "\230"
    assert_equal(255, @vc.vm.c_fetch(here + 153)) # "\231"
    assert_equal(255, @vc.vm.c_fetch(here + 154)) # "\232"
    assert_equal(255, @vc.vm.c_fetch(here + 155)) # "\233"
    assert_equal(255, @vc.vm.c_fetch(here + 156)) # "\234"
    assert_equal(255, @vc.vm.c_fetch(here + 157)) # "\235"
    assert_equal(255, @vc.vm.c_fetch(here + 158)) # "\236"
    assert_equal(255, @vc.vm.c_fetch(here + 159)) # "\237"
    assert_equal(255, @vc.vm.c_fetch(here + 160)) # "\240"
    assert_equal(255, @vc.vm.c_fetch(here + 161)) # "\241"
    assert_equal(255, @vc.vm.c_fetch(here + 162)) # "\242"
    assert_equal(255, @vc.vm.c_fetch(here + 163)) # "\243"
    assert_equal(255, @vc.vm.c_fetch(here + 164)) # "\244"
    assert_equal(255, @vc.vm.c_fetch(here + 165)) # "\245"
    assert_equal(255, @vc.vm.c_fetch(here + 166)) # "\246"
    assert_equal(255, @vc.vm.c_fetch(here + 167)) # "\247"
    assert_equal(255, @vc.vm.c_fetch(here + 168)) # "\250"
    assert_equal(255, @vc.vm.c_fetch(here + 169)) # "\251"
    assert_equal(255, @vc.vm.c_fetch(here + 170)) # "\252"
    assert_equal(255, @vc.vm.c_fetch(here + 171)) # "\253"
    assert_equal(255, @vc.vm.c_fetch(here + 172)) # "\254"
    assert_equal(255, @vc.vm.c_fetch(here + 173)) # "\255"
    assert_equal(255, @vc.vm.c_fetch(here + 174)) # "\256"
    assert_equal(255, @vc.vm.c_fetch(here + 175)) # "\257"
    assert_equal(255, @vc.vm.c_fetch(here + 176)) # "\260"
    assert_equal(255, @vc.vm.c_fetch(here + 177)) # "\261"
    assert_equal(255, @vc.vm.c_fetch(here + 178)) # "\262"
    assert_equal(255, @vc.vm.c_fetch(here + 179)) # "\263"
    assert_equal(255, @vc.vm.c_fetch(here + 180)) # "\264"
    assert_equal(255, @vc.vm.c_fetch(here + 181)) # "\265"
    assert_equal(255, @vc.vm.c_fetch(here + 182)) # "\266"
    assert_equal(255, @vc.vm.c_fetch(here + 183)) # "\267"
    assert_equal(255, @vc.vm.c_fetch(here + 184)) # "\270"
    assert_equal(255, @vc.vm.c_fetch(here + 185)) # "\271"
    assert_equal(255, @vc.vm.c_fetch(here + 186)) # "\272"
    assert_equal(255, @vc.vm.c_fetch(here + 187)) # "\273"
    assert_equal(255, @vc.vm.c_fetch(here + 188)) # "\274"
    assert_equal(255, @vc.vm.c_fetch(here + 189)) # "\275"
    assert_equal(255, @vc.vm.c_fetch(here + 190)) # "\276"
    assert_equal(255, @vc.vm.c_fetch(here + 191)) # "\277"
    assert_equal(255, @vc.vm.c_fetch(here + 192)) # "\300"
    assert_equal(255, @vc.vm.c_fetch(here + 193)) # "\301"
    assert_equal(255, @vc.vm.c_fetch(here + 194)) # "\302"
    assert_equal(255, @vc.vm.c_fetch(here + 195)) # "\303"
    assert_equal(255, @vc.vm.c_fetch(here + 196)) # "\304"
    assert_equal(255, @vc.vm.c_fetch(here + 197)) # "\305"
    assert_equal(255, @vc.vm.c_fetch(here + 198)) # "\306"
    assert_equal(255, @vc.vm.c_fetch(here + 199)) # "\307"
    assert_equal(255, @vc.vm.c_fetch(here + 200)) # "\310"
    assert_equal(255, @vc.vm.c_fetch(here + 201)) # "\311"
    assert_equal(255, @vc.vm.c_fetch(here + 202)) # "\312"
    assert_equal(255, @vc.vm.c_fetch(here + 203)) # "\313"
    assert_equal(255, @vc.vm.c_fetch(here + 204)) # "\314"
    assert_equal(255, @vc.vm.c_fetch(here + 205)) # "\315"
    assert_equal(255, @vc.vm.c_fetch(here + 206)) # "\316"
    assert_equal(255, @vc.vm.c_fetch(here + 207)) # "\317"
    assert_equal(255, @vc.vm.c_fetch(here + 208)) # "\320"
    assert_equal(255, @vc.vm.c_fetch(here + 209)) # "\321"
    assert_equal(255, @vc.vm.c_fetch(here + 210)) # "\322"
    assert_equal(255, @vc.vm.c_fetch(here + 211)) # "\323"
    assert_equal(255, @vc.vm.c_fetch(here + 212)) # "\324"
    assert_equal(255, @vc.vm.c_fetch(here + 213)) # "\325"
    assert_equal(255, @vc.vm.c_fetch(here + 214)) # "\326"
    assert_equal(255, @vc.vm.c_fetch(here + 215)) # "\327"
    assert_equal(255, @vc.vm.c_fetch(here + 216)) # "\330"
    assert_equal(255, @vc.vm.c_fetch(here + 217)) # "\331"
    assert_equal(255, @vc.vm.c_fetch(here + 218)) # "\332"
    assert_equal(255, @vc.vm.c_fetch(here + 219)) # "\333"
    assert_equal(255, @vc.vm.c_fetch(here + 220)) # "\334"
    assert_equal(255, @vc.vm.c_fetch(here + 221)) # "\335"
    assert_equal(255, @vc.vm.c_fetch(here + 222)) # "\336"
    assert_equal(255, @vc.vm.c_fetch(here + 223)) # "\337"
    assert_equal(255, @vc.vm.c_fetch(here + 224)) # "\340"
    assert_equal(255, @vc.vm.c_fetch(here + 225)) # "\341"
    assert_equal(255, @vc.vm.c_fetch(here + 226)) # "\342"
    assert_equal(255, @vc.vm.c_fetch(here + 227)) # "\343"
    assert_equal(255, @vc.vm.c_fetch(here + 228)) # "\344"
    assert_equal(255, @vc.vm.c_fetch(here + 229)) # "\345"
    assert_equal(255, @vc.vm.c_fetch(here + 230)) # "\346"
    assert_equal(255, @vc.vm.c_fetch(here + 231)) # "\347"
    assert_equal(255, @vc.vm.c_fetch(here + 232)) # "\350"
    assert_equal(255, @vc.vm.c_fetch(here + 233)) # "\351"
    assert_equal(255, @vc.vm.c_fetch(here + 234)) # "\352"
    assert_equal(255, @vc.vm.c_fetch(here + 235)) # "\353"
    assert_equal(255, @vc.vm.c_fetch(here + 236)) # "\354"
    assert_equal(255, @vc.vm.c_fetch(here + 237)) # "\355"
    assert_equal(255, @vc.vm.c_fetch(here + 238)) # "\356"
    assert_equal(255, @vc.vm.c_fetch(here + 239)) # "\357"
    assert_equal(255, @vc.vm.c_fetch(here + 240)) # "\360"
    assert_equal(255, @vc.vm.c_fetch(here + 241)) # "\361"
    assert_equal(255, @vc.vm.c_fetch(here + 242)) # "\362"
    assert_equal(255, @vc.vm.c_fetch(here + 243)) # "\363"
    assert_equal(255, @vc.vm.c_fetch(here + 244)) # "\364"
    assert_equal(255, @vc.vm.c_fetch(here + 245)) # "\365"
    assert_equal(255, @vc.vm.c_fetch(here + 246)) # "\366"
    assert_equal(255, @vc.vm.c_fetch(here + 247)) # "\367"
    assert_equal(255, @vc.vm.c_fetch(here + 248)) # "\370"
    assert_equal(255, @vc.vm.c_fetch(here + 249)) # "\371"
    assert_equal(255, @vc.vm.c_fetch(here + 250)) # "\372"
    assert_equal(255, @vc.vm.c_fetch(here + 251)) # "\373"
    assert_equal(255, @vc.vm.c_fetch(here + 252)) # "\374"
    assert_equal(255, @vc.vm.c_fetch(here + 253)) # "\375"
    assert_equal(255, @vc.vm.c_fetch(here + 254)) # "\376"
    assert_equal(255, @vc.vm.c_fetch(here + 255)) # "\377"
  end

  def test_stack_108_1
    @vc.parse ": test 256 0 do i 10 digit 0= if 255 then c, loop ;"
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run_limit = @vc.run_limit * 100
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(255, @vc.vm.c_fetch(here +   0)) # "\000"
    assert_equal(255, @vc.vm.c_fetch(here +   1)) # "\001"
    assert_equal(255, @vc.vm.c_fetch(here +   2)) # "\002"
    assert_equal(255, @vc.vm.c_fetch(here +   3)) # "\003"
    assert_equal(255, @vc.vm.c_fetch(here +   4)) # "\004"
    assert_equal(255, @vc.vm.c_fetch(here +   5)) # "\005"
    assert_equal(255, @vc.vm.c_fetch(here +   6)) # "\006"
    assert_equal(255, @vc.vm.c_fetch(here +   7)) # "\a"
    assert_equal(255, @vc.vm.c_fetch(here +   8)) # "\b"
    assert_equal(255, @vc.vm.c_fetch(here +   9)) # "\t"
    assert_equal(255, @vc.vm.c_fetch(here +  10)) # "\n"
    assert_equal(255, @vc.vm.c_fetch(here +  11)) # "\v"
    assert_equal(255, @vc.vm.c_fetch(here +  12)) # "\f"
    assert_equal(255, @vc.vm.c_fetch(here +  13)) # "\r"
    assert_equal(255, @vc.vm.c_fetch(here +  14)) # "\016"
    assert_equal(255, @vc.vm.c_fetch(here +  15)) # "\017"
    assert_equal(255, @vc.vm.c_fetch(here +  16)) # "\020"
    assert_equal(255, @vc.vm.c_fetch(here +  17)) # "\021"
    assert_equal(255, @vc.vm.c_fetch(here +  18)) # "\022"
    assert_equal(255, @vc.vm.c_fetch(here +  19)) # "\023"
    assert_equal(255, @vc.vm.c_fetch(here +  20)) # "\024"
    assert_equal(255, @vc.vm.c_fetch(here +  21)) # "\025"
    assert_equal(255, @vc.vm.c_fetch(here +  22)) # "\026"
    assert_equal(255, @vc.vm.c_fetch(here +  23)) # "\027"
    assert_equal(255, @vc.vm.c_fetch(here +  24)) # "\030"
    assert_equal(255, @vc.vm.c_fetch(here +  25)) # "\031"
    assert_equal(255, @vc.vm.c_fetch(here +  26)) # "\032"
    assert_equal(255, @vc.vm.c_fetch(here +  27)) # "\e"
    assert_equal(255, @vc.vm.c_fetch(here +  28)) # "\034"
    assert_equal(255, @vc.vm.c_fetch(here +  29)) # "\035"
    assert_equal(255, @vc.vm.c_fetch(here +  30)) # "\036"
    assert_equal(255, @vc.vm.c_fetch(here +  31)) # "\037"
    assert_equal(255, @vc.vm.c_fetch(here +  32)) # " "
    assert_equal(255, @vc.vm.c_fetch(here +  33)) # "!"
    assert_equal(255, @vc.vm.c_fetch(here +  34)) # "\""
    assert_equal(255, @vc.vm.c_fetch(here +  35)) # "#"
    assert_equal(255, @vc.vm.c_fetch(here +  36)) # "$"
    assert_equal(255, @vc.vm.c_fetch(here +  37)) # "%"
    assert_equal(255, @vc.vm.c_fetch(here +  38)) # "&"
    assert_equal(255, @vc.vm.c_fetch(here +  39)) # "'"
    assert_equal(255, @vc.vm.c_fetch(here +  40)) # "("
    assert_equal(255, @vc.vm.c_fetch(here +  41)) # ")"
    assert_equal(255, @vc.vm.c_fetch(here +  42)) # "*"
    assert_equal(255, @vc.vm.c_fetch(here +  43)) # "+"
    assert_equal(255, @vc.vm.c_fetch(here +  44)) # ","
    assert_equal(255, @vc.vm.c_fetch(here +  45)) # "-"
    assert_equal(255, @vc.vm.c_fetch(here +  46)) # "."
    assert_equal(255, @vc.vm.c_fetch(here +  47)) # "/"
    assert_equal(  0, @vc.vm.c_fetch(here +  48)) # "0"
    assert_equal(  1, @vc.vm.c_fetch(here +  49)) # "1"
    assert_equal(  2, @vc.vm.c_fetch(here +  50)) # "2"
    assert_equal(  3, @vc.vm.c_fetch(here +  51)) # "3"
    assert_equal(  4, @vc.vm.c_fetch(here +  52)) # "4"
    assert_equal(  5, @vc.vm.c_fetch(here +  53)) # "5"
    assert_equal(  6, @vc.vm.c_fetch(here +  54)) # "6"
    assert_equal(  7, @vc.vm.c_fetch(here +  55)) # "7"
    assert_equal(  8, @vc.vm.c_fetch(here +  56)) # "8"
    assert_equal(  9, @vc.vm.c_fetch(here +  57)) # "9"
    assert_equal(255, @vc.vm.c_fetch(here +  58)) # ":"
    assert_equal(255, @vc.vm.c_fetch(here +  59)) # ";"
    assert_equal(255, @vc.vm.c_fetch(here +  60)) # "<"
    assert_equal(255, @vc.vm.c_fetch(here +  61)) # "="
    assert_equal(255, @vc.vm.c_fetch(here +  62)) # ">"
    assert_equal(255, @vc.vm.c_fetch(here +  63)) # "?"
    assert_equal(255, @vc.vm.c_fetch(here +  64)) # "@"
    assert_equal(255, @vc.vm.c_fetch(here +  65)) # "A"
    assert_equal(255, @vc.vm.c_fetch(here +  66)) # "B"
    assert_equal(255, @vc.vm.c_fetch(here +  67)) # "C"
    assert_equal(255, @vc.vm.c_fetch(here +  68)) # "D"
    assert_equal(255, @vc.vm.c_fetch(here +  69)) # "E"
    assert_equal(255, @vc.vm.c_fetch(here +  70)) # "F"
    assert_equal(255, @vc.vm.c_fetch(here +  71)) # "G"
    assert_equal(255, @vc.vm.c_fetch(here +  72)) # "H"
    assert_equal(255, @vc.vm.c_fetch(here +  73)) # "I"
    assert_equal(255, @vc.vm.c_fetch(here +  74)) # "J"
    assert_equal(255, @vc.vm.c_fetch(here +  75)) # "K"
    assert_equal(255, @vc.vm.c_fetch(here +  76)) # "L"
    assert_equal(255, @vc.vm.c_fetch(here +  77)) # "M"
    assert_equal(255, @vc.vm.c_fetch(here +  78)) # "N"
    assert_equal(255, @vc.vm.c_fetch(here +  79)) # "O"
    assert_equal(255, @vc.vm.c_fetch(here +  80)) # "P"
    assert_equal(255, @vc.vm.c_fetch(here +  81)) # "Q"
    assert_equal(255, @vc.vm.c_fetch(here +  82)) # "R"
    assert_equal(255, @vc.vm.c_fetch(here +  83)) # "S"
    assert_equal(255, @vc.vm.c_fetch(here +  84)) # "T"
    assert_equal(255, @vc.vm.c_fetch(here +  85)) # "U"
    assert_equal(255, @vc.vm.c_fetch(here +  86)) # "V"
    assert_equal(255, @vc.vm.c_fetch(here +  87)) # "W"
    assert_equal(255, @vc.vm.c_fetch(here +  88)) # "X"
    assert_equal(255, @vc.vm.c_fetch(here +  89)) # "Y"
    assert_equal(255, @vc.vm.c_fetch(here +  90)) # "Z"
    assert_equal(255, @vc.vm.c_fetch(here +  91)) # "["
    assert_equal(255, @vc.vm.c_fetch(here +  92)) # "\\"
    assert_equal(255, @vc.vm.c_fetch(here +  93)) # "]"
    assert_equal(255, @vc.vm.c_fetch(here +  94)) # "^"
    assert_equal(255, @vc.vm.c_fetch(here +  95)) # "_"
    assert_equal(255, @vc.vm.c_fetch(here +  96)) # "`"
    assert_equal(255, @vc.vm.c_fetch(here +  97)) # "a"
    assert_equal(255, @vc.vm.c_fetch(here +  98)) # "b"
    assert_equal(255, @vc.vm.c_fetch(here +  99)) # "c"
    assert_equal(255, @vc.vm.c_fetch(here + 100)) # "d"
    assert_equal(255, @vc.vm.c_fetch(here + 101)) # "e"
    assert_equal(255, @vc.vm.c_fetch(here + 102)) # "f"
    assert_equal(255, @vc.vm.c_fetch(here + 103)) # "g"
    assert_equal(255, @vc.vm.c_fetch(here + 104)) # "h"
    assert_equal(255, @vc.vm.c_fetch(here + 105)) # "i"
    assert_equal(255, @vc.vm.c_fetch(here + 106)) # "j"
    assert_equal(255, @vc.vm.c_fetch(here + 107)) # "k"
    assert_equal(255, @vc.vm.c_fetch(here + 108)) # "l"
    assert_equal(255, @vc.vm.c_fetch(here + 109)) # "m"
    assert_equal(255, @vc.vm.c_fetch(here + 110)) # "n"
    assert_equal(255, @vc.vm.c_fetch(here + 111)) # "o"
    assert_equal(255, @vc.vm.c_fetch(here + 112)) # "p"
    assert_equal(255, @vc.vm.c_fetch(here + 113)) # "q"
    assert_equal(255, @vc.vm.c_fetch(here + 114)) # "r"
    assert_equal(255, @vc.vm.c_fetch(here + 115)) # "s"
    assert_equal(255, @vc.vm.c_fetch(here + 116)) # "t"
    assert_equal(255, @vc.vm.c_fetch(here + 117)) # "u"
    assert_equal(255, @vc.vm.c_fetch(here + 118)) # "v"
    assert_equal(255, @vc.vm.c_fetch(here + 119)) # "w"
    assert_equal(255, @vc.vm.c_fetch(here + 120)) # "x"
    assert_equal(255, @vc.vm.c_fetch(here + 121)) # "y"
    assert_equal(255, @vc.vm.c_fetch(here + 122)) # "z"
    assert_equal(255, @vc.vm.c_fetch(here + 123)) # "{"
    assert_equal(255, @vc.vm.c_fetch(here + 124)) # "|"
    assert_equal(255, @vc.vm.c_fetch(here + 125)) # "}"
    assert_equal(255, @vc.vm.c_fetch(here + 126)) # "~"
    assert_equal(255, @vc.vm.c_fetch(here + 127)) # "\177"
    assert_equal(255, @vc.vm.c_fetch(here + 128)) # "\200"
    assert_equal(255, @vc.vm.c_fetch(here + 129)) # "\201"
    assert_equal(255, @vc.vm.c_fetch(here + 130)) # "\202"
    assert_equal(255, @vc.vm.c_fetch(here + 131)) # "\203"
    assert_equal(255, @vc.vm.c_fetch(here + 132)) # "\204"
    assert_equal(255, @vc.vm.c_fetch(here + 133)) # "\205"
    assert_equal(255, @vc.vm.c_fetch(here + 134)) # "\206"
    assert_equal(255, @vc.vm.c_fetch(here + 135)) # "\207"
    assert_equal(255, @vc.vm.c_fetch(here + 136)) # "\210"
    assert_equal(255, @vc.vm.c_fetch(here + 137)) # "\211"
    assert_equal(255, @vc.vm.c_fetch(here + 138)) # "\212"
    assert_equal(255, @vc.vm.c_fetch(here + 139)) # "\213"
    assert_equal(255, @vc.vm.c_fetch(here + 140)) # "\214"
    assert_equal(255, @vc.vm.c_fetch(here + 141)) # "\215"
    assert_equal(255, @vc.vm.c_fetch(here + 142)) # "\216"
    assert_equal(255, @vc.vm.c_fetch(here + 143)) # "\217"
    assert_equal(255, @vc.vm.c_fetch(here + 144)) # "\220"
    assert_equal(255, @vc.vm.c_fetch(here + 145)) # "\221"
    assert_equal(255, @vc.vm.c_fetch(here + 146)) # "\222"
    assert_equal(255, @vc.vm.c_fetch(here + 147)) # "\223"
    assert_equal(255, @vc.vm.c_fetch(here + 148)) # "\224"
    assert_equal(255, @vc.vm.c_fetch(here + 149)) # "\225"
    assert_equal(255, @vc.vm.c_fetch(here + 150)) # "\226"
    assert_equal(255, @vc.vm.c_fetch(here + 151)) # "\227"
    assert_equal(255, @vc.vm.c_fetch(here + 152)) # "\230"
    assert_equal(255, @vc.vm.c_fetch(here + 153)) # "\231"
    assert_equal(255, @vc.vm.c_fetch(here + 154)) # "\232"
    assert_equal(255, @vc.vm.c_fetch(here + 155)) # "\233"
    assert_equal(255, @vc.vm.c_fetch(here + 156)) # "\234"
    assert_equal(255, @vc.vm.c_fetch(here + 157)) # "\235"
    assert_equal(255, @vc.vm.c_fetch(here + 158)) # "\236"
    assert_equal(255, @vc.vm.c_fetch(here + 159)) # "\237"
    assert_equal(255, @vc.vm.c_fetch(here + 160)) # "\240"
    assert_equal(255, @vc.vm.c_fetch(here + 161)) # "\241"
    assert_equal(255, @vc.vm.c_fetch(here + 162)) # "\242"
    assert_equal(255, @vc.vm.c_fetch(here + 163)) # "\243"
    assert_equal(255, @vc.vm.c_fetch(here + 164)) # "\244"
    assert_equal(255, @vc.vm.c_fetch(here + 165)) # "\245"
    assert_equal(255, @vc.vm.c_fetch(here + 166)) # "\246"
    assert_equal(255, @vc.vm.c_fetch(here + 167)) # "\247"
    assert_equal(255, @vc.vm.c_fetch(here + 168)) # "\250"
    assert_equal(255, @vc.vm.c_fetch(here + 169)) # "\251"
    assert_equal(255, @vc.vm.c_fetch(here + 170)) # "\252"
    assert_equal(255, @vc.vm.c_fetch(here + 171)) # "\253"
    assert_equal(255, @vc.vm.c_fetch(here + 172)) # "\254"
    assert_equal(255, @vc.vm.c_fetch(here + 173)) # "\255"
    assert_equal(255, @vc.vm.c_fetch(here + 174)) # "\256"
    assert_equal(255, @vc.vm.c_fetch(here + 175)) # "\257"
    assert_equal(255, @vc.vm.c_fetch(here + 176)) # "\260"
    assert_equal(255, @vc.vm.c_fetch(here + 177)) # "\261"
    assert_equal(255, @vc.vm.c_fetch(here + 178)) # "\262"
    assert_equal(255, @vc.vm.c_fetch(here + 179)) # "\263"
    assert_equal(255, @vc.vm.c_fetch(here + 180)) # "\264"
    assert_equal(255, @vc.vm.c_fetch(here + 181)) # "\265"
    assert_equal(255, @vc.vm.c_fetch(here + 182)) # "\266"
    assert_equal(255, @vc.vm.c_fetch(here + 183)) # "\267"
    assert_equal(255, @vc.vm.c_fetch(here + 184)) # "\270"
    assert_equal(255, @vc.vm.c_fetch(here + 185)) # "\271"
    assert_equal(255, @vc.vm.c_fetch(here + 186)) # "\272"
    assert_equal(255, @vc.vm.c_fetch(here + 187)) # "\273"
    assert_equal(255, @vc.vm.c_fetch(here + 188)) # "\274"
    assert_equal(255, @vc.vm.c_fetch(here + 189)) # "\275"
    assert_equal(255, @vc.vm.c_fetch(here + 190)) # "\276"
    assert_equal(255, @vc.vm.c_fetch(here + 191)) # "\277"
    assert_equal(255, @vc.vm.c_fetch(here + 192)) # "\300"
    assert_equal(255, @vc.vm.c_fetch(here + 193)) # "\301"
    assert_equal(255, @vc.vm.c_fetch(here + 194)) # "\302"
    assert_equal(255, @vc.vm.c_fetch(here + 195)) # "\303"
    assert_equal(255, @vc.vm.c_fetch(here + 196)) # "\304"
    assert_equal(255, @vc.vm.c_fetch(here + 197)) # "\305"
    assert_equal(255, @vc.vm.c_fetch(here + 198)) # "\306"
    assert_equal(255, @vc.vm.c_fetch(here + 199)) # "\307"
    assert_equal(255, @vc.vm.c_fetch(here + 200)) # "\310"
    assert_equal(255, @vc.vm.c_fetch(here + 201)) # "\311"
    assert_equal(255, @vc.vm.c_fetch(here + 202)) # "\312"
    assert_equal(255, @vc.vm.c_fetch(here + 203)) # "\313"
    assert_equal(255, @vc.vm.c_fetch(here + 204)) # "\314"
    assert_equal(255, @vc.vm.c_fetch(here + 205)) # "\315"
    assert_equal(255, @vc.vm.c_fetch(here + 206)) # "\316"
    assert_equal(255, @vc.vm.c_fetch(here + 207)) # "\317"
    assert_equal(255, @vc.vm.c_fetch(here + 208)) # "\320"
    assert_equal(255, @vc.vm.c_fetch(here + 209)) # "\321"
    assert_equal(255, @vc.vm.c_fetch(here + 210)) # "\322"
    assert_equal(255, @vc.vm.c_fetch(here + 211)) # "\323"
    assert_equal(255, @vc.vm.c_fetch(here + 212)) # "\324"
    assert_equal(255, @vc.vm.c_fetch(here + 213)) # "\325"
    assert_equal(255, @vc.vm.c_fetch(here + 214)) # "\326"
    assert_equal(255, @vc.vm.c_fetch(here + 215)) # "\327"
    assert_equal(255, @vc.vm.c_fetch(here + 216)) # "\330"
    assert_equal(255, @vc.vm.c_fetch(here + 217)) # "\331"
    assert_equal(255, @vc.vm.c_fetch(here + 218)) # "\332"
    assert_equal(255, @vc.vm.c_fetch(here + 219)) # "\333"
    assert_equal(255, @vc.vm.c_fetch(here + 220)) # "\334"
    assert_equal(255, @vc.vm.c_fetch(here + 221)) # "\335"
    assert_equal(255, @vc.vm.c_fetch(here + 222)) # "\336"
    assert_equal(255, @vc.vm.c_fetch(here + 223)) # "\337"
    assert_equal(255, @vc.vm.c_fetch(here + 224)) # "\340"
    assert_equal(255, @vc.vm.c_fetch(here + 225)) # "\341"
    assert_equal(255, @vc.vm.c_fetch(here + 226)) # "\342"
    assert_equal(255, @vc.vm.c_fetch(here + 227)) # "\343"
    assert_equal(255, @vc.vm.c_fetch(here + 228)) # "\344"
    assert_equal(255, @vc.vm.c_fetch(here + 229)) # "\345"
    assert_equal(255, @vc.vm.c_fetch(here + 230)) # "\346"
    assert_equal(255, @vc.vm.c_fetch(here + 231)) # "\347"
    assert_equal(255, @vc.vm.c_fetch(here + 232)) # "\350"
    assert_equal(255, @vc.vm.c_fetch(here + 233)) # "\351"
    assert_equal(255, @vc.vm.c_fetch(here + 234)) # "\352"
    assert_equal(255, @vc.vm.c_fetch(here + 235)) # "\353"
    assert_equal(255, @vc.vm.c_fetch(here + 236)) # "\354"
    assert_equal(255, @vc.vm.c_fetch(here + 237)) # "\355"
    assert_equal(255, @vc.vm.c_fetch(here + 238)) # "\356"
    assert_equal(255, @vc.vm.c_fetch(here + 239)) # "\357"
    assert_equal(255, @vc.vm.c_fetch(here + 240)) # "\360"
    assert_equal(255, @vc.vm.c_fetch(here + 241)) # "\361"
    assert_equal(255, @vc.vm.c_fetch(here + 242)) # "\362"
    assert_equal(255, @vc.vm.c_fetch(here + 243)) # "\363"
    assert_equal(255, @vc.vm.c_fetch(here + 244)) # "\364"
    assert_equal(255, @vc.vm.c_fetch(here + 245)) # "\365"
    assert_equal(255, @vc.vm.c_fetch(here + 246)) # "\366"
    assert_equal(255, @vc.vm.c_fetch(here + 247)) # "\367"
    assert_equal(255, @vc.vm.c_fetch(here + 248)) # "\370"
    assert_equal(255, @vc.vm.c_fetch(here + 249)) # "\371"
    assert_equal(255, @vc.vm.c_fetch(here + 250)) # "\372"
    assert_equal(255, @vc.vm.c_fetch(here + 251)) # "\373"
    assert_equal(255, @vc.vm.c_fetch(here + 252)) # "\374"
    assert_equal(255, @vc.vm.c_fetch(here + 253)) # "\375"
    assert_equal(255, @vc.vm.c_fetch(here + 254)) # "\376"
    assert_equal(255, @vc.vm.c_fetch(here + 255)) # "\377"
  end

  def test_stack_108_2
    @vc.parse ": test 256 0 do i 16 digit 0= if 255 then c, loop ;"
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run_limit = @vc.run_limit * 100
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(255, @vc.vm.c_fetch(here +   0)) # "\000"
    assert_equal(255, @vc.vm.c_fetch(here +   1)) # "\001"
    assert_equal(255, @vc.vm.c_fetch(here +   2)) # "\002"
    assert_equal(255, @vc.vm.c_fetch(here +   3)) # "\003"
    assert_equal(255, @vc.vm.c_fetch(here +   4)) # "\004"
    assert_equal(255, @vc.vm.c_fetch(here +   5)) # "\005"
    assert_equal(255, @vc.vm.c_fetch(here +   6)) # "\006"
    assert_equal(255, @vc.vm.c_fetch(here +   7)) # "\a"
    assert_equal(255, @vc.vm.c_fetch(here +   8)) # "\b"
    assert_equal(255, @vc.vm.c_fetch(here +   9)) # "\t"
    assert_equal(255, @vc.vm.c_fetch(here +  10)) # "\n"
    assert_equal(255, @vc.vm.c_fetch(here +  11)) # "\v"
    assert_equal(255, @vc.vm.c_fetch(here +  12)) # "\f"
    assert_equal(255, @vc.vm.c_fetch(here +  13)) # "\r"
    assert_equal(255, @vc.vm.c_fetch(here +  14)) # "\016"
    assert_equal(255, @vc.vm.c_fetch(here +  15)) # "\017"
    assert_equal(255, @vc.vm.c_fetch(here +  16)) # "\020"
    assert_equal(255, @vc.vm.c_fetch(here +  17)) # "\021"
    assert_equal(255, @vc.vm.c_fetch(here +  18)) # "\022"
    assert_equal(255, @vc.vm.c_fetch(here +  19)) # "\023"
    assert_equal(255, @vc.vm.c_fetch(here +  20)) # "\024"
    assert_equal(255, @vc.vm.c_fetch(here +  21)) # "\025"
    assert_equal(255, @vc.vm.c_fetch(here +  22)) # "\026"
    assert_equal(255, @vc.vm.c_fetch(here +  23)) # "\027"
    assert_equal(255, @vc.vm.c_fetch(here +  24)) # "\030"
    assert_equal(255, @vc.vm.c_fetch(here +  25)) # "\031"
    assert_equal(255, @vc.vm.c_fetch(here +  26)) # "\032"
    assert_equal(255, @vc.vm.c_fetch(here +  27)) # "\e"
    assert_equal(255, @vc.vm.c_fetch(here +  28)) # "\034"
    assert_equal(255, @vc.vm.c_fetch(here +  29)) # "\035"
    assert_equal(255, @vc.vm.c_fetch(here +  30)) # "\036"
    assert_equal(255, @vc.vm.c_fetch(here +  31)) # "\037"
    assert_equal(255, @vc.vm.c_fetch(here +  32)) # " "
    assert_equal(255, @vc.vm.c_fetch(here +  33)) # "!"
    assert_equal(255, @vc.vm.c_fetch(here +  34)) # "\""
    assert_equal(255, @vc.vm.c_fetch(here +  35)) # "#"
    assert_equal(255, @vc.vm.c_fetch(here +  36)) # "$"
    assert_equal(255, @vc.vm.c_fetch(here +  37)) # "%"
    assert_equal(255, @vc.vm.c_fetch(here +  38)) # "&"
    assert_equal(255, @vc.vm.c_fetch(here +  39)) # "'"
    assert_equal(255, @vc.vm.c_fetch(here +  40)) # "("
    assert_equal(255, @vc.vm.c_fetch(here +  41)) # ")"
    assert_equal(255, @vc.vm.c_fetch(here +  42)) # "*"
    assert_equal(255, @vc.vm.c_fetch(here +  43)) # "+"
    assert_equal(255, @vc.vm.c_fetch(here +  44)) # ","
    assert_equal(255, @vc.vm.c_fetch(here +  45)) # "-"
    assert_equal(255, @vc.vm.c_fetch(here +  46)) # "."
    assert_equal(255, @vc.vm.c_fetch(here +  47)) # "/"
    assert_equal(  0, @vc.vm.c_fetch(here +  48)) # "0"
    assert_equal(  1, @vc.vm.c_fetch(here +  49)) # "1"
    assert_equal(  2, @vc.vm.c_fetch(here +  50)) # "2"
    assert_equal(  3, @vc.vm.c_fetch(here +  51)) # "3"
    assert_equal(  4, @vc.vm.c_fetch(here +  52)) # "4"
    assert_equal(  5, @vc.vm.c_fetch(here +  53)) # "5"
    assert_equal(  6, @vc.vm.c_fetch(here +  54)) # "6"
    assert_equal(  7, @vc.vm.c_fetch(here +  55)) # "7"
    assert_equal(  8, @vc.vm.c_fetch(here +  56)) # "8"
    assert_equal(  9, @vc.vm.c_fetch(here +  57)) # "9"
    assert_equal(255, @vc.vm.c_fetch(here +  58)) # ":"
    assert_equal(255, @vc.vm.c_fetch(here +  59)) # ";"
    assert_equal(255, @vc.vm.c_fetch(here +  60)) # "<"
    assert_equal(255, @vc.vm.c_fetch(here +  61)) # "="
    assert_equal(255, @vc.vm.c_fetch(here +  62)) # ">"
    assert_equal(255, @vc.vm.c_fetch(here +  63)) # "?"
    assert_equal(255, @vc.vm.c_fetch(here +  64)) # "@"
    assert_equal( 10, @vc.vm.c_fetch(here +  65)) # "A"
    assert_equal( 11, @vc.vm.c_fetch(here +  66)) # "B"
    assert_equal( 12, @vc.vm.c_fetch(here +  67)) # "C"
    assert_equal( 13, @vc.vm.c_fetch(here +  68)) # "D"
    assert_equal( 14, @vc.vm.c_fetch(here +  69)) # "E"
    assert_equal( 15, @vc.vm.c_fetch(here +  70)) # "F"
    assert_equal(255, @vc.vm.c_fetch(here +  71)) # "G"
    assert_equal(255, @vc.vm.c_fetch(here +  72)) # "H"
    assert_equal(255, @vc.vm.c_fetch(here +  73)) # "I"
    assert_equal(255, @vc.vm.c_fetch(here +  74)) # "J"
    assert_equal(255, @vc.vm.c_fetch(here +  75)) # "K"
    assert_equal(255, @vc.vm.c_fetch(here +  76)) # "L"
    assert_equal(255, @vc.vm.c_fetch(here +  77)) # "M"
    assert_equal(255, @vc.vm.c_fetch(here +  78)) # "N"
    assert_equal(255, @vc.vm.c_fetch(here +  79)) # "O"
    assert_equal(255, @vc.vm.c_fetch(here +  80)) # "P"
    assert_equal(255, @vc.vm.c_fetch(here +  81)) # "Q"
    assert_equal(255, @vc.vm.c_fetch(here +  82)) # "R"
    assert_equal(255, @vc.vm.c_fetch(here +  83)) # "S"
    assert_equal(255, @vc.vm.c_fetch(here +  84)) # "T"
    assert_equal(255, @vc.vm.c_fetch(here +  85)) # "U"
    assert_equal(255, @vc.vm.c_fetch(here +  86)) # "V"
    assert_equal(255, @vc.vm.c_fetch(here +  87)) # "W"
    assert_equal(255, @vc.vm.c_fetch(here +  88)) # "X"
    assert_equal(255, @vc.vm.c_fetch(here +  89)) # "Y"
    assert_equal(255, @vc.vm.c_fetch(here +  90)) # "Z"
    assert_equal(255, @vc.vm.c_fetch(here +  91)) # "["
    assert_equal(255, @vc.vm.c_fetch(here +  92)) # "\\"
    assert_equal(255, @vc.vm.c_fetch(here +  93)) # "]"
    assert_equal(255, @vc.vm.c_fetch(here +  94)) # "^"
    assert_equal(255, @vc.vm.c_fetch(here +  95)) # "_"
    assert_equal(255, @vc.vm.c_fetch(here +  96)) # "`"
    assert_equal( 10, @vc.vm.c_fetch(here +  97)) # "a"
    assert_equal( 11, @vc.vm.c_fetch(here +  98)) # "b"
    assert_equal( 12, @vc.vm.c_fetch(here +  99)) # "c"
    assert_equal( 13, @vc.vm.c_fetch(here + 100)) # "d"
    assert_equal( 14, @vc.vm.c_fetch(here + 101)) # "e"
    assert_equal( 15, @vc.vm.c_fetch(here + 102)) # "f"
    assert_equal(255, @vc.vm.c_fetch(here + 103)) # "g"
    assert_equal(255, @vc.vm.c_fetch(here + 104)) # "h"
    assert_equal(255, @vc.vm.c_fetch(here + 105)) # "i"
    assert_equal(255, @vc.vm.c_fetch(here + 106)) # "j"
    assert_equal(255, @vc.vm.c_fetch(here + 107)) # "k"
    assert_equal(255, @vc.vm.c_fetch(here + 108)) # "l"
    assert_equal(255, @vc.vm.c_fetch(here + 109)) # "m"
    assert_equal(255, @vc.vm.c_fetch(here + 110)) # "n"
    assert_equal(255, @vc.vm.c_fetch(here + 111)) # "o"
    assert_equal(255, @vc.vm.c_fetch(here + 112)) # "p"
    assert_equal(255, @vc.vm.c_fetch(here + 113)) # "q"
    assert_equal(255, @vc.vm.c_fetch(here + 114)) # "r"
    assert_equal(255, @vc.vm.c_fetch(here + 115)) # "s"
    assert_equal(255, @vc.vm.c_fetch(here + 116)) # "t"
    assert_equal(255, @vc.vm.c_fetch(here + 117)) # "u"
    assert_equal(255, @vc.vm.c_fetch(here + 118)) # "v"
    assert_equal(255, @vc.vm.c_fetch(here + 119)) # "w"
    assert_equal(255, @vc.vm.c_fetch(here + 120)) # "x"
    assert_equal(255, @vc.vm.c_fetch(here + 121)) # "y"
    assert_equal(255, @vc.vm.c_fetch(here + 122)) # "z"
    assert_equal(255, @vc.vm.c_fetch(here + 123)) # "{"
    assert_equal(255, @vc.vm.c_fetch(here + 124)) # "|"
    assert_equal(255, @vc.vm.c_fetch(here + 125)) # "}"
    assert_equal(255, @vc.vm.c_fetch(here + 126)) # "~"
    assert_equal(255, @vc.vm.c_fetch(here + 127)) # "\177"
    assert_equal(255, @vc.vm.c_fetch(here + 128)) # "\200"
    assert_equal(255, @vc.vm.c_fetch(here + 129)) # "\201"
    assert_equal(255, @vc.vm.c_fetch(here + 130)) # "\202"
    assert_equal(255, @vc.vm.c_fetch(here + 131)) # "\203"
    assert_equal(255, @vc.vm.c_fetch(here + 132)) # "\204"
    assert_equal(255, @vc.vm.c_fetch(here + 133)) # "\205"
    assert_equal(255, @vc.vm.c_fetch(here + 134)) # "\206"
    assert_equal(255, @vc.vm.c_fetch(here + 135)) # "\207"
    assert_equal(255, @vc.vm.c_fetch(here + 136)) # "\210"
    assert_equal(255, @vc.vm.c_fetch(here + 137)) # "\211"
    assert_equal(255, @vc.vm.c_fetch(here + 138)) # "\212"
    assert_equal(255, @vc.vm.c_fetch(here + 139)) # "\213"
    assert_equal(255, @vc.vm.c_fetch(here + 140)) # "\214"
    assert_equal(255, @vc.vm.c_fetch(here + 141)) # "\215"
    assert_equal(255, @vc.vm.c_fetch(here + 142)) # "\216"
    assert_equal(255, @vc.vm.c_fetch(here + 143)) # "\217"
    assert_equal(255, @vc.vm.c_fetch(here + 144)) # "\220"
    assert_equal(255, @vc.vm.c_fetch(here + 145)) # "\221"
    assert_equal(255, @vc.vm.c_fetch(here + 146)) # "\222"
    assert_equal(255, @vc.vm.c_fetch(here + 147)) # "\223"
    assert_equal(255, @vc.vm.c_fetch(here + 148)) # "\224"
    assert_equal(255, @vc.vm.c_fetch(here + 149)) # "\225"
    assert_equal(255, @vc.vm.c_fetch(here + 150)) # "\226"
    assert_equal(255, @vc.vm.c_fetch(here + 151)) # "\227"
    assert_equal(255, @vc.vm.c_fetch(here + 152)) # "\230"
    assert_equal(255, @vc.vm.c_fetch(here + 153)) # "\231"
    assert_equal(255, @vc.vm.c_fetch(here + 154)) # "\232"
    assert_equal(255, @vc.vm.c_fetch(here + 155)) # "\233"
    assert_equal(255, @vc.vm.c_fetch(here + 156)) # "\234"
    assert_equal(255, @vc.vm.c_fetch(here + 157)) # "\235"
    assert_equal(255, @vc.vm.c_fetch(here + 158)) # "\236"
    assert_equal(255, @vc.vm.c_fetch(here + 159)) # "\237"
    assert_equal(255, @vc.vm.c_fetch(here + 160)) # "\240"
    assert_equal(255, @vc.vm.c_fetch(here + 161)) # "\241"
    assert_equal(255, @vc.vm.c_fetch(here + 162)) # "\242"
    assert_equal(255, @vc.vm.c_fetch(here + 163)) # "\243"
    assert_equal(255, @vc.vm.c_fetch(here + 164)) # "\244"
    assert_equal(255, @vc.vm.c_fetch(here + 165)) # "\245"
    assert_equal(255, @vc.vm.c_fetch(here + 166)) # "\246"
    assert_equal(255, @vc.vm.c_fetch(here + 167)) # "\247"
    assert_equal(255, @vc.vm.c_fetch(here + 168)) # "\250"
    assert_equal(255, @vc.vm.c_fetch(here + 169)) # "\251"
    assert_equal(255, @vc.vm.c_fetch(here + 170)) # "\252"
    assert_equal(255, @vc.vm.c_fetch(here + 171)) # "\253"
    assert_equal(255, @vc.vm.c_fetch(here + 172)) # "\254"
    assert_equal(255, @vc.vm.c_fetch(here + 173)) # "\255"
    assert_equal(255, @vc.vm.c_fetch(here + 174)) # "\256"
    assert_equal(255, @vc.vm.c_fetch(here + 175)) # "\257"
    assert_equal(255, @vc.vm.c_fetch(here + 176)) # "\260"
    assert_equal(255, @vc.vm.c_fetch(here + 177)) # "\261"
    assert_equal(255, @vc.vm.c_fetch(here + 178)) # "\262"
    assert_equal(255, @vc.vm.c_fetch(here + 179)) # "\263"
    assert_equal(255, @vc.vm.c_fetch(here + 180)) # "\264"
    assert_equal(255, @vc.vm.c_fetch(here + 181)) # "\265"
    assert_equal(255, @vc.vm.c_fetch(here + 182)) # "\266"
    assert_equal(255, @vc.vm.c_fetch(here + 183)) # "\267"
    assert_equal(255, @vc.vm.c_fetch(here + 184)) # "\270"
    assert_equal(255, @vc.vm.c_fetch(here + 185)) # "\271"
    assert_equal(255, @vc.vm.c_fetch(here + 186)) # "\272"
    assert_equal(255, @vc.vm.c_fetch(here + 187)) # "\273"
    assert_equal(255, @vc.vm.c_fetch(here + 188)) # "\274"
    assert_equal(255, @vc.vm.c_fetch(here + 189)) # "\275"
    assert_equal(255, @vc.vm.c_fetch(here + 190)) # "\276"
    assert_equal(255, @vc.vm.c_fetch(here + 191)) # "\277"
    assert_equal(255, @vc.vm.c_fetch(here + 192)) # "\300"
    assert_equal(255, @vc.vm.c_fetch(here + 193)) # "\301"
    assert_equal(255, @vc.vm.c_fetch(here + 194)) # "\302"
    assert_equal(255, @vc.vm.c_fetch(here + 195)) # "\303"
    assert_equal(255, @vc.vm.c_fetch(here + 196)) # "\304"
    assert_equal(255, @vc.vm.c_fetch(here + 197)) # "\305"
    assert_equal(255, @vc.vm.c_fetch(here + 198)) # "\306"
    assert_equal(255, @vc.vm.c_fetch(here + 199)) # "\307"
    assert_equal(255, @vc.vm.c_fetch(here + 200)) # "\310"
    assert_equal(255, @vc.vm.c_fetch(here + 201)) # "\311"
    assert_equal(255, @vc.vm.c_fetch(here + 202)) # "\312"
    assert_equal(255, @vc.vm.c_fetch(here + 203)) # "\313"
    assert_equal(255, @vc.vm.c_fetch(here + 204)) # "\314"
    assert_equal(255, @vc.vm.c_fetch(here + 205)) # "\315"
    assert_equal(255, @vc.vm.c_fetch(here + 206)) # "\316"
    assert_equal(255, @vc.vm.c_fetch(here + 207)) # "\317"
    assert_equal(255, @vc.vm.c_fetch(here + 208)) # "\320"
    assert_equal(255, @vc.vm.c_fetch(here + 209)) # "\321"
    assert_equal(255, @vc.vm.c_fetch(here + 210)) # "\322"
    assert_equal(255, @vc.vm.c_fetch(here + 211)) # "\323"
    assert_equal(255, @vc.vm.c_fetch(here + 212)) # "\324"
    assert_equal(255, @vc.vm.c_fetch(here + 213)) # "\325"
    assert_equal(255, @vc.vm.c_fetch(here + 214)) # "\326"
    assert_equal(255, @vc.vm.c_fetch(here + 215)) # "\327"
    assert_equal(255, @vc.vm.c_fetch(here + 216)) # "\330"
    assert_equal(255, @vc.vm.c_fetch(here + 217)) # "\331"
    assert_equal(255, @vc.vm.c_fetch(here + 218)) # "\332"
    assert_equal(255, @vc.vm.c_fetch(here + 219)) # "\333"
    assert_equal(255, @vc.vm.c_fetch(here + 220)) # "\334"
    assert_equal(255, @vc.vm.c_fetch(here + 221)) # "\335"
    assert_equal(255, @vc.vm.c_fetch(here + 222)) # "\336"
    assert_equal(255, @vc.vm.c_fetch(here + 223)) # "\337"
    assert_equal(255, @vc.vm.c_fetch(here + 224)) # "\340"
    assert_equal(255, @vc.vm.c_fetch(here + 225)) # "\341"
    assert_equal(255, @vc.vm.c_fetch(here + 226)) # "\342"
    assert_equal(255, @vc.vm.c_fetch(here + 227)) # "\343"
    assert_equal(255, @vc.vm.c_fetch(here + 228)) # "\344"
    assert_equal(255, @vc.vm.c_fetch(here + 229)) # "\345"
    assert_equal(255, @vc.vm.c_fetch(here + 230)) # "\346"
    assert_equal(255, @vc.vm.c_fetch(here + 231)) # "\347"
    assert_equal(255, @vc.vm.c_fetch(here + 232)) # "\350"
    assert_equal(255, @vc.vm.c_fetch(here + 233)) # "\351"
    assert_equal(255, @vc.vm.c_fetch(here + 234)) # "\352"
    assert_equal(255, @vc.vm.c_fetch(here + 235)) # "\353"
    assert_equal(255, @vc.vm.c_fetch(here + 236)) # "\354"
    assert_equal(255, @vc.vm.c_fetch(here + 237)) # "\355"
    assert_equal(255, @vc.vm.c_fetch(here + 238)) # "\356"
    assert_equal(255, @vc.vm.c_fetch(here + 239)) # "\357"
    assert_equal(255, @vc.vm.c_fetch(here + 240)) # "\360"
    assert_equal(255, @vc.vm.c_fetch(here + 241)) # "\361"
    assert_equal(255, @vc.vm.c_fetch(here + 242)) # "\362"
    assert_equal(255, @vc.vm.c_fetch(here + 243)) # "\363"
    assert_equal(255, @vc.vm.c_fetch(here + 244)) # "\364"
    assert_equal(255, @vc.vm.c_fetch(here + 245)) # "\365"
    assert_equal(255, @vc.vm.c_fetch(here + 246)) # "\366"
    assert_equal(255, @vc.vm.c_fetch(here + 247)) # "\367"
    assert_equal(255, @vc.vm.c_fetch(here + 248)) # "\370"
    assert_equal(255, @vc.vm.c_fetch(here + 249)) # "\371"
    assert_equal(255, @vc.vm.c_fetch(here + 250)) # "\372"
    assert_equal(255, @vc.vm.c_fetch(here + 251)) # "\373"
    assert_equal(255, @vc.vm.c_fetch(here + 252)) # "\374"
    assert_equal(255, @vc.vm.c_fetch(here + 253)) # "\375"
    assert_equal(255, @vc.vm.c_fetch(here + 254)) # "\376"
    assert_equal(255, @vc.vm.c_fetch(here + 255)) # "\377"
  end

  def test_stack_108_3
    @vc.parse ": test 256 0 do i 36 digit 0= if 255 then c, loop ;"
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run_limit = @vc.run_limit * 100
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(255, @vc.vm.c_fetch(here +   0)) # "\000"
    assert_equal(255, @vc.vm.c_fetch(here +   1)) # "\001"
    assert_equal(255, @vc.vm.c_fetch(here +   2)) # "\002"
    assert_equal(255, @vc.vm.c_fetch(here +   3)) # "\003"
    assert_equal(255, @vc.vm.c_fetch(here +   4)) # "\004"
    assert_equal(255, @vc.vm.c_fetch(here +   5)) # "\005"
    assert_equal(255, @vc.vm.c_fetch(here +   6)) # "\006"
    assert_equal(255, @vc.vm.c_fetch(here +   7)) # "\a"
    assert_equal(255, @vc.vm.c_fetch(here +   8)) # "\b"
    assert_equal(255, @vc.vm.c_fetch(here +   9)) # "\t"
    assert_equal(255, @vc.vm.c_fetch(here +  10)) # "\n"
    assert_equal(255, @vc.vm.c_fetch(here +  11)) # "\v"
    assert_equal(255, @vc.vm.c_fetch(here +  12)) # "\f"
    assert_equal(255, @vc.vm.c_fetch(here +  13)) # "\r"
    assert_equal(255, @vc.vm.c_fetch(here +  14)) # "\016"
    assert_equal(255, @vc.vm.c_fetch(here +  15)) # "\017"
    assert_equal(255, @vc.vm.c_fetch(here +  16)) # "\020"
    assert_equal(255, @vc.vm.c_fetch(here +  17)) # "\021"
    assert_equal(255, @vc.vm.c_fetch(here +  18)) # "\022"
    assert_equal(255, @vc.vm.c_fetch(here +  19)) # "\023"
    assert_equal(255, @vc.vm.c_fetch(here +  20)) # "\024"
    assert_equal(255, @vc.vm.c_fetch(here +  21)) # "\025"
    assert_equal(255, @vc.vm.c_fetch(here +  22)) # "\026"
    assert_equal(255, @vc.vm.c_fetch(here +  23)) # "\027"
    assert_equal(255, @vc.vm.c_fetch(here +  24)) # "\030"
    assert_equal(255, @vc.vm.c_fetch(here +  25)) # "\031"
    assert_equal(255, @vc.vm.c_fetch(here +  26)) # "\032"
    assert_equal(255, @vc.vm.c_fetch(here +  27)) # "\e"
    assert_equal(255, @vc.vm.c_fetch(here +  28)) # "\034"
    assert_equal(255, @vc.vm.c_fetch(here +  29)) # "\035"
    assert_equal(255, @vc.vm.c_fetch(here +  30)) # "\036"
    assert_equal(255, @vc.vm.c_fetch(here +  31)) # "\037"
    assert_equal(255, @vc.vm.c_fetch(here +  32)) # " "
    assert_equal(255, @vc.vm.c_fetch(here +  33)) # "!"
    assert_equal(255, @vc.vm.c_fetch(here +  34)) # "\""
    assert_equal(255, @vc.vm.c_fetch(here +  35)) # "#"
    assert_equal(255, @vc.vm.c_fetch(here +  36)) # "$"
    assert_equal(255, @vc.vm.c_fetch(here +  37)) # "%"
    assert_equal(255, @vc.vm.c_fetch(here +  38)) # "&"
    assert_equal(255, @vc.vm.c_fetch(here +  39)) # "'"
    assert_equal(255, @vc.vm.c_fetch(here +  40)) # "("
    assert_equal(255, @vc.vm.c_fetch(here +  41)) # ")"
    assert_equal(255, @vc.vm.c_fetch(here +  42)) # "*"
    assert_equal(255, @vc.vm.c_fetch(here +  43)) # "+"
    assert_equal(255, @vc.vm.c_fetch(here +  44)) # ","
    assert_equal(255, @vc.vm.c_fetch(here +  45)) # "-"
    assert_equal(255, @vc.vm.c_fetch(here +  46)) # "."
    assert_equal(255, @vc.vm.c_fetch(here +  47)) # "/"
    assert_equal(  0, @vc.vm.c_fetch(here +  48)) # "0"
    assert_equal(  1, @vc.vm.c_fetch(here +  49)) # "1"
    assert_equal(  2, @vc.vm.c_fetch(here +  50)) # "2"
    assert_equal(  3, @vc.vm.c_fetch(here +  51)) # "3"
    assert_equal(  4, @vc.vm.c_fetch(here +  52)) # "4"
    assert_equal(  5, @vc.vm.c_fetch(here +  53)) # "5"
    assert_equal(  6, @vc.vm.c_fetch(here +  54)) # "6"
    assert_equal(  7, @vc.vm.c_fetch(here +  55)) # "7"
    assert_equal(  8, @vc.vm.c_fetch(here +  56)) # "8"
    assert_equal(  9, @vc.vm.c_fetch(here +  57)) # "9"
    assert_equal(255, @vc.vm.c_fetch(here +  58)) # ":"
    assert_equal(255, @vc.vm.c_fetch(here +  59)) # ";"
    assert_equal(255, @vc.vm.c_fetch(here +  60)) # "<"
    assert_equal(255, @vc.vm.c_fetch(here +  61)) # "="
    assert_equal(255, @vc.vm.c_fetch(here +  62)) # ">"
    assert_equal(255, @vc.vm.c_fetch(here +  63)) # "?"
    assert_equal(255, @vc.vm.c_fetch(here +  64)) # "@"
    assert_equal( 10, @vc.vm.c_fetch(here +  65)) # "A"
    assert_equal( 11, @vc.vm.c_fetch(here +  66)) # "B"
    assert_equal( 12, @vc.vm.c_fetch(here +  67)) # "C"
    assert_equal( 13, @vc.vm.c_fetch(here +  68)) # "D"
    assert_equal( 14, @vc.vm.c_fetch(here +  69)) # "E"
    assert_equal( 15, @vc.vm.c_fetch(here +  70)) # "F"
    assert_equal( 16, @vc.vm.c_fetch(here +  71)) # "G"
    assert_equal( 17, @vc.vm.c_fetch(here +  72)) # "H"
    assert_equal( 18, @vc.vm.c_fetch(here +  73)) # "I"
    assert_equal( 19, @vc.vm.c_fetch(here +  74)) # "J"
    assert_equal( 20, @vc.vm.c_fetch(here +  75)) # "K"
    assert_equal( 21, @vc.vm.c_fetch(here +  76)) # "L"
    assert_equal( 22, @vc.vm.c_fetch(here +  77)) # "M"
    assert_equal( 23, @vc.vm.c_fetch(here +  78)) # "N"
    assert_equal( 24, @vc.vm.c_fetch(here +  79)) # "O"
    assert_equal( 25, @vc.vm.c_fetch(here +  80)) # "P"
    assert_equal( 26, @vc.vm.c_fetch(here +  81)) # "Q"
    assert_equal( 27, @vc.vm.c_fetch(here +  82)) # "R"
    assert_equal( 28, @vc.vm.c_fetch(here +  83)) # "S"
    assert_equal( 29, @vc.vm.c_fetch(here +  84)) # "T"
    assert_equal( 30, @vc.vm.c_fetch(here +  85)) # "U"
    assert_equal( 31, @vc.vm.c_fetch(here +  86)) # "V"
    assert_equal( 32, @vc.vm.c_fetch(here +  87)) # "W"
    assert_equal( 33, @vc.vm.c_fetch(here +  88)) # "X"
    assert_equal( 34, @vc.vm.c_fetch(here +  89)) # "Y"
    assert_equal( 35, @vc.vm.c_fetch(here +  90)) # "Z"
    assert_equal(255, @vc.vm.c_fetch(here +  91)) # "["
    assert_equal(255, @vc.vm.c_fetch(here +  92)) # "\\"
    assert_equal(255, @vc.vm.c_fetch(here +  93)) # "]"
    assert_equal(255, @vc.vm.c_fetch(here +  94)) # "^"
    assert_equal(255, @vc.vm.c_fetch(here +  95)) # "_"
    assert_equal(255, @vc.vm.c_fetch(here +  96)) # "`"
    assert_equal( 10, @vc.vm.c_fetch(here +  97)) # "a"
    assert_equal( 11, @vc.vm.c_fetch(here +  98)) # "b"
    assert_equal( 12, @vc.vm.c_fetch(here +  99)) # "c"
    assert_equal( 13, @vc.vm.c_fetch(here + 100)) # "d"
    assert_equal( 14, @vc.vm.c_fetch(here + 101)) # "e"
    assert_equal( 15, @vc.vm.c_fetch(here + 102)) # "f"
    assert_equal( 16, @vc.vm.c_fetch(here + 103)) # "g"
    assert_equal( 17, @vc.vm.c_fetch(here + 104)) # "h"
    assert_equal( 18, @vc.vm.c_fetch(here + 105)) # "i"
    assert_equal( 19, @vc.vm.c_fetch(here + 106)) # "j"
    assert_equal( 20, @vc.vm.c_fetch(here + 107)) # "k"
    assert_equal( 21, @vc.vm.c_fetch(here + 108)) # "l"
    assert_equal( 22, @vc.vm.c_fetch(here + 109)) # "m"
    assert_equal( 23, @vc.vm.c_fetch(here + 110)) # "n"
    assert_equal( 24, @vc.vm.c_fetch(here + 111)) # "o"
    assert_equal( 25, @vc.vm.c_fetch(here + 112)) # "p"
    assert_equal( 26, @vc.vm.c_fetch(here + 113)) # "q"
    assert_equal( 27, @vc.vm.c_fetch(here + 114)) # "r"
    assert_equal( 28, @vc.vm.c_fetch(here + 115)) # "s"
    assert_equal( 29, @vc.vm.c_fetch(here + 116)) # "t"
    assert_equal( 30, @vc.vm.c_fetch(here + 117)) # "u"
    assert_equal( 31, @vc.vm.c_fetch(here + 118)) # "v"
    assert_equal( 32, @vc.vm.c_fetch(here + 119)) # "w"
    assert_equal( 33, @vc.vm.c_fetch(here + 120)) # "x"
    assert_equal( 34, @vc.vm.c_fetch(here + 121)) # "y"
    assert_equal( 35, @vc.vm.c_fetch(here + 122)) # "z"
    assert_equal(255, @vc.vm.c_fetch(here + 123)) # "{"
    assert_equal(255, @vc.vm.c_fetch(here + 124)) # "|"
    assert_equal(255, @vc.vm.c_fetch(here + 125)) # "}"
    assert_equal(255, @vc.vm.c_fetch(here + 126)) # "~"
    assert_equal(255, @vc.vm.c_fetch(here + 127)) # "\177"
    assert_equal(255, @vc.vm.c_fetch(here + 128)) # "\200"
    assert_equal(255, @vc.vm.c_fetch(here + 129)) # "\201"
    assert_equal(255, @vc.vm.c_fetch(here + 130)) # "\202"
    assert_equal(255, @vc.vm.c_fetch(here + 131)) # "\203"
    assert_equal(255, @vc.vm.c_fetch(here + 132)) # "\204"
    assert_equal(255, @vc.vm.c_fetch(here + 133)) # "\205"
    assert_equal(255, @vc.vm.c_fetch(here + 134)) # "\206"
    assert_equal(255, @vc.vm.c_fetch(here + 135)) # "\207"
    assert_equal(255, @vc.vm.c_fetch(here + 136)) # "\210"
    assert_equal(255, @vc.vm.c_fetch(here + 137)) # "\211"
    assert_equal(255, @vc.vm.c_fetch(here + 138)) # "\212"
    assert_equal(255, @vc.vm.c_fetch(here + 139)) # "\213"
    assert_equal(255, @vc.vm.c_fetch(here + 140)) # "\214"
    assert_equal(255, @vc.vm.c_fetch(here + 141)) # "\215"
    assert_equal(255, @vc.vm.c_fetch(here + 142)) # "\216"
    assert_equal(255, @vc.vm.c_fetch(here + 143)) # "\217"
    assert_equal(255, @vc.vm.c_fetch(here + 144)) # "\220"
    assert_equal(255, @vc.vm.c_fetch(here + 145)) # "\221"
    assert_equal(255, @vc.vm.c_fetch(here + 146)) # "\222"
    assert_equal(255, @vc.vm.c_fetch(here + 147)) # "\223"
    assert_equal(255, @vc.vm.c_fetch(here + 148)) # "\224"
    assert_equal(255, @vc.vm.c_fetch(here + 149)) # "\225"
    assert_equal(255, @vc.vm.c_fetch(here + 150)) # "\226"
    assert_equal(255, @vc.vm.c_fetch(here + 151)) # "\227"
    assert_equal(255, @vc.vm.c_fetch(here + 152)) # "\230"
    assert_equal(255, @vc.vm.c_fetch(here + 153)) # "\231"
    assert_equal(255, @vc.vm.c_fetch(here + 154)) # "\232"
    assert_equal(255, @vc.vm.c_fetch(here + 155)) # "\233"
    assert_equal(255, @vc.vm.c_fetch(here + 156)) # "\234"
    assert_equal(255, @vc.vm.c_fetch(here + 157)) # "\235"
    assert_equal(255, @vc.vm.c_fetch(here + 158)) # "\236"
    assert_equal(255, @vc.vm.c_fetch(here + 159)) # "\237"
    assert_equal(255, @vc.vm.c_fetch(here + 160)) # "\240"
    assert_equal(255, @vc.vm.c_fetch(here + 161)) # "\241"
    assert_equal(255, @vc.vm.c_fetch(here + 162)) # "\242"
    assert_equal(255, @vc.vm.c_fetch(here + 163)) # "\243"
    assert_equal(255, @vc.vm.c_fetch(here + 164)) # "\244"
    assert_equal(255, @vc.vm.c_fetch(here + 165)) # "\245"
    assert_equal(255, @vc.vm.c_fetch(here + 166)) # "\246"
    assert_equal(255, @vc.vm.c_fetch(here + 167)) # "\247"
    assert_equal(255, @vc.vm.c_fetch(here + 168)) # "\250"
    assert_equal(255, @vc.vm.c_fetch(here + 169)) # "\251"
    assert_equal(255, @vc.vm.c_fetch(here + 170)) # "\252"
    assert_equal(255, @vc.vm.c_fetch(here + 171)) # "\253"
    assert_equal(255, @vc.vm.c_fetch(here + 172)) # "\254"
    assert_equal(255, @vc.vm.c_fetch(here + 173)) # "\255"
    assert_equal(255, @vc.vm.c_fetch(here + 174)) # "\256"
    assert_equal(255, @vc.vm.c_fetch(here + 175)) # "\257"
    assert_equal(255, @vc.vm.c_fetch(here + 176)) # "\260"
    assert_equal(255, @vc.vm.c_fetch(here + 177)) # "\261"
    assert_equal(255, @vc.vm.c_fetch(here + 178)) # "\262"
    assert_equal(255, @vc.vm.c_fetch(here + 179)) # "\263"
    assert_equal(255, @vc.vm.c_fetch(here + 180)) # "\264"
    assert_equal(255, @vc.vm.c_fetch(here + 181)) # "\265"
    assert_equal(255, @vc.vm.c_fetch(here + 182)) # "\266"
    assert_equal(255, @vc.vm.c_fetch(here + 183)) # "\267"
    assert_equal(255, @vc.vm.c_fetch(here + 184)) # "\270"
    assert_equal(255, @vc.vm.c_fetch(here + 185)) # "\271"
    assert_equal(255, @vc.vm.c_fetch(here + 186)) # "\272"
    assert_equal(255, @vc.vm.c_fetch(here + 187)) # "\273"
    assert_equal(255, @vc.vm.c_fetch(here + 188)) # "\274"
    assert_equal(255, @vc.vm.c_fetch(here + 189)) # "\275"
    assert_equal(255, @vc.vm.c_fetch(here + 190)) # "\276"
    assert_equal(255, @vc.vm.c_fetch(here + 191)) # "\277"
    assert_equal(255, @vc.vm.c_fetch(here + 192)) # "\300"
    assert_equal(255, @vc.vm.c_fetch(here + 193)) # "\301"
    assert_equal(255, @vc.vm.c_fetch(here + 194)) # "\302"
    assert_equal(255, @vc.vm.c_fetch(here + 195)) # "\303"
    assert_equal(255, @vc.vm.c_fetch(here + 196)) # "\304"
    assert_equal(255, @vc.vm.c_fetch(here + 197)) # "\305"
    assert_equal(255, @vc.vm.c_fetch(here + 198)) # "\306"
    assert_equal(255, @vc.vm.c_fetch(here + 199)) # "\307"
    assert_equal(255, @vc.vm.c_fetch(here + 200)) # "\310"
    assert_equal(255, @vc.vm.c_fetch(here + 201)) # "\311"
    assert_equal(255, @vc.vm.c_fetch(here + 202)) # "\312"
    assert_equal(255, @vc.vm.c_fetch(here + 203)) # "\313"
    assert_equal(255, @vc.vm.c_fetch(here + 204)) # "\314"
    assert_equal(255, @vc.vm.c_fetch(here + 205)) # "\315"
    assert_equal(255, @vc.vm.c_fetch(here + 206)) # "\316"
    assert_equal(255, @vc.vm.c_fetch(here + 207)) # "\317"
    assert_equal(255, @vc.vm.c_fetch(here + 208)) # "\320"
    assert_equal(255, @vc.vm.c_fetch(here + 209)) # "\321"
    assert_equal(255, @vc.vm.c_fetch(here + 210)) # "\322"
    assert_equal(255, @vc.vm.c_fetch(here + 211)) # "\323"
    assert_equal(255, @vc.vm.c_fetch(here + 212)) # "\324"
    assert_equal(255, @vc.vm.c_fetch(here + 213)) # "\325"
    assert_equal(255, @vc.vm.c_fetch(here + 214)) # "\326"
    assert_equal(255, @vc.vm.c_fetch(here + 215)) # "\327"
    assert_equal(255, @vc.vm.c_fetch(here + 216)) # "\330"
    assert_equal(255, @vc.vm.c_fetch(here + 217)) # "\331"
    assert_equal(255, @vc.vm.c_fetch(here + 218)) # "\332"
    assert_equal(255, @vc.vm.c_fetch(here + 219)) # "\333"
    assert_equal(255, @vc.vm.c_fetch(here + 220)) # "\334"
    assert_equal(255, @vc.vm.c_fetch(here + 221)) # "\335"
    assert_equal(255, @vc.vm.c_fetch(here + 222)) # "\336"
    assert_equal(255, @vc.vm.c_fetch(here + 223)) # "\337"
    assert_equal(255, @vc.vm.c_fetch(here + 224)) # "\340"
    assert_equal(255, @vc.vm.c_fetch(here + 225)) # "\341"
    assert_equal(255, @vc.vm.c_fetch(here + 226)) # "\342"
    assert_equal(255, @vc.vm.c_fetch(here + 227)) # "\343"
    assert_equal(255, @vc.vm.c_fetch(here + 228)) # "\344"
    assert_equal(255, @vc.vm.c_fetch(here + 229)) # "\345"
    assert_equal(255, @vc.vm.c_fetch(here + 230)) # "\346"
    assert_equal(255, @vc.vm.c_fetch(here + 231)) # "\347"
    assert_equal(255, @vc.vm.c_fetch(here + 232)) # "\350"
    assert_equal(255, @vc.vm.c_fetch(here + 233)) # "\351"
    assert_equal(255, @vc.vm.c_fetch(here + 234)) # "\352"
    assert_equal(255, @vc.vm.c_fetch(here + 235)) # "\353"
    assert_equal(255, @vc.vm.c_fetch(here + 236)) # "\354"
    assert_equal(255, @vc.vm.c_fetch(here + 237)) # "\355"
    assert_equal(255, @vc.vm.c_fetch(here + 238)) # "\356"
    assert_equal(255, @vc.vm.c_fetch(here + 239)) # "\357"
    assert_equal(255, @vc.vm.c_fetch(here + 240)) # "\360"
    assert_equal(255, @vc.vm.c_fetch(here + 241)) # "\361"
    assert_equal(255, @vc.vm.c_fetch(here + 242)) # "\362"
    assert_equal(255, @vc.vm.c_fetch(here + 243)) # "\363"
    assert_equal(255, @vc.vm.c_fetch(here + 244)) # "\364"
    assert_equal(255, @vc.vm.c_fetch(here + 245)) # "\365"
    assert_equal(255, @vc.vm.c_fetch(here + 246)) # "\366"
    assert_equal(255, @vc.vm.c_fetch(here + 247)) # "\367"
    assert_equal(255, @vc.vm.c_fetch(here + 248)) # "\370"
    assert_equal(255, @vc.vm.c_fetch(here + 249)) # "\371"
    assert_equal(255, @vc.vm.c_fetch(here + 250)) # "\372"
    assert_equal(255, @vc.vm.c_fetch(here + 251)) # "\373"
    assert_equal(255, @vc.vm.c_fetch(here + 252)) # "\374"
    assert_equal(255, @vc.vm.c_fetch(here + 253)) # "\375"
    assert_equal(255, @vc.vm.c_fetch(here + 254)) # "\376"
    assert_equal(255, @vc.vm.c_fetch(here + 255)) # "\377"
  end



# >number
  def test_stack_109
    @vc.parse <<EOF

: test 0. s" 123" >number ;

EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(123, @vc.vm.pick(3))
  end


  def test_stack_109_1
    @vc.parse <<EOF

: test 0. s" .123" >number ;

EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
  end

  def test_stack_109_2
    @vc.parse <<EOF

: test 0. s" 1.23" >number ;

EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

  def test_stack_109_3
    @vc.parse <<EOF

: test 0. s" 12.3" >number ;

EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(12, @vc.vm.pick(3))
  end

  def test_stack_109_4
    @vc.parse <<EOF

: test 0. s" 123." >number ;

EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(123, @vc.vm.pick(3))
  end

# sgn
  def test_stack_110
    @vc.parse(": test -100 sgn 0 sgn 2 sgn ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(-1, @vc.vm.signed(@vc.vm.pick(2)))
  end

# casecompare
  def test_stack_111
    @vc.parse <<EOF
: test 
   here
   s" 123"  s" abc"  casecompare ,
   s" abc"  s" 123"  casecompare ,
   s" abc"  s" abc"  casecompare ,
   s" abc"  s" abcd" casecompare ,
   s" abcd" s" abc"  casecompare ,
   s" 123"  s" ab"   casecompare ,
   s" 12"   s" abc"  casecompare ,
   s" ab"   s" 123"  casecompare ,
   s" abc"  s" 12"   casecompare ,
   s" ABC"  s" abc"  casecompare ,
   s" abc"  s" ABC"  casecompare , ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 100
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_not_equal(0, @vc.vm.tos)
    here = @vc.vm.tos
    assert_equal(-1, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(0))))
    assert_equal( 1, @vc.vm.fetch(here + @vc.cells(1)))
    assert_equal( 0, @vc.vm.fetch(here + @vc.cells(2)))
    assert_equal(-1, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(3))))
    assert_equal( 1, @vc.vm.fetch(here + @vc.cells(4)))
    assert_equal(-1, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(5))))
    assert_equal(-1, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(6))))
    assert_equal( 1, @vc.vm.fetch(here + @vc.cells(7)))
    assert_equal( 1, @vc.vm.fetch(here + @vc.cells(8)))
    assert_equal( 0, @vc.vm.fetch(here + @vc.cells(9)))
    assert_equal( 0, @vc.vm.fetch(here + @vc.cells(10)))
  end

# D+
  def test_stack_112
    @vc.parse ": test 0. 1. d+ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

  def test_stack_112_1
    @vc.parse ": test 0. -1. d+ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
  end

  def test_stack_112_2
    @vc.parse ": test -1. 1. d+ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
  end

# D-
  def test_stack_113
    @vc.parse ": test 0. 1. d- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
  end

  def test_stack_113_1
    @vc.parse ": test 0. -1. d- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

  def test_stack_113_2
    @vc.parse ": test 2. 1. d- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

# dnegate
  def test_stack_114
    @vc.parse ": test 0. dnegate ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
  end

  def test_stack_114_1
    @vc.parse ": test 1. dnegate ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
  end

  def test_stack_114_2
    @vc.parse ": test -1. dnegate ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

# n>r
# nr>
  def test_stack_115

    @vc.parse <<EOF

: test
   10 11 12 3 n>r nr>
;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(12, @vc.vm.nos)
    assert_equal(11, @vc.vm.pick(2))
    assert_equal(10, @vc.vm.pick(3))
  end

# rp@
  def test_stack_116
    @vc.parse ": test rp@ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(@vc.vm.rdepth, @vc.vm.tos)
  end

  def test_stack_116_1
    @vc.parse ": test 1 >r rp@ r> drop ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
  end

  def test_stack_116_2
    @vc.parse ": test 1 2 2>r rp@ 2r> 2drop ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
  end

# sp@
  def test_stack_117
    @vc.parse ": test sp@ ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_stack_117_1
    @vc.parse ": test 1 sp@ swap drop ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
  end

  def test_stack_117_2
    @vc.parse ": test 1 2 sp@ -rot 2drop ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
  end

# +-
  def test_stack_118_1
    @vc.parse ": test 10 1 +- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
  end

  def test_stack_118_2
    @vc.parse ": test 10 0 +- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
  end

  def test_stack_118_3
    @vc.parse ": test 10 -1 +- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-10, @vc.vm.signed(@vc.vm.tos))
  end

  def test_stack_118_4
    @vc.parse ": test 10 -195 +- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-10, @vc.vm.signed(@vc.vm.tos))
  end

# D+-
  def test_stack_119_1
    @vc.parse ": test 10. 1 d+- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
  end

  def test_stack_119_2
    @vc.parse ": test 10. 0 d+- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
  end

  def test_stack_119_3
    @vc.parse ": test 10. -1 d+- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-10, @vc.vm.signed(@vc.vm.nos))
  end

  def test_stack_119_4
    @vc.parse ": test 10. -1999 d+- ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-10, @vc.vm.signed(@vc.vm.nos))
  end

# ut*
  def test_stack_120_1
    @vc.parse ": test 10. 5 ut* ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(0,  @vc.vm.nos)
    assert_equal(50,  @vc.vm.pick(2))
  end

  def test_stack_120_2
    @vc.parse ": test #{@m} 0 #{@n} ut* ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(@n/2,  @vc.vm.nos)
    assert_equal(@m,  @vc.vm.pick(2))
  end

  # 3fffffff 7fffffff 80000001
  def test_stack_120_3
    @vc.parse ": test #{@nn}. #{@n} ut* ;"
    @vc.compile
    @vc.run
    assert_equal(3,  @vc.vm.depth)
    assert_equal(@n/2,  @vc.vm.tos)
    assert_equal(@n,  @vc.vm.nos)
    assert_equal(@n+2,  @vc.vm.pick(2))
  end


# ut/mod
  def test_stack_121_1
    @vc.parse ": test 10 0 0 5 ut/mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(0,  @vc.vm.nos)
    assert_equal(2,  @vc.vm.pick(2))
    assert_equal(0,  @vc.vm.pick(3))
  end

  def test_stack_121_2
    @vc.parse ": test 10 0 0 4 ut/mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4,  @vc.vm.depth)
    assert_equal(0,  @vc.vm.tos)
    assert_equal(0,  @vc.vm.nos)
    assert_equal(2,  @vc.vm.pick(2))
    assert_equal(2,  @vc.vm.pick(3))
  end

  def test_stack_121_3
    @vc.parse ": test -1 -1 -1 -1 ut/mod ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4,  @vc.vm.depth)
    assert_equal(1,  @vc.vm.tos)
    assert_equal(1,  @vc.vm.nos)
    assert_equal(1,  @vc.vm.pick(2))
    assert_equal(0,  @vc.vm.pick(3))
  end

# dabs
  def test_stack_122_1
    @vc.parse ": test 0. dabs ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
  end

  def test_stack_122_2
    @vc.parse ": test 1. dabs ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

  def test_stack_122_3
    @vc.parse ": test -1. dabs ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

  # bounds
  def test_stack_123
    @vc.parse ": test 10 1 bounds ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
    assert_equal(11, @vc.vm.nos)
  end

# cset/creset/ctoggle
  def test_stack_124
    @vc.parse ": test 3 pad c! 4 pad cset pad c@ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(7, @vc.vm.tos)
  end

  def test_stack_125
    @vc.parse ": test 3 pad c! 1 pad creset pad c@ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
  end

  def test_stack_126
    @vc.parse ": test 3 pad c! 5 pad ctoggle pad c@ ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(6, @vc.vm.tos)
  end

# test constant values
  def test_constants
    @vc.parse <<EOF
: test here

    (=bs) ,
    (=rub) ,
    (=lf) ,
    (=cr) ,
    BL ,
    0 ,
    (pad) ,
    (error-ABORT) ,
    (error-ABORT") , ( " )
    (error-stack-o) ,
    (error-stack-u) ,
    (error-return-o) ,
    (error-return-u) ,
    (error-do) ,
    (error-dict) ,
    (error-mem) ,
    (error-div) ,
    (error-range) ,
    (error-type) ,
    (error-undef) ,
    (error-compile-only) ,
    (error-forget) ,
    (error-no-name) ,
    (error-num-o) ,
    (error-string-o) ,
    (error-def-o) ,
    (error-read-only) ,
    (error-unsupported) ,
    (error-control) ,
    (error-align) ,
    (error-num) ,
    (error-return-i) ,
    (error-loop-u) ,
    (error-recursion) ,
    (error-interrupt) ,
    (error-nesting) ,
    (error-obsolete) ,
    (error-body) ,
    (error-name-a) ,
    (error-blk-read) ,
    (error-blk-write) ,
    (error-blk-invalid) ,
    (error-file-pos) ,
    (error-file-io) ,
    (error-file-not-found) ,
    (error-eof) ,
    (error-base) ,
    (error-precision) ,
    (error-float-div) ,
    (error-float-range) ,
    (error-float-stack-o) ,
    (error-float-stack-u) ,
    (error-float-invalid) ,
    (error-deleted) ,
    (error-postpone) ,
    (error-search-o) ,
    (error-search-u) ,
    (error-changed) ,
    (error-control-o) ,
    (error-exception-o) ,
    (error-float-o) ,
    (error-float-fault) ,
    (error-quit) ,
    (error-char) ,
    (error-fpp) ,
    (error-ALLOCATE) ,
    (error-FREE) ,
    (error-RESIZE) ,
    (error-CLOSE-FILE) ,
    (error-CREATE-FILE) ,
    (error-DELETE-FILE) ,
    (error-FILE-POSITION) ,
    (error-FILE-SIZE) ,
    (error-FILE-STATUS) ,
    (error-FLUSH-FILE) ,
    (error-OPEN-FILE) ,
    (error-READ-FILE) ,
    (error-READ-LINE) ,
    (error-RENAME-FILE) ,
    (error-REPOSITION-FILE) ,
    (error-RESIZE-FILE) ,
    (error-WRITE-FILE) ,
    (error-WRITE-LINE) ,
    (lex-start) ,
    (lex-immediate) ,
    (lex-compile-only) ,
    (lex-max-name) ,
    (#i) ,
    here ;
EOF
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run_limit = @vc.run_limit * 10
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(here + @vc.cells(88), @vc.vm.tos)
    assert_equal(here + 0, @vc.vm.nos)
    assert_equal(8, @vc.vm.fetch(here + @vc.cells(0)))
    assert_equal(127, @vc.vm.fetch(here + @vc.cells(1)))
    assert_equal(10, @vc.vm.fetch(here + @vc.cells(2)))
    assert_equal(13, @vc.vm.fetch(here + @vc.cells(3)))
    assert_equal(32, @vc.vm.fetch(here + @vc.cells(4)))
    assert_equal(0, @vc.vm.fetch(here + @vc.cells(5))) # removed
    assert_equal(68, @vc.vm.fetch(here + @vc.cells(6)))
    assert_equal(-1, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(7))))
    assert_equal(-2, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(8))))
    assert_equal(-3, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(9))))
    assert_equal(-4, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(10))))
    assert_equal(-5, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(11))))
    assert_equal(-6, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(12))))
    assert_equal(-7, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(13))))
    assert_equal(-8, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(14))))
    assert_equal(-9, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(15))))
    assert_equal(-10, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(16))))
    assert_equal(-11, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(17))))
    assert_equal(-12, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(18))))
    assert_equal(-13, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(19))))
    assert_equal(-14, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(20))))
    assert_equal(-15, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(21))))
    assert_equal(-16, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(22))))
    assert_equal(-17, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(23))))
    assert_equal(-18, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(24))))
    assert_equal(-19, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(25))))
    assert_equal(-20, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(26))))
    assert_equal(-21, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(27))))
    assert_equal(-22, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(28))))
    assert_equal(-23, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(29))))
    assert_equal(-24, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(30))))
    assert_equal(-25, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(31))))
    assert_equal(-26, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(32))))
    assert_equal(-27, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(33))))
    assert_equal(-28, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(34))))
    assert_equal(-29, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(35))))
    assert_equal(-30, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(36))))
    assert_equal(-31, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(37))))
    assert_equal(-32, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(38))))
    assert_equal(-33, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(39))))
    assert_equal(-34, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(40))))
    assert_equal(-35, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(41))))
    assert_equal(-36, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(42))))
    assert_equal(-37, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(43))))
    assert_equal(-38, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(44))))
    assert_equal(-39, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(45))))
    assert_equal(-40, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(46))))
    assert_equal(-41, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(47))))
    assert_equal(-42, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(48))))
    assert_equal(-43, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(49))))
    assert_equal(-44, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(50))))
    assert_equal(-45, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(51))))
    assert_equal(-46, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(52))))
    assert_equal(-47, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(53))))
    assert_equal(-48, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(54))))
    assert_equal(-49, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(55))))
    assert_equal(-50, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(56))))
    assert_equal(-51, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(57))))
    assert_equal(-52, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(58))))
    assert_equal(-53, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(59))))
    assert_equal(-54, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(60))))
    assert_equal(-55, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(61))))
    assert_equal(-56, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(62))))
    assert_equal(-57, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(63))))
    assert_equal(-58, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(64))))
    assert_equal(-59, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(65))))
    assert_equal(-60, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(66))))
    assert_equal(-61, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(67))))
    assert_equal(-62, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(68))))
    assert_equal(-63, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(69))))
    assert_equal(-64, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(70))))
    assert_equal(-65, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(71))))
    assert_equal(-66, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(72))))
    assert_equal(-67, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(73))))
    assert_equal(-68, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(74))))
    assert_equal(-69, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(75))))
    assert_equal(-70, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(76))))
    assert_equal(-71, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(77))))
    assert_equal(-72, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(78))))
    assert_equal(-73, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(79))))
    assert_equal(-74, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(80))))
    assert_equal(-75, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(81))))
    assert_equal(-76, @vc.vm.signed(@vc.vm.fetch(here + @vc.cells(82))))
    assert_equal(128, @vc.vm.fetch(here + @vc.cells(83)))
    assert_equal( 64, @vc.vm.fetch(here + @vc.cells(84)))
    assert_equal( 32, @vc.vm.fetch(here + @vc.cells(85)))
    assert_equal( 31, @vc.vm.fetch(here + @vc.cells(86)))
    assert_equal(  9, @vc.vm.fetch(here + @vc.cells(87)))
  end

# BLK

  def test_user_001
    @vc.parse(": test blk @ -1 blk ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end


# >IN

  def test_user_002
    @vc.parse(": test >in @ -1 >in ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (SRC@)

  def test_user_003
    @vc.parse(": test (src@) @ -1 (src@) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal( src, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# STATE

  def test_user_004
    @vc.parse(": test state @ -1 state ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# BASE

  def test_user_005
    @vc.parse(": test base @ -1 base ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (hld)

  def test_user_006
    @vc.parse(": test (hld) @ -1 (hld) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (here)

  def test_user_007
    @vc.parse(": test (here) @ -1 (here) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(here, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (src)

  def test_user_008
    @vc.parse(": test (src) @ -1 (src) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal( src, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (rx?)

  def test_user_009
    @vc.parse(": test (rx?) @ -1 (rx?) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (rx@)

  def test_user_010
    @vc.parse(": test (rx@) @ -1 (rx@) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (tx?)

  def test_user_011
    @vc.parse(": test (tx?) @ -1 (tx?) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (tx!)

  def test_user_012
    @vc.parse(": test (tx!) @ -1 (tx!) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (boot)

  def test_user_013
    @vc.parse(": test (boot) @ -1 (boot) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (SRCID)

  def test_user_014
    @vc.parse(": test (srcid) @ -1 (srcid) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# current

  def test_user_015
    @vc.parse(": test current @ -1 current ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (vocs)

  def test_user_016
    @vc.parse(": test (vocs) @ -1 (vocs) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# context

  def test_user_017
    @vc.parse(": test context @ -1 context ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# test_user_018 was cx1 test
# test_user_019 was cx2 test
# test_user_020 was cx3 test
# test_user_021 was cx4 test
# test_user_022 was cx5 test
# test_user_023 was cx6 test
# test_user_024 was cx7 test

# (sp0)

  def test_user_025
    @vc.parse(": test (sp0) @ -1 (sp0) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (rp0)

  def test_user_026
    @vc.parse(": test (rp0)  @ -1 (rp0)  ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# dpl

  def test_user_027
    @vc.parse(": test dpl  @ -1 dpl  ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# dpl

  def test_user_028
    @vc.parse(": test erf  @ -1 erf  ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (#user)

  def test_user_029
    @vc.parse(": test (#user) @ 1 (#user) +! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    nxtu = NUMU+1
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(NUMU, @vc.vm.tos)
    assert_equal(nxtu, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (src0)

  def test_user_030
    @vc.parse(": test (src0) @ -1 (src0) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(src, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (srcend)

  def test_user_031
    @vc.parse(": test (srcend) @ -1 (srcend) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(sct, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# tib

  def test_user_032
    @vc.parse(": test tib @ -1 tib ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(src, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (scratch)

  def test_user_033
    @vc.parse(": test (scratch) @ -1 (scratch) ! ;")
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(sct, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (abort"$)

  def test_user_034
    @vc.parse(': test (abort"$) @ -1 (abort"$) ! ;')
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# (#line)

  def test_user_035
    @vc.parse(': test (#line) @ -1 (#line) ! ;')
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end

# >IN-

  def test_user_036
    @vc.parse(': test >in- @ -1 >in- ! ;')
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    user = @vc.vm.u
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(NUMU, @vc.vm.fetch(user + @vc.cells(0)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(1)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(2)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(3)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(4)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(5)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(6)))
    assert_equal( @m1, @vc.vm.fetch(user + @vc.cells(7)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(8)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(9)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(10)))
    assert_equal(  10, @vc.vm.fetch(user + @vc.cells(11)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(12)))
    assert_equal(here, @vc.vm.fetch(user + @vc.cells(13)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(14)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(15)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(16)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(17)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(18)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(19)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(20)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(21)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(22)))
    assert_equal( src, @vc.vm.fetch(user + @vc.cells(23)))
    assert_equal( sct, @vc.vm.fetch(user + @vc.cells(24)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(25)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(26)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(27)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(28)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(29)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(30)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(31)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(32)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(33)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(34)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(35)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(36)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(37)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(38)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(39)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(40)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(41)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(42)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(43)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(44)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(45)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(46)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(47)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(48)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(49)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(50)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(51)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(52)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(53)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(54)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(55)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(56)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(57)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(58)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(59)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(60)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(61)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(62)))
    assert_equal(   0, @vc.vm.fetch(user + @vc.cells(63)))
  end



# compile,

# Control
# ---------

# if
  def test_control_001
    @vc.parse(": test 1 0 if 1 then ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
  end

  def test_control_002
    @vc.parse(": test 2 1 if 1 then ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
  end


# else
  def test_control_003
    @vc.parse(": test 2 0 if 1 else 3 then ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
  end

  def test_control_004
    @vc.parse(": test 2 1 if 4 else 3 then ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
  end


# exit
  def test_control_005
    @vc.parse(": test 1 2 exit 3 4 ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
  end

# begin until
  def test_control_006
    @vc.parse(": test 0 begin 1+ dup 3 > until ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
  end

# begin while repeat
  def test_control_007
    @vc.parse(": test 0 begin dup 3 < while 1+ repeat ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
  end

  def test_control_007_1
    @vc.parse(": test 0 begin dup 0< while 1+ repeat ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_control_007_2
    @vc.parse <<EOF
: test 0 begin s" this" 2drop dup 0< while 1+ s" 1234567" 2drop repeat ;
EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end


# do loop
  def test_control_008
    @vc.parse(": test 1 2 0 do 1+ 1+ 1+ loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(7, @vc.vm.tos)
  end

  def test_control_008_1
    @vc.parse(": test 5 0 do i loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
    assert_equal(3, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
  end

  def test_control_008_2
    @vc.parse(": test 2 0 do 2 0 do i j loop loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(8, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
    assert_equal(1, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(1, @vc.vm.pick(5))
    assert_equal(0, @vc.vm.pick(6))
    assert_equal(0, @vc.vm.pick(7))
  end

# do unloop loop
  def test_control_009
    @vc.parse(": test -4 10 0 do dup 1 > if unloop exit then 1+ loop 1+ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
  end

# do leave loop
  def test_control_010
    @vc.parse(": test -4 10 0 do dup 1 > if leave then 1+ loop 1+ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
  end

# do ?leave loop
  def test_control_010_01
    @vc.parse(": test -4 10 0 do dup 1 > ?leave 1+ loop 1+ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
  end

# do +loop
  def test_control_011
    @vc.parse(": test 1 10 0 do 1+ 1+ 1+ 3 +loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(13, @vc.vm.tos)
  end

  def test_control_011_1
    @vc.parse(": test 15 0 do i 3 +loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(12, @vc.vm.tos)
    assert_equal(9, @vc.vm.nos)
    assert_equal(6, @vc.vm.pick(2))
    assert_equal(3, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
  end

  def test_control_011_2
    @vc.parse(": test 0 -1 0 do 1+ -1 2 rshift 1+ +loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
  end

  def test_control_011_3
    @vc.parse(": test 0 0 -1 do 1+ -1 2 rshift 1+ negate +loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(4, @vc.vm.tos)
  end

# do unloop +loop
  def test_control_012
    @vc.parse(": test 4 9 0 do dup 5 > if unloop exit then 1+ 2 +loop 1+ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(6, @vc.vm.tos)
  end

# do leave +loop
  def test_control_013
    @vc.parse(": test 4 9 0 do dup 5 > if leave then 1+ 2 +loop 1+ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(7, @vc.vm.tos)
  end

# ?do +loop
  def test_control_014
    @vc.parse(": test 1 10 0 ?do 1+ 1+ 1+ 3 +loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(13, @vc.vm.tos)
  end

  def test_control_014_1
    @vc.parse(": test 1 0 0 ?do 1+ 1+ 1+ 3 +loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
  end

  def test_control_014_2
    @vc.parse(": test 6 10 ?do i -1 +loop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(5, @vc.vm.depth)
    assert_equal(6, @vc.vm.tos)
    assert_equal(7, @vc.vm.nos)
    assert_equal(8, @vc.vm.pick(2))
    assert_equal(9, @vc.vm.pick(3))
    assert_equal(10, @vc.vm.pick(4))
  end

# ?do unloop +loop
  def test_control_015
    @vc.parse(": test 4 9 0 ?do dup 5 > if unloop exit then 1+ 2 +loop 1+ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(6, @vc.vm.tos)
  end

  def test_control_015_1
    @vc.parse(": test 4 9 9 ?do dup 5 > if unloop exit then 1+ 2 +loop 1+ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(5, @vc.vm.tos)
  end

# ?do leave +loop
  def test_control_016
    @vc.parse(": test 4 9 0 ?do dup 5 > if leave then 1+ 2 +loop 1+ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(7, @vc.vm.tos)
  end

  def test_control_016_1
    @vc.parse(": test 4 -5 -5 ?do dup 5 > if leave then 1+ 2 +loop 1+ ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(5, @vc.vm.tos)
  end

# [']
  def test_control_017
    @vc.parse <<EOF
    : test1 ;
    : test ['] @ ['] hold ['] base ['] test1 ;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(@vc.tick('test1'), @vc.vm.tos)
    assert_equal(@vc.tick('base'), @vc.vm.nos)
    assert_equal(@vc.tick('hold'), @vc.vm.pick(2))
    assert_equal(@vc.tick('@'), @vc.vm.pick(3))
  end

# execute
  def test_control_018
    @vc.parse <<EOF
    : test1 1 2 3 ;
    : test ['] test1 execute ;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
    assert_equal(1, @vc.vm.pick(2))
  end

# catch
  def test_control_019
    @vc.parse <<EOF
    : test1 1 2 3 ;
    : test ['] test1 catch ;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(3, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

# throw
  def test_control_020
    @vc.parse <<EOF
    : test1 1 2 3 0 throw ;
    : test ['] test1 catch ;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(3, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(1, @vc.vm.pick(3))
  end

  def test_control_020_1
    @vc.parse <<EOF
    : test1 1 2 3 1 throw ;
    : test ['] test1 catch ;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
  end

  def test_control_020_2
    @vc.parse <<EOF
    : test1 1 2 3 -1 throw ;
    : test ['] test1 catch ;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
  end

  def test_control_020_3
    @vc.parse <<EOF
    : test1 drop 0 throw ;
    : test 1 ['] test1 catch ;

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_control_020_4
    @vc.parse <<EOF
    : test1 drop -1 throw ;
    : test 1 ['] test1 catch ; ( ' )

EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    # the value '0' is a consequence of the implementation of
    # throw, and not a requirement
    assert_equal(0, @vc.vm.nos)
  end

# BYE
  def test_control_021
    @vc.parse(": test 1 bye drop ;")
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
  end

# code literals
  def test_code_lit_000
    @vc.parse("code test 0 end-code")
    @vc.compile
  end

  def test_code_lit_001
    @vc.parse("code test 1 end-code")
    @vc.compile
  end

  def test_code_lit_002
    @vc.parse("code test 2 end-code")
    @vc.compile
  end

  def test_code_lit_003
    @vc.parse("code test -1 end-code")
    @vc.compile
  end

end
