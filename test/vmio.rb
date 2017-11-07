#
#  vmio.rb
#
#  Copyright (c) 2011 by Daniel Kelley
#
#  $Id:$
#

module VMIO

  extend NoRedef

# (utx?)
  def test_io_001
    @vc.parse ": test (utx?) ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
  end

# (urx?)
  def test_io_002
    @vc.parse ": test (urx?) ;"
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
  end

# (urx@)
  def test_io_003
    @vc.parse ": test (urx@) (urx@) (urx@) ;"
    @vc.compile
    inp = 'abc'
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(inp[-1].ord, @vc.vm.tos)
    assert_equal(inp[-2].ord, @vc.vm.nos)
    assert_equal(inp[-3].ord, @vc.vm.pick(2))
    assert_equal('', out)
  end

# (utx!)
  def test_io_004
    @vc.parse ": test [char] 1 (utx!) [char] 2 (utx!) [char] 3 (utx!) ;"
    @vc.compile
    inp = ''
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal('123', out)
    assert_equal('', inp)
  end

# key
  def test_io_005
    @vc.parse ": test ['] (urx@) (rx@) ! key key key ;"
    @vc.compile
    inp = 'abc'
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(inp[-1].ord, @vc.vm.tos)
    assert_equal(inp[-2].ord, @vc.vm.nos)
    assert_equal(inp[-3].ord, @vc.vm.pick(2))
    assert_equal('', out)
  end

# emit
  def test_io_006
    @vc.parse <<EOF
: test ['] (utx!) (tx!) ! [char] 1 emit [char] 2 emit [char] 3 emit ;
EOF
    @vc.compile
    inp = ''
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal('123', out)
    assert_equal('', inp)
  end

# cr
  def test_io_007
    @vc.parse <<EOF
: test ['] (utx!) (tx!) ! [char] 1 emit cr [char] 3 emit ;
EOF
    @vc.compile
    inp = ''
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal("1\r\n3", out)
    assert_equal('', inp)
  end

# space
  def test_io_008
    @vc.parse <<EOF
: test ['] (utx!) (tx!) ! [char] 1 emit space [char] 3 emit ;
EOF
    @vc.compile
    inp = ''
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal("1 3", out)
    assert_equal('', inp)
  end

# spaces
  def test_io_009
    @vc.parse <<EOF
: test ['] (utx!) (tx!) ! 
       [char] 1 emit 0 spaces [char] 2 emit 
       [char] 1 emit 1 spaces [char] 2 emit 
       [char] 1 emit 2 spaces [char] 2 emit 
       -1 spaces ;
EOF
    @vc.compile
    inp = ''
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal("121 21  2", out)
    assert_equal('', inp)
  end

# type
  def test_io_010
    @vc.parse <<EOF
: test ['] (utx!) (tx!) ! ( ' )
       [char] 1 emit s" " type [char] 2 emit 
       [char] 1 emit s" a" type [char] 2 emit 
       [char] 1 emit s" abcdefg" type [char] 2 emit ;
EOF
    @vc.compile
    inp = ''
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal("121a21abcdefg2", out)
    assert_equal('', inp)
  end

# u.
  def test_io_011
    @vc.parse ": test ['] (utx!) (tx!) ! 12345 u. ;"
    @vc.compile
    inp = ''
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal("12345 ", out)
    assert_equal('', inp)
  end

# .
  def test_io_012
    @vc.parse <<EOF
: test ['] (utx!) (tx!) ! ( ' )
       12345 . -54321 . ;
EOF
    @vc.compile
    inp = ''
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal("12345 -54321 ", out)
    assert_equal('', inp)
  end

# ."
  def test_io_013
    @vc.parse <<EOF
: test ['] (utx!) (tx!) ! ." abcde" ." " ." 1" ; ( ' )
EOF
    @vc.compile
    inp = ''
    out = ''
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal("abcde1", out)
    assert_equal('', inp)
  end

# accept
  def test_io_014
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) !  pad dup 10 accept ;
EOF
    @vc.compile
    inp = "\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(" ", out)
    pad = @vc.vm.nos
    # pad should have not been touched
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad)
    end
  end

  def test_io_014_01
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) !  pad dup 10 accept ;
EOF
    @vc.compile
    inp = "abc\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal("abc ", out)
    pad = @vc.vm.nos
    assert_equal(inp[0].ord,  @vc.vm.c_fetch(pad + 0))
    assert_equal(inp[1].ord,  @vc.vm.c_fetch(pad + 1))
    assert_equal(inp[2].ord,  @vc.vm.c_fetch(pad + 2))
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad+3)
    end
  end

  def test_io_014_02
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) !  pad dup 10 accept ;
EOF
    @vc.compile
    inp = "abcdefghijklmnop\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal("abcdefghij ", out)
    pad = @vc.vm.nos
    assert_equal(inp[0].ord,  @vc.vm.c_fetch(pad + 0))
    assert_equal(inp[1].ord,  @vc.vm.c_fetch(pad + 1))
    assert_equal(inp[2].ord,  @vc.vm.c_fetch(pad + 2))
    assert_equal(inp[3].ord,  @vc.vm.c_fetch(pad + 3))
    assert_equal(inp[4].ord,  @vc.vm.c_fetch(pad + 4))
    assert_equal(inp[5].ord,  @vc.vm.c_fetch(pad + 5))
    assert_equal(inp[6].ord,  @vc.vm.c_fetch(pad + 6))
    assert_equal(inp[7].ord,  @vc.vm.c_fetch(pad + 7))
    assert_equal(inp[8].ord,  @vc.vm.c_fetch(pad + 8))
    assert_equal(inp[9].ord,  @vc.vm.c_fetch(pad + 9))
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad+10)
    end
  end

  def test_io_014_03
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) !  pad dup 10 accept ;
EOF
    @vc.compile
    inp = "abcdefghijklmnop\010\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(9, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal("abcdefghij\b \b ", out)
    pad = @vc.vm.nos
    assert_equal(inp[0].ord,  @vc.vm.c_fetch(pad + 0))
    assert_equal(inp[1].ord,  @vc.vm.c_fetch(pad + 1))
    assert_equal(inp[2].ord,  @vc.vm.c_fetch(pad + 2))
    assert_equal(inp[3].ord,  @vc.vm.c_fetch(pad + 3))
    assert_equal(inp[4].ord,  @vc.vm.c_fetch(pad + 4))
    assert_equal(inp[5].ord,  @vc.vm.c_fetch(pad + 5))
    assert_equal(inp[6].ord,  @vc.vm.c_fetch(pad + 6))
    assert_equal(inp[7].ord,  @vc.vm.c_fetch(pad + 7))
    assert_equal(inp[8].ord,  @vc.vm.c_fetch(pad + 8))
    assert_equal(inp[9].ord,  @vc.vm.c_fetch(pad + 9))
    assert_raise GMPForth::MemoryUninitializedError do
      @vc.vm.c_fetch(pad+10)
    end
  end

