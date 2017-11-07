#
#  vmoptimizer.rb
# 
#  Copyright (c) 2013 by Daniel Kelley
# 
# 
# Generic VM optimizer tests

# ''                    004
#
# next                  005
# op                    002
# push                  008
#
# op,next               001
# next,op               007
# op,op                 003
# next,next             006
#
# push,next             009
# next,push             010
# push,push             011
# push,push,next        012

#
# op,push               013
# next,op,push          014
# op,next,push          015
# op,push,next          016
#
# push,op               017
# next,push,op          018
# push,next,op          019
# push,op,next          020
#

require 'pp'
require 'gmpforth/vmseq'

module VMOptimizer

  extend NoRedef

  # op,next combined
  def test_vmopt_001
    @vc.parse 'code test vm_or vm_next end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal("vm_or", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].push)
    assert_equal(false, a[0].avoid)
    assert_equal("vm_next", a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(true, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].push)
    assert_equal(false, a[1].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal("vm_or", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].combine)
    assert_equal(false, a[0].push)
    assert_equal(false, a[0].avoid)
  end

  # single op-next -> op+next
  def test_vmopt_002
    @vc.parse 'code test vm_or end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal("vm_or", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal("vm_or", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

  # op,op -> op,op+next
  def test_vmopt_003
    @vc.parse 'code test vm_or vm_or end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal("vm_or", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal("vm_or", a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal("vm_or", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal("vm_or", a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(true, a[1].combine)
    assert_equal(false, a[1].avoid)
  end

  # <> -> <>
  def test_vmopt_004
    @vc.parse 'code test end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(0, a.length)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(0, a.length)
  end

  # next -> next
  def test_vmopt_005
    @vc.parse 'code test vm_next end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal("vm_next", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal("vm_next", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

  # next,next -> next
  def test_vmopt_006
    @vc.parse 'code test vm_next vm_next end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal("vm_next", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal("vm_next", a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(true, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal("vm_next", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

  # next,op -> next
  def test_vmopt_007
    @vc.parse 'code test vm_next vm_or end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal("vm_next", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal("vm_or", a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal("vm_next", a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

  # push -> push+next
  def test_vmopt_008
    @vc.parse 'code test 2 end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(true, a[0].push)
    assert_equal(false, a[0].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].combine)
    assert_equal(true, a[0].push)
    assert_equal(false, a[0].avoid)
  end

  # push,next -> push+next
  def test_vmopt_009
    @vc.parse 'code test 2 vm_next end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_next', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(true, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

  # next,push -> next
  def test_vmopt_010
    @vc.parse 'code test vm_next 2 end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_next', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(2, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_next', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

  # push,push -> push,push+next
  def test_vmopt_011
    @vc.parse 'code test 2 3 end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(3, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(3, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(true, a[1].combine)
    assert_equal(false, a[1].avoid)
  end

  # push,push,next -> push,push+next
  def test_vmopt_012
    @vc.parse 'code test 2 3 vm_next end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(3, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(3, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    assert_equal('vm_next', a[2].op)
    assert_equal(nil, a[2].arg)
    assert_equal(true, a[2].ret)
    assert_equal(false, a[2].combine)
    assert_equal(false, a[2].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(3, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(true, a[1].combine)
    assert_equal(false, a[1].avoid)
  end

  # op,push -> op,push+next
  def test_vmopt_013
    @vc.parse 'code test vm_or 2 end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_or', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(2, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[1].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_or', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(2, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(true, a[1].combine)
    assert_equal(false, a[1].avoid)
  end

  # next,op,push -> next
  def test_vmopt_014
    @vc.parse 'code test vm_next vm_or 2 end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(3, a.length)
    assert_equal('vm_next', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_or', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    assert_equal('vm_push', a[2].op)
    assert_equal(2, a[2].arg)
    assert_equal(false, a[2].ret)
    assert_equal(false, a[2].combine)
    assert_equal(false, a[2].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_next', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

  # op,next,push -> op+next
  def test_vmopt_015
    @vc.parse 'code test vm_or vm_next 2 end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(3, a.length)
    assert_equal('vm_or', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_next', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(true, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    assert_equal('vm_push', a[2].op)
    assert_equal(2, a[2].arg)
    assert_equal(false, a[2].ret)
    assert_equal(false, a[2].combine)
    assert_equal(false, a[2].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_or', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

 
  # op,push,next -> op,push+next
  def test_vmopt_016
    @vc.parse 'code test vm_or 2 vm_next end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(3, a.length)
    assert_equal('vm_or', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(2, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    assert_equal('vm_next', a[2].op)
    assert_equal(nil, a[2].arg)
    assert_equal(true, a[2].ret)
    assert_equal(false, a[2].combine)
    assert_equal(false, a[2].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_or', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(2, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(true, a[1].combine)
    assert_equal(false, a[1].avoid)
  end

  # push,op -> push,op+next
  def test_vmopt_017
    @vc.parse 'code test 2 vm_or end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_or', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_or', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(true, a[1].combine)
    assert_equal(false, a[1].avoid)
  end

  # next,push,op -> next
  def test_vmopt_018
    @vc.parse 'code test vm_next 2 vm_or end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(3, a.length)
    assert_equal('vm_next', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_push', a[1].op)
    assert_equal(2, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    assert_equal('vm_or', a[2].op)
    assert_equal(nil, a[2].arg)
    assert_equal(false, a[2].ret)
    assert_equal(false, a[2].combine)
    assert_equal(false, a[2].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_next', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(true, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

  # push,next,op -> push+next
  def test_vmopt_019
    @vc.parse 'code test 2 vm_next vm_or end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(3, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_next', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(true, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    assert_equal('vm_or', a[2].op)
    assert_equal(nil, a[2].arg)
    assert_equal(false, a[2].ret)
    assert_equal(false, a[2].combine)
    assert_equal(false, a[2].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].combine)
    assert_equal(false, a[0].avoid)
  end

 
  # push,op,next -> push,op+next
  def test_vmopt_020
    @vc.parse 'code test 2 vm_or vm_next end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(3, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_or', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(false, a[1].combine)
    assert_equal(false, a[1].avoid)
    assert_equal('vm_next', a[2].op)
    assert_equal(nil, a[2].arg)
    assert_equal(true, a[2].ret)
    assert_equal(false, a[2].combine)
    assert_equal(false, a[2].avoid)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_push', a[0].op)
    assert_equal(2, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(false, a[0].combine)
    assert_equal(false, a[0].avoid)
    assert_equal('vm_or', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(false, a[1].ret)
    assert_equal(true, a[1].combine)
    assert_equal(false, a[1].avoid)
  end

  # execute,next -> execute,next
  def test_vmopt_021
    @vc.parse 'code test vm_execute vm_next end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_execute', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].avoid)
    assert_equal(false, a[0].combine)
    assert_equal('vm_next', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(true, a[1].ret)
    assert_equal(false, a[1].combine)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(2, a.length)
    assert_equal('vm_execute', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].avoid)
    assert_equal(false, a[0].combine)
    assert_equal('vm_next', a[1].op)
    assert_equal(nil, a[1].arg)
    assert_equal(true, a[1].ret)
    assert_equal(false, a[1].combine)
  end

  # execute -> execute
  def test_vmopt_022
    @vc.parse 'code test vm_execute end-code'
    @vc.compile
    seq = GMPForth::VMSeq.new(@vc.latest.param)

    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_execute', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].avoid)
    assert_equal(false, a[0].combine)
    seq.combine_next
    a = []
    seq.each { |op| a << op }
    assert_equal(1, a.length)
    assert_equal('vm_execute', a[0].op)
    assert_equal(nil, a[0].arg)
    assert_equal(false, a[0].ret)
    assert_equal(true, a[0].avoid)
    assert_equal(false, a[0].combine)
  end
 
end
