#
#  stackrobatic.rb
# 
#  Copyright (c) 2012 by Daniel Kelley
# 
# 

require 'pp'
require 'array/sub'

class Stackrobatic

  TO_R = 0
  R_FROM = 1
  SWAP = 2
  ROT = 3
  DROP = 4
  DUP = 5
  OVER = 6
  R_FETCH = 7

  OPNAME = { 
    TO_R => ">r", 
    R_FROM => "r>",
    SWAP => "swap",
    ROT => "rot",
    DROP => "drop", 
    DUP => "dup", 
    OVER => "over", 
    R_FETCH => "r@",
  }

  NUM_OP = OPNAME.length
  OP_MASK = NUM_OP-1
  OP_BIT = 3

  raise "oops" if NUM_OP != 8

  # sequences that produce the identity transform
  IDENTITY = [
    [ TO_R, R_FROM ],
    [ SWAP, SWAP ],
    [ ROT, ROT, ROT ],
    [ SWAP, ROT, SWAP, ROT ],
    [ ROT, SWAP, ROT, SWAP ],
    [ ROT, SWAP, TO_R, SWAP, R_FROM ],
    [ TO_R, SWAP, R_FROM, ROT, SWAP ],
    [ SWAP, TO_R, SWAP, R_FROM, ROT ],
  ]

  # higher level equivalents
  EQUIV = [
    [ "2swap", OPNAME[ROT], OPNAME[TO_R], OPNAME[ROT], OPNAME[R_FROM], ],
    [ "-rot", OPNAME[ROT], OPNAME[ROT], ],
    [ "2drop", OPNAME[DROP], OPNAME[DROP], ],
    [ "2dup", OPNAME[OVER], OPNAME[OVER], ],
    [ "2over", OPNAME[TO_R], OPNAME[TO_R], OPNAME[OVER], OPNAME[OVER],
               OPNAME[R_FROM], OPNAME[R_FROM], 
               OPNAME[ROT], OPNAME[TO_R], OPNAME[ROT], OPNAME[R_FROM] ],
  ]

  INIT_STACK = [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' ]

  # maximum stack depth of target patterns
  TARGET_LEN = 4

  PREFIX = "  "

  @@target = {}


  def initialize(verbose=false)
    @p=[]
    @r=[]
    @verbose = verbose
    @identity = make_identities
  end

  def make_identities
    IDENTITY.map do |spec|
      a = 0
      spec.each_with_index do |opcode,idx|
        a |= (opcode<<idx*OP_BIT)
      end
      m = (NUM_OP ** spec.length) - 1
      [ a,m,spec.length ]
    end
  end

  def has_identity(opseq, seqlen)
    @identity.each do |iop,mask,len|
      if seqlen >= len && ((opseq&mask) == iop)
        return true
      end
    end
    false
  end

  # for a instruction sequence length 'len', consider 'n'
  # as an integer encoded sequence of operations, each operation
  # encoded as two bits
  def run(n,len)
    @p = INIT_STACK.dup
    @r.clear
    plen_in = @p.length
    raise "oops" if @r.length != 0
    @seq = []
    @syndrome = []
    left = len
    ok = true
    len.times do
      opcode = n & OP_MASK
      @seq << OPNAME[opcode]
      if ok
        if has_identity(n,left)
          @syndrome << "ident"
          ok = false
        else
          ok = execute(opcode)
        end
      end
      left = left-1
      n = n >> OP_BIT
    end
    if ok
      if @r.length != 0
        @syndrome << "rlen(#{@r.length})"
        ok = false
      end
      if @p == INIT_STACK
        @syndrome << "nc"
        ok = false
      end
    end
    raise "ok & has syndrome #{@syndrome}" if ok && @syndrome.length > 0
    raise "!ok and no syndrome" if !ok && @syndrome.length == 0
    ok
  end

  #
  # Execute opcode, returning true if the operation was valid else false
  #
  def execute(opcode)
    case opcode
    when TO_R
      if @p.length > 0
        @r.push(@p.pop)
        true
      else
        @syndrome << "pempty"
        false
      end
    when R_FROM
      if @r.length > 0
        @p.push(@r.pop)
        true
      else
        @syndrome << "rempty"
        false
      end
    when SWAP
      if @p.length > 1
        @p[-2],@p[-1] = @p[-1],@p[-2]
        true
      else
        @syndrome << "p1"
        false
      end
    when ROT
      if @p.length > 2
        # a b c -- b c a
        @p[-3],@p[-2],@p[-1] = @p[-2],@p[-1],@p[-3],
        true
      else
        @syndrome << "p2"
        false
      end
    when DROP
      if @p.length > 0
        @p.pop
        true
      else
        @syndrome << "pempty"
        false
      end
    when DUP
      if @p.length > 0
        @p.push(@p[-1])
        true
      else
        @syndrome << "pempty"
        false
      end
    when OVER
      if @p.length > 1
        @p.push(@p[-2])
        true
      else
        @syndrome << "p1"
        false
      end
    when R_FETCH
      if @r.length > 0
        @p.push(@r[-1])
        true
      else
        @syndrome << "rempty"
        false
      end
    else
      raise "illegal op #{opcode}"
    end
  end

  #
  # Create a string description of a sequence array, substituting
  # high-level equivalents where possible
  #
  def sequence_str(seq_a)
    keep_going = true
    while keep_going
      subst = false
      EQUIV.each do |equiv|
        s = seq_a.gsub!(equiv[1..-1],equiv[0])
        subst = s || subst
      end
      keep_going = subst
    end
    seq_a.join ' '
  end

  #
  # Analyze a sequence of 'n' operations
  #
  def analyze(n)
    limit = NUM_OP**n
    limit.times do |opseq|
      if run(opseq, n)
        seq_str = sequence_str(@seq)
        puts "#{@p} #{seq_str}" if @verbose
        if @@target[@p]
          @@target[@p] << seq_str
        else
          puts "? #{@p.inspect}" if @verbose
        end
      elsif @verbose
        seq_str = sequence_str(@seq)
        syndrome_str = @syndrome.join ','
        puts "#{@p} #{seq_str} rejected #{syndrome_str}"
      end
    end
  end

  class << self

    #
    # Convert a stack pattern into a standard stack comment
    #
    def stack_comment(pattern)
      # find the length of the pattern that has a prefix in INIT_STACK
      start = 0
      INIT_STACK.each_with_index do |o,n|
        if pattern[n] == o
          start += 1
        else
          break
        end
      end
      # find the index of the earliest element used
      # in the the pattern suffix - this may move 'start'
      # lower.
      pattern[start..-1].each do |o|
        idx = INIT_STACK.index(o)
        raise "oops #{o}" if idx.nil?
        start = [start, idx].min
      end
 
      from_a = INIT_STACK[start..-1]
      new_map = INIT_STACK[0..from_a.length-1]
      old_map = from_a.dup
      cmap ={}
      old_map.each_with_index { |o,n| cmap[o] = new_map[n] }
      from_a.each_with_index { |o,n| from_a[n] = new_map[n] }
      from = from_a ? from_a.join(' ') : ''
      to_a = pattern[start..-1]
      to_a.each_with_index { |o,n| to_a[n] = cmap[o] }
      to   = to_a ? to_a.join(' ') : ''
      s = "( #{from} -- #{to} )"
      if @verbose
        s += " \\ #{pattern} #{from_a} #{to_a} #{start}"
      end
      s
    end
  
    def make_target(n)
      plen = INIT_STACK.length - n - 1
      raise "oops" if n < 2
      prefix = INIT_STACK[0..plen]
      # buggy in 1.8.7 p334, works in 1.9
      suffix_a = INIT_STACK[-n..-1]
      # stack permutations
      suffix_a.permutation.each do |suffix|
        @@target[prefix + suffix] = []
      end
      # removal of one to four elements
      d_modidx = (TARGET_LEN...INIT_STACK.length).to_a.reverse
      # copy of one to four elements
      c_modidx = (-TARGET_LEN..-1).to_a
      (1..TARGET_LEN).each do |n|
        d_modidx.combination(n).each do |cidx|
          tstk = INIT_STACK.dup
          cidx.each { |idx| tstk.delete_at(idx) }
          @@target[tstk] = []
        end
        c_modidx.combination(n).each do |cidx|
          tstk = INIT_STACK.dup
          cidx.each { |idx| tstk.push(INIT_STACK[idx]) }
          @@target[tstk] = []
        end
      end
          
    end

    def show
      @@target.each do |pattern,ops|
        puts stack_comment(pattern)
        if pattern == INIT_STACK
          puts "#{PREFIX}identity"
        elsif ops.length == 0
          puts "#{PREFIX}MISSING"
        else
          len = []
          ops.each_with_index { |op,n| len[n] = op.split.length }
          min = len.min
          ops.each_with_index { |op,n| puts "#{PREFIX}#{op}" if len[n] == min}
        end
      end
    end
  end

  (2..4).each { |n| make_target(n) }

end