# source
  def test_io_15
    @vc.parse(": test source ;")
    @vc.compile
    @vc.init_user
    src  = @vc.fetch_user('tib')
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(src, @vc.vm.nos)
  end

# save-input
  def test_io_16
    to_in = 10
    src_at = 20
    src_id = 30
    @vc.parse <<EOF
: test 
   #{to_in} >in ! #{src_at} (src@) ! #{src_id} (srcid) ! 
   save-input ;
EOF
    @vc.compile
    @vc.init_user
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(10, @vc.vm.depth)
    assert_equal(9, @vc.vm.tos)
    assert_equal(to_in, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(src_id, @vc.vm.pick(5))
    assert_equal(src_at, @vc.vm.pick(6))
    assert_equal(src, @vc.vm.pick(7))
    assert_equal(sct, @vc.vm.pick(8))
    assert_equal(src, @vc.vm.pick(9))
  end

# restore-input
  def test_io_17
    to_in = 10
    src_at = 20
    src_id = 30
    @vc.parse <<EOF
: test 
    #{to_in} >in ! #{src_at} (src@) ! #{src_id} (srcid) ! 
    save-input
    0 (src) !
    0 (src@) !
    0 >in !
    0 (srcid) !
    restore-input >r save-input r> ;
EOF
    @vc.compile
    @vc.init_user
    src  = @vc.fetch_user('tib')
    sct  = @vc.fetch_user('(scratch)')
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(11, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(9, @vc.vm.nos)
    assert_equal(to_in, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
    assert_equal(src_id, @vc.vm.pick(6))
    assert_equal(src_at, @vc.vm.pick(7))
    assert_equal(src, @vc.vm.pick(8))
    assert_equal(sct, @vc.vm.pick(9))
    assert_equal(src, @vc.vm.pick(10))
  end

  def test_io_17_1
    @vc.parse <<EOF
: test 
    1 0 restore-input ;
EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(1, @vc.vm.pick(2))
  end

  def test_io_17_2
    @vc.parse <<EOF
: test 
    3 2 1 restore-input ;
EOF
    @vc.compile
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
    assert_equal(2, @vc.vm.pick(2))
    assert_equal(3, @vc.vm.pick(3))
  end

# refill
  def test_io_018
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! refill source ;
EOF
    @vc.compile
    inp = "\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal(" ", out)
  end

  def test_io_018_01
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! refill source ;
EOF
    @vc.compile
    inp = "abc\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal("abc ", out)
    buf = @vc.vm.nos
    assert_equal(inp[0].ord,  @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[1].ord,  @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[2].ord,  @vc.vm.c_fetch(buf + 2))
  end

  def test_io_018_02
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! refill source ;
EOF
    @vc.compile
    inp = "abcdefghijklmnop\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(16, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal("abcdefghijklmnop ", out)
    buf = @vc.vm.nos
    assert_equal(inp[0].ord,  @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[1].ord,  @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[2].ord,  @vc.vm.c_fetch(buf + 2))
    assert_equal(inp[3].ord,  @vc.vm.c_fetch(buf + 3))
    assert_equal(inp[4].ord,  @vc.vm.c_fetch(buf + 4))
    assert_equal(inp[5].ord,  @vc.vm.c_fetch(buf + 5))
    assert_equal(inp[6].ord,  @vc.vm.c_fetch(buf + 6))
    assert_equal(inp[7].ord,  @vc.vm.c_fetch(buf + 7))
    assert_equal(inp[8].ord,  @vc.vm.c_fetch(buf + 8))
    assert_equal(inp[9].ord,  @vc.vm.c_fetch(buf + 9))
    assert_equal(inp[10].ord,  @vc.vm.c_fetch(buf + 10))
    assert_equal(inp[11].ord,  @vc.vm.c_fetch(buf + 11))
    assert_equal(inp[12].ord,  @vc.vm.c_fetch(buf + 12))
    assert_equal(inp[13].ord,  @vc.vm.c_fetch(buf + 13))
    assert_equal(inp[14].ord,  @vc.vm.c_fetch(buf + 14))
    assert_equal(inp[15].ord,  @vc.vm.c_fetch(buf + 15))
  end

  def test_io_018_03
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! refill source >in @ ;
EOF
    @vc.compile
    inp = "abcdefghijklmnop\010\010qr\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(16, @vc.vm.nos)
    assert_not_equal(0, @vc.vm.pick(2))
    assert_equal(@m1, @vc.vm.pick(3))
    assert_equal("abcdefghijklmnop\b \b\b \bqr ", out)
    buf = @vc.vm.pick(2)
    assert_equal(inp[0].ord,  @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[1].ord,  @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[2].ord,  @vc.vm.c_fetch(buf + 2))
    assert_equal(inp[3].ord,  @vc.vm.c_fetch(buf + 3))
    assert_equal(inp[4].ord,  @vc.vm.c_fetch(buf + 4))
    assert_equal(inp[5].ord,  @vc.vm.c_fetch(buf + 5))
    assert_equal(inp[6].ord,  @vc.vm.c_fetch(buf + 6))
    assert_equal(inp[7].ord,  @vc.vm.c_fetch(buf + 7))
    assert_equal(inp[8].ord,  @vc.vm.c_fetch(buf + 8))
    assert_equal(inp[9].ord,  @vc.vm.c_fetch(buf + 9))
    assert_equal(inp[10].ord,  @vc.vm.c_fetch(buf + 10))
    assert_equal(inp[11].ord,  @vc.vm.c_fetch(buf + 11))
    assert_equal(inp[12].ord,  @vc.vm.c_fetch(buf + 12))
    assert_equal(inp[13].ord,  @vc.vm.c_fetch(buf + 13))
    assert_equal(inp[-3].ord,  @vc.vm.c_fetch(buf + 14))
    assert_equal(inp[-2].ord,  @vc.vm.c_fetch(buf + 15))
  end

  def test_io_018_04
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! -1 (srcid) ! refill ;
EOF
    @vc.compile
    inp = ""
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal("", out)
  end

# (scan)
#  def test_io_019_01
#  def test_io_019_02
#  def test_io_019_03
#  def test_io_019_04
#  def test_io_019_05
#  def test_io_019_06
#  def test_io_019_07
#  def test_io_019_08
#  def test_io_019_09
#  def test_io_019_10
# (parse-begin)
#  def test_io_020
#  def test_io_020_01
# (parse-end)
#  def test_io_021

# parse
  def test_io_022
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if bl parse then 
   save-input ;
EOF
    @vc.compile
    inp = "this is a test\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(12, @vc.vm.depth)
    assert_equal(9, @vc.vm.tos)
    assert_equal(5, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(14, @vc.vm.pick(6) - @vc.vm.pick(7))
    assert_not_equal(0, @vc.vm.pick(7))
    # ignoring (src0), (srcend)
    assert_equal(4, @vc.vm.pick(10))
    assert_not_equal(0, @vc.vm.pick(11))
    assert_equal("this is a test ", out)
    buf = @vc.vm.pick(11)
    assert_equal(inp[0].ord,   @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[1].ord,   @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[2].ord,   @vc.vm.c_fetch(buf + 2))
    assert_equal(inp[3].ord,   @vc.vm.c_fetch(buf + 3))
  end

  def test_io_022_1
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if [char] a parse then 
   save-input ;
EOF
    @vc.compile
    inp = "this is a test\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(12, @vc.vm.depth)
    assert_equal(9, @vc.vm.tos)
    assert_equal(9, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(14, @vc.vm.pick(6) - @vc.vm.pick(7))
    assert_not_equal(0, @vc.vm.pick(7))
    # ignoring (src0), (srcend)
    assert_equal(8, @vc.vm.pick(10))
    assert_not_equal(0, @vc.vm.pick(11))
    assert_equal("this is a test ", out)
    buf = @vc.vm.pick(11)
    assert_equal(inp[0].ord,   @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[1].ord,   @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[2].ord,   @vc.vm.c_fetch(buf + 2))
    assert_equal(inp[3].ord,   @vc.vm.c_fetch(buf + 3))
    assert_equal(inp[4].ord,   @vc.vm.c_fetch(buf + 4))
    assert_equal(inp[5].ord,   @vc.vm.c_fetch(buf + 5))
    assert_equal(inp[6].ord,   @vc.vm.c_fetch(buf + 6))
    assert_equal(inp[7].ord,   @vc.vm.c_fetch(buf + 7))
  end

  def test_io_022_2
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if [char] Z parse then 
   save-input ;
EOF
    @vc.compile
    inp = "this is a test\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(12, @vc.vm.depth)
    assert_equal(9, @vc.vm.tos)
    assert_equal(14, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(14, @vc.vm.pick(6) - @vc.vm.pick(7))
    assert_not_equal(0, @vc.vm.pick(7))
    # ignoring (src0), (srcend)
    assert_equal(14, @vc.vm.pick(10))
    assert_not_equal(0, @vc.vm.pick(11))
    assert_equal("this is a test ", out)
    buf = @vc.vm.pick(11)
    assert_equal(inp[0].ord,   @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[1].ord,   @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[2].ord,   @vc.vm.c_fetch(buf + 2))
    assert_equal(inp[3].ord,   @vc.vm.c_fetch(buf + 3))
    assert_equal(inp[4].ord,   @vc.vm.c_fetch(buf + 4))
    assert_equal(inp[5].ord,   @vc.vm.c_fetch(buf + 5))
    assert_equal(inp[6].ord,   @vc.vm.c_fetch(buf + 6))
    assert_equal(inp[7].ord,   @vc.vm.c_fetch(buf + 7))
    assert_equal(inp[8].ord,   @vc.vm.c_fetch(buf + 8))
    assert_equal(inp[9].ord,   @vc.vm.c_fetch(buf + 9))
    assert_equal(inp[10].ord,  @vc.vm.c_fetch(buf + 10))
    assert_equal(inp[11].ord,  @vc.vm.c_fetch(buf + 11))
    assert_equal(inp[12].ord,  @vc.vm.c_fetch(buf + 12))
    assert_equal(inp[13].ord,  @vc.vm.c_fetch(buf + 13))
  end

# parse-name
  def test_io_023
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if parse-name then 
   save-input ;
EOF
    @vc.compile
    inp = "   this is a test\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(12, @vc.vm.depth)
    assert_equal(9, @vc.vm.tos)
    assert_equal(8, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(3, @vc.vm.pick(3))
    assert_equal(0, @vc.vm.pick(4))
    assert_equal(0, @vc.vm.pick(5))
    assert_equal(17, @vc.vm.pick(6) - @vc.vm.pick(7))
    assert_not_equal(0, @vc.vm.pick(7))
    # ignoring (src0), (srcend)
    assert_equal(4, @vc.vm.pick(10))
    assert_not_equal(0, @vc.vm.pick(11))
    assert_equal("   this is a test ", out)
    buf = @vc.vm.pick(11)
    assert_equal(inp[3].ord,   @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[4].ord,   @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[5].ord,   @vc.vm.c_fetch(buf + 2))
    assert_equal(inp[6].ord,   @vc.vm.c_fetch(buf + 3))
  end

  def test_io_023_1
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if parse-name then 
   save-input ;
EOF
    @vc.compile
    inp = "this is a test\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(12, @vc.vm.depth)
    assert_equal(9, @vc.vm.tos)
    assert_equal(5, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(14, @vc.vm.pick(6) - @vc.vm.pick(7))
    assert_not_equal(0, @vc.vm.pick(7))
    # ignoring (src0), (srcend)
    assert_equal(4, @vc.vm.pick(10))
    assert_not_equal(0, @vc.vm.pick(11))
    assert_equal("this is a test ", out)
    buf = @vc.vm.pick(11)
    assert_equal(inp[0].ord,   @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[1].ord,   @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[2].ord,   @vc.vm.c_fetch(buf + 2))
    assert_equal(inp[3].ord,   @vc.vm.c_fetch(buf + 3))
  end

  def test_io_023_2
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if parse-name then 
   save-input ;
EOF
    @vc.compile
    inp = "this\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(12, @vc.vm.depth)
    assert_equal(9, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(0, @vc.vm.pick(3))
    assert_equal(4, @vc.vm.pick(6) - @vc.vm.pick(7))
    assert_not_equal(0, @vc.vm.pick(7))
    # ignoring (src0), (srcend)
    assert_equal(4, @vc.vm.pick(10))
    assert_not_equal(0, @vc.vm.pick(11))
    assert_equal("this ", out)
    buf = @vc.vm.pick(11)
    assert_equal(inp[0].ord,   @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[1].ord,   @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[2].ord,   @vc.vm.c_fetch(buf + 2))
    assert_equal(inp[3].ord,   @vc.vm.c_fetch(buf + 3))
  end

  def test_io_023_3
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if parse-name then 
   save-input ;
EOF
    @vc.compile
    inp = "    \r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(12, @vc.vm.depth)
    assert_equal(9, @vc.vm.tos)
    assert_equal(4, @vc.vm.nos)
    assert_equal(0, @vc.vm.pick(2))
    assert_equal(4, @vc.vm.pick(3))
    assert_equal(4, @vc.vm.pick(6) - @vc.vm.pick(7))
    assert_not_equal(0, @vc.vm.pick(7))
    # ignoring (src0), (srcend)
    assert_equal(0, @vc.vm.pick(10))
    assert_not_equal(0, @vc.vm.pick(11))
    assert_equal("     ", out)
  end

# (input)
  def test_io_024
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! refill (input) ;
EOF
    @vc.compile
    inp = "\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_not_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_not_equal(0, @vc.vm.tos)
    assert_equal(@vc.vm.tos, @vc.vm.nos)
    assert_equal(@m1, @vc.vm.pick(2))
    assert_equal(" ", out)
  end

  def test_io_024_01
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if 4 >in ! (input) then ;
EOF
    @vc.compile
    inp = "this is a test\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_not_equal(0, @vc.vm.nos)
    assert_not_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos - @vc.vm.tos)
    assert_equal("this is a test ", out)
    buf = @vc.vm.tos
    assert_equal(inp[4].ord,   @vc.vm.c_fetch(buf + 0))
    assert_equal(inp[5].ord,   @vc.vm.c_fetch(buf + 1))
    assert_equal(inp[6].ord,   @vc.vm.c_fetch(buf + 2))
    assert_equal(inp[7].ord,   @vc.vm.c_fetch(buf + 3))
    assert_equal(inp[8].ord,   @vc.vm.c_fetch(buf + 4))
    assert_equal(inp[9].ord,   @vc.vm.c_fetch(buf + 5))
    assert_equal(inp[10].ord,  @vc.vm.c_fetch(buf + 6))
    assert_equal(inp[11].ord,  @vc.vm.c_fetch(buf + 7))
    assert_equal(inp[12].ord,  @vc.vm.c_fetch(buf + 8))
    assert_equal(inp[13].ord,  @vc.vm.c_fetch(buf + 9))
  end

  def test_io_024_02
    # negative >in
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if -1 >in ! ['] (input) catch then ;
EOF
    @vc.compile
    inp = "this is a test\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-256, @vc.vm.signed(@vc.vm.tos))
  end

  def test_io_024_03
    # >in larger than input
    inp = "this is a test\r"
    ilen = inp.length+1
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if #{ilen} >in ! ['] (input) catch then ;
EOF
    @vc.compile
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-256, @vc.vm.signed(@vc.vm.tos))
  end

# (skip)
  def test_io_025
    @vc.parse <<EOF
: test
    (skip) >in @ ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_io_025_01
    @vc.parse <<EOF
: test  
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! 
   refill if (skip) >in @ then ;
EOF
    @vc.compile
    inp = "          this is a test\r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 100
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
  end


end

