#
#  vm.rb
#
#  Copyright (c) 2010 by Daniel Kelley
#
#  $Id:$
#
# GMP Forth VM
#
# PUSH:   1rvv|vvvv
#            push signed(v)
#
# OP:     0rnn|nnnn
#           nn nnnn see OPCODE
#
#          0 nop
#          1 vm_next

require 'gmpforth/exception'
require 'gmpforth/vmassembler'
require 'gmpforth/console'

class GMPForth::VM

  attr_accessor :dot, :pstack_size, :rstack_size, :mem_size, :mem_ro, :fence
  attr_accessor :u
  attr_reader :addrbytes, :databytes, :addrbits, :databits, :bigendian
  attr_reader :max_uint, :modulus, :state
  attr_reader :pc, :ip, :w
  attr_reader :profile
  attr_reader :sepstack
  attr_reader :console

  include GMPForth::VMAssembler

  OPCODE0 = [
    :vm_nop,
    :vm_reset,
    :vm_store,
    :vm_star,
    :vm_star_slash,     # see #125 for consolidation
    :vm_star_slash_mod,
    :vm_plus,
    :vm_minus,
    :vm_slash,          # see #125 for consolidation
    :vm_slash_mod,
    :vm_n_to_r,         # could use sign to combine w/ n_r_from
    :vm_fetch,
    :vm_and,
    :vm_c_store,
    :vm_c_fetch,
    :vm_depth,
    :vm_drop,
    :vm_dup,
    :vm_execute,
    :vm_unsupported_19, # vm_of
    :vm_j,
    :vm_or,
    :vm_over,
    :vm_n_r_from,
    :vm_r_fetch,
    :vm_rot,
    :vm_swap,
    :vm_uless,
    :vm_um_star,
    :vm_um_slash_mod,
    :vm_xor,
    :vm_plus_loop,
    :vm_question_do,
    :vm_do,
    :vm_docol,
    :vm_does,
    :vm_dovar,
    :vm_dolit,
    :vm_leave,
    :vm_loop,
    :vm_reg_fetch,
    :vm_reg_store,
    :vm_s_quote,
    :vm_unsupported_43, # vm_c_quote
    :vm_unsupported_44, # vm_fp
    :vm_dash_rot,       # see #125 for consolidation
    :vm_pick,
    :vm_roll,
    :vm_io,
    :vm_exit,
    :vm_branch,
    :vm_zero_branch_no_pop, # unused
    :vm_zero_branch,
    :vm_zero_equal,
    :vm_zero_less,
    :vm_less,
    :vm_two_star,
    :vm_two_slash,
    :vm_m_star_slash,
    :vm_d_plus,
    :vm_d_minus,
    :vm_u_two_slash,
    :vm_to_r,
    :vm_r_from,
  ]

  raise "too many type 0 opcodes" if OPCODE0.length > 64

  OPBITS = 8
  OP_T  = 0x80 # Opcode type (0,1)
  OP_R  = 0x40 # Opcode 0:return 1:subtype
  OP_N  = 0x3F # Opcode 0 idx


  DEFAULT_STACK_SIZE = 256
  DEFAULT_MEM_SIZE = 256*1024

  REG_SP=0
  REG_RP=1
  REG_UP=2

  # opcode coverage
  @@opex = {}

  def initialize(dw=4, aw=dw, bigendian=true, sepstack=true)
    # virtual machine
    @sepstack = sepstack
    @mem = []
    @mem_ro = nil # read only region
    @fence = 0    # no-exec fence
    @partial = {}
    @opcache = nil
    @pc = 0     # VM program counter
    @ip = 0     # Interpretive pointer, pointing to colon def PFA
    @w = 0      # Current word pointer, pointing to code word PFA
    @pstack_size = DEFAULT_STACK_SIZE
    @rstack_size = DEFAULT_STACK_SIZE
    @mem_size = DEFAULT_MEM_SIZE
    @addrbytes = aw
    @databytes = dw
    @addrbits = aw*8
    @databits = dw*8
    @bigendian = bigendian
    @opc_idx = 0
    @haslogged = nil
    @u = 0
    # stacks
    if @sepstack
      @pstack = []
      @rstack = []
    else
      @vm.sp_store(@vm.mem_size)
      @vm.rp_store(@vm.mem_size - @vm.pstack_size)
    end

    # limits
    @modulus  = 2**@databits
    @max_uint = @modulus - 1
    @sign_bit = 2**(@databits - 1)

    # logging
    @logitem = { :out => true }
    @stepidx = 0

    # VM state (:idle, :run, :halt)
    @state = :idle

    # profiling
    @profile = {}

    # VM IO

    @console = nil

    # init included modules
    super

  end

  #
  # VM Memory opcodes
  #
  def vm_store               # !
    addr = pop
    value = pop
    store(addr, value)
  end

  def vm_fetch               # @
    set_tos(fetch(tos))
  end

  def vm_c_store             # C!
    addr = pop
    value = pop
    c_store(addr, value)
  end

  def vm_c_fetch             # C@
    set_tos(c_fetch(tos))
  end

  #
  # VM Stack opcodes
  #

  def vm_reg_fetch
    reg = pop
    case reg
    when REG_SP
      push(depth) # (sp@) - seems wrong for mem stack...
    when REG_RP
      push(rdepth) # (rp@)
    when REG_UP
      push(@u) # (up@)
    else
      raise "unsupported #{reg}"
    end
  end

  def vm_reg_store
    reg = pop
    val = pop
    case reg
    when REG_SP
      sp_store(val)
    when REG_RP
      rp_store(val)
    when REG_UP
      @u = val
    else
      raise "unsupported #{reg}"
    end
  end

  def vm_dash_rot            # -ROT
    dash_rot
  end

  def vm_n_to_r              # N>R
    n = pop
    n.times { rpush(pop) }
    rpush(n)
  end

  def vm_to_r                # >R
    rpush(pop)
  end

  def vm_depth               # DEPTH
    push(depth)
  end

  def vm_drop                # DROP
    pop
  end

  def vm_dup                 # DUP
    push(tos)
  end

  def vm_over                # OVER
    push(nos)
  end

  def vm_pick                # PICK
    set_tos(pick(tos+1))
  end

  def vm_n_r_from            # NR>
    n = rpop
    n.times { push(rpop) }
    push(n)
  end

  def vm_r_from                # R>
    push(rpop)
  end

  def vm_r_fetch             # R@
    push(rtos)
  end

  def vm_roll                # ROLL
    roll(signed(pop))
  end

  def vm_rot                 # ROT
    rot
  end

  def vm_swap                # SWAP
    swap
  end

  #
  # VM Control opcodes
  #

  # no operation
  def vm_nop
  end

  def vm_reset
    @dot = 0
    @state = :idle
    if @sepstack
      @pstack.clear
      @rstack.clear
    end
    @partial.clear
    jmp(@dot)
  end

  def vm_halt
    @state = :halt
    throw @state
  end

  def vm_trap
    raise "trap"
  end

  def vm_docol               # (docol)
    rpush(@ip)
    @ip = @w
  end

  def vm_exit                # EXIT
    #
    # Typically, VM will be booted with vm_docol as the first interpreter
    # so the initial rdepth starts off at 1, not 0, because of the rpush
    # in vm_docol.
    #
    if rdepth > 1
      @ip = rpop
    else
      vm_halt
    end
  end

  def vm_execute             # EXECUTE
    xfer_w(pop)
  end

  def vm_zero_branch         # (0branch)
    ba = fetch(@ip)
    if pop == 0
      @ip = ba
    else
      next_ip
    end
  end

  def vm_zero_branch_no_pop  # (0branch-no-pop)
    ba = fetch(@ip)
    if tos == 0
      @ip = ba
    else
      next_ip
    end
  end

  def vm_branch              # (branch)
    @ip = fetch(@ip)
  end

  def vm_j                   # J
    push(rpick(3))
  end

  #
  # Both (do) and (?do) require the loop destination to be compiled
  # afterwards so (leave) can know where to branch to. (?do) needs
  # this anyway, so this approach makes both (do) and (?do) compile
  # uniformly. I don't recall if this corresponds to 'standard
  # practice' or not. Well, it remains to be seen how this will work
  # anyway.
  #

  def vm_do                  # (do)
    rpush(@ip)
    next_ip
    start = pop # start
    rpush(pop) # limit
    rpush(start)
  end

  def vm_question_do         # (?do)
    dest  = @ip
    next_ip
    start = pop
    limit = pop
    if start == limit
      @ip = fetch(dest) # branch
    else
      rpush(dest)
      rpush(limit)
      rpush(start)
    end
  end

  def vm_leave               # (leave)
    rpop # index
    rpop # limit
    @ip = fetch(rpop) # branch to end of loop
  end

  def unloop
    rpop # limit
    rpop # start
    rpop # dest
  end

  def vm_loop                # (loop)
    set_rtos(rtos + 1)
    if rnos != rtos
      @ip = fetch(@ip) # branch back
    else
      unloop
      next_ip
    end      
  end

  def vm_plus_loop           # (+loop)
    incr = signed(pop)
    idx = signed(rtos)
    idxp = signed(idx + incr)
    lim = signed(rnos)
    log(:loop, "+loop: limit=#{rnos} idx:#{rtos}+#{incr}=#{idxp}")

    # From Forth-2012:
    #
    #   "Add n to the loop index. If the loop index did not cross the
    #   boundary between the loop limit minus one and the loop limit,
    #   continue execution at the beginning of the loop."
    #
    # incr<0 ?  idxp-lim u>= idx-lim :  idxp-lim u< idx-lim
    #
    terminate = unsigned(idxp-lim) < unsigned(idx-lim)
    terminate = !terminate if incr < 0
    if (terminate)
      unloop
      next_ip
    else
      set_rtos(idxp)
      @ip = fetch(@ip) # branch back
    end
  end

  def vm_does               # (does)
    rpush(@ip)
    @ip = word_aligned?(@pc) ? @pc+@databytes : word_align(@pc)
    push(w)
  end

  def vm_dovar              # (dovar)
    push(w)
  end

  def vm_dolit               # (dolit)
    push(fetch(@ip))
    next_ip
  end

  def vm_s_quote             # (s")
    push(@ip + 1)
    count = c_fetch(@ip)
    push(count)
    @ip = word_align(@ip + count + 1)
  end

  #
  # VM Math opcodes
  #
  def vm_plus                # +
    n = signed(pop)
    set_tos(integer(signed(tos) + n))
  end

  def vm_minus               # -
    n = signed(pop)
    set_tos(tos - n)
  end

  def vm_and                 # AND
    n = pop
    set_tos(tos & n)
  end

  def vm_or                  # OR
    n = pop
    set_tos(tos | n)
  end

  def vm_xor                 # XOR
    n = pop
    set_tos(tos ^ n)
  end

  def vm_uless               # U<
    u2 = unsigned(pop)
    u1 = unsigned(tos)
    set_tos(boolean(u1 < u2))
  end

  def vm_star                # *
    n = signed(pop)
    set_tos(signed(tos) * n)
  end

  def vm_star_slash          # */
    c = signed(pop)
    b = signed(pop)
    a = signed(tos)
    set_tos((a*b)/c)
  end

  def vm_star_slash_mod      # */MOD
    c = signed(pop)
    b = signed(tos)
    a = signed(nos)
    q = (a*b)/c
    r = (a*b)%c
    set_nos(r)
    set_tos(q)
  end

  def vm_slash               # /
    n = signed(pop)
    set_tos(integer(signed(tos) / n))
  end

  def vm_slash_mod           # /MOD
    b = signed(tos)
    a = signed(nos)
    q = a/b
    r = a%b
    set_nos(r)
    set_tos(q)
  end

  def vm_um_star             # UM*
    b = unsigned(tos)
    a = unsigned(nos)
    u = a * b
    set_nos(u)
    set_tos(hi(u))
  end

  def vm_um_slash_mod        # UM/MOD
    u1 = unsigned(pop)
    ud = udouble(nos, tos)
    set_nos(integer(ud % u1))
    set_tos(integer(ud / u1))
  end

  def vm_zero_equal         # 0=
    set_tos(boolean(signed(tos) == 0))
  end

  def vm_zero_less          # 0<
    set_tos(boolean(signed(tos) < 0))
  end

  def vm_less              # <
    u1 = signed(pop)
    set_tos(boolean(signed(tos) < u1))
  end

  def vm_two_star          # 2*
    set_tos(tos << 1)
  end

  def vm_two_slash         # 2/
    n = tos >> 1
    n |= (tos & @sign_bit)
    set_tos(n)
  end

  def vm_u_two_slash         # u2/
    set_tos(tos >> 1)
  end

  def vm_d_plus            # D+
    hi = pop
    lo = pop
    a = udouble(lo, hi)
    n = udouble(nos, tos)
    n += a
    set_tos(hi(n))
    set_nos(n)
  end

  def vm_d_minus           # D-
    hi = pop
    lo = pop
    a = udouble(lo, hi)
    n = udouble(nos, tos)
    n -= a
    set_tos(hi(n))
    set_nos(n)
  end

  def vm_m_star_slash      # M*/
    d = signed(pop)
    m = signed(pop)
    n = udouble(nos,tos)
    n *= m
    n /= d
    set_tos(hi(n))
    set_nos(n)
  end



  #
  # VM IO opcodes
  #

  def vm_io
    attach_console
    case signed(tos)
    when IO_TX_STORE
      # (tx!)
      pop # opcode
      @console.emit(pop)
    when IO_TX_QUESTION
      # (tx?)
      set_tos(boolean(@console.emit?))
    when IO_RX_FETCH
      # (rx@)
      set_tos(@console.key)
    when IO_RX_QUESTION
      # (rx?)
      set_tos(boolean(@console.key?))
    when IO_MEM_LIMIT
      # unused
      set_tos(@mem_size)
    else
      pop
      vm_halt
    end
  end

  #
  # VM internal
  #

  # return the byte at idx from value
  def byte_at(value, idx)
    (value >> ((@bigendian ? @databytes - idx - 1 : idx)*8)) & 0xff
  end

  # start execution at given CFA
  def boot(cfa)
    @state = :run
    push(cfa)
    @ip = cfa
    next_ip
    exec(:vm_execute)
  end

  # execute the given opcode
  def exec(opcode, r=false)
    @@opex[opcode] = ((@@opex[opcode] || 0) + 1)
    send(opcode)
  end

  # Set the program counter to the given code location
  def jmp(loc)
    raise "#{loc} is below write fence" if loc < @fence
    @pc = loc
    @opcache = nil
    log(:opcache, "opcache cleared because of jmp to #{loc.to_s(16)}")
  end

  def where(opcode, ret=false)
    if logging?(:exec)
      s = ''
      
      if opcode.to_s =~ /^vm_(.*)/
        op = $1
      else
        op = opcode
      end
      op += "*" if ret
      if @stepidx == 0
        s += "idx    pc   ip   w    rp@ op             stack\r\n"
        s += "------ ---- ---- ---- --- -------------- ---------------\r\n"
      end
      s += "%6d "  % @stepidx
      s += "%04x " % @pc
      s += "%04x " % @ip
      s += "%04x " % @w
      s += "%3d "  % rdepth
      s += "%-14s " % op
      s += "[#{depth}]"
      (depth-1).downto(0) do |n|
        s += ' '
        s += pick(n).to_s(16)
      end
      s += "\r"
      log(:exec, s)
      @stepidx += 1
    end
  end

  # step one instruction
  def step
    opcode = nil
    s = [ @pc, @opc_idx ]
    if @opcache.nil?
      @opcache = fetch(@pc)
      @opc_idx = 0
    end
    op = byte_at(@opcache, @opc_idx)
    log(:opcache, "op=#{op} opcache=#{@opcache.to_s(16)} opc_idx=#{@opc_idx}")
    n = (op & OP_N)
    r = (op & OP_R) != 0
    if (op & OP_T) != 0
      # small push
      opcode = :vm_push
      data = small(n)
      if block_given?
        yield opcode,data,false
      else
        where("push(#{'%08x' % data})")
      end
      push(data)
    else
      opcode = OPCODE0[n]
      if block_given?
        yield opcode,nil,r 
      else
        where(opcode,r)
      end
      exec(opcode, r)
    end
    if r
      xfer_w(fetch(@ip))
      next_ip
    end
    next_op
    log(:opcache, "pc:#{s[0]}->#{@pc} opc_idx:#{s[1]}->#{@opc_idx}")
    opcode
  end

  def small(n)
    signed(n, 6)
  end

  def next_op
    # yuk. only incr PC if a jmp did not occur. jmp
    # clears opcache, so that will be used to indicate
    # a jmp happened. I don't like this - needs to be cleaned up.
    if !@opcache.nil?
      @pc += 1
      @opc_idx += 1
      if @opc_idx >= @databytes
        @opcache = nil
        log(:opcache, "opcache cleared because of opidx=#{@opc_idx}")
      end
    end
  end
  
  def xfer_w(cfa)
    @w = cfa
    @profile[cfa] = @profile[cfa].nil? ? 1 : @profile[cfa] + 1
    jmp(fetch(@w))
    @w += @databytes
  end

  # increment IP
  def next_ip
    @ip += @databytes
  end

  # raise an UnimplementedError exception
  def unimplemented
    raise GMPForth::UnimplementedError
  end

  # set SP0
  def sp_store(n)
    if @sepstack
      # n is desired depth
      while n < depth
        @pstack.pop
      end
      while n > depth
        @pstack.push(0)
      end
    else
      @sp0 = @sp = aligned_word_addr(n) + 1
    end
  end

  # set RP0
  def rp_store(n)
    if @sepstack
      # n is desired depth
      while n < rdepth
        @rstack.pop
      end
      while n > rdepth
        @rstack.push(0)
      end
    else
      @rp0 = @rp = aligned_word_addr(n) + 1
    end
  end

  # return the depth of the parameter stack
  def depth
    @sepstack ? @pstack.length : @sp - @sp0
  end

  def byteswap(value)
    if value.nil?
      value
    elsif @databytes == 2
      b0 = value & 0xff
      b1 = (value >> 8) & 0xff
      ((b0 << 8) | (b1))
    elsif @databytes == 4
      b0 = value & 0xff
      b1 = (value >> 8) & 0xff
      b2 = (value >> 16) & 0xff
      b3 = (value >> 24) & 0xff
      ((b0 << 24) | (b1 << 16) | (b2 << 8) | (b3))
    elsif @databytes == 8
      b0 = value & 0xff
      b1 = (value >> 8) & 0xff
      b2 = (value >> 16) & 0xff
      b3 = (value >> 24) & 0xff
      b4 = (value >> 32) & 0xff
      b5 = (value >> 40) & 0xff
      b6 = (value >> 48) & 0xff
      b7 = (value >> 56) & 0xff
      ((b0 << 56) | (b1 << 48) | (b2 << 40) | (b3 << 32) |
       (b4 << 24) | (b5 << 16) | (b6 <<  8) | (b7))
    elsif
      raise "unsupported"
    end
  end

  def mem_store(addr, value)
    if !@mem_ro.nil?
      raise "readonly mem #{addr.to_s(16)}" if @mem_ro.member?(addr)
    end
    v = @bigendian ? value : byteswap(value)
    log(:mem, "W mem[#{addr.to_s(16)}]=#{v.to_s(16)} (#{value.to_s(16)})")
    @mem[addr] = v
  end

  def mem_fetch(addr)
    value = @mem[addr]
    v = @bigendian ? value : byteswap(value)
    if v.nil?
      log(:mem, "R mem[#{addr.to_s(16)}]=--")
    else
      log(:mem, "R mem[#{addr.to_s(16)}]=#{v.to_s(16)} (#{value.to_s(16)})")
    end
    v
  end
  
  # set the top of the parameter stack to the given value
  def set_tos(value)
    u = unsigned(value)
    if @sepstack
      @pstack[-1] = u
    else
      mem_store(@sp, u)
    end
  end

  # set the 'next on stack' word (just under top) to the given value
  def set_nos(value)
    u = unsigned(value)
    if @sepstack
      @pstack[-2] = u
    else
      mem_store(@sp+1, u)
    end
  end

  # put the Nth (0-based) word of the parameter stack on the top
  def pick(n)
    raise GMPForth::StackShallowError if depth <= n
    @sepstack ? @pstack[-1 - n] : mem_fetch(@sp + n)
  end

  # rotate the top N+1 words on the parameter stack
  # reverse rotation if N is negative
  def roll(n)
    raise GMPForth::StackShallowError if depth <= n.abs
    if @sepstack
      if n > 0
        tmp = pick(n)
        n.downto(1) do |nn| 
          to = -nn - 1
          from = -nn
          v = @pstack[from]
          @pstack[to] = v
        end
        set_tos(tmp)
      elsif n < 0
        n = -n
        tmp = tos
        n.times do |nn| 
          to = -(nn+1)
          from = -(nn+2)
          v = @pstack[from]
          @pstack[to] = v
        end
        to = -(n+1)
        @pstack[to] = tmp
      end
    else
      unimplemented
    end
  end

  # rotate the top three words
  # FIXME - define in terms of 'roll'
  def rot
    raise GMPForth::StackShallowError if depth < 3
    if @sepstack
      @pstack[-3],@pstack[-2],@pstack[-1] = 
        @pstack[-2],@pstack[-1],@pstack[-3] 
    else
      unimplemented
    end
  end

  # reverse rotate the top three words
  # FIXME - define in terms of 'roll'
  def dash_rot
    raise GMPForth::StackShallowError if depth < 3
    if @sepstack
      @pstack[-3],@pstack[-2],@pstack[-1] = 
        @pstack[-1],@pstack[-3],@pstack[-2] 
    else
      unimplemented
    end
  end

  # swap the top two words
  # FIXME - define in terms of 'roll'
  def swap
    raise GMPForth::StackShallowError if depth < 2
    if @sepstack
      @pstack[-2],@pstack[-1] = @pstack[-1],@pstack[-2] 
    else
      unimplemented
    end
  end

  # return the top word of the parameter stack
  def tos
    raise GMPForth::StackEmptyError if depth < 1
    pick(0)
  end

  # return the next word of the parameter stack
  def nos
    pick(1)
  end

  # push 'n' on to the parameter stack
  def push(n)
    raise GMPForth::StackFullError if depth >= @pstack_size
    u = unsigned(n)
    if @sepstack
      @pstack.push(u)
    else
      @sp += 1
      mem_store(@sp, u)
    end
  end

  # pop the top word of the parameter stack and return it
  def pop
    raise GMPForth::StackEmptyError if depth < 1
    if @sepstack
      v = @pstack.pop
    else
      v = tos
      @sp -= 1
    end
    v
  end

  # return the depth of the return stack
  def rdepth
    @sepstack ? @rstack.length : @rp - @rp0
  end

  # put the Nth (0-based) word of the return stack on the top
  def rpick(n)
    @sepstack ? @rstack[-1 - n] : mem_fetch(@sp + (n*@databytes))
  end

  # return the top word of the return stack
  def rtos
    raise GMPForth::StackEmptyError if rdepth < 1
    rpick(0)
  end

  # return the next word of the return stack
  def rnos
    raise GMPForth::StackShallowError if rdepth < 2
    rpick(1)
  end

  # push 'n' on to the return stack
  def rpush(n)
    u = unsigned(n)
    raise GMPForth::StackFullError if rdepth >= @rstack_size
    if @sepstack
      @rstack.push(u)
    else
      @rp += 1
      mem_store(@rp, u)
    end
  end

  # pop the top word of the return stack and return it
  def rpop
    raise GMPForth::StackEmptyError if rdepth < 1
    if @sepstack
      v = @rstack.pop
    else
      v = rtos
      @rp -= 1
    end
    v
  end

  # set the top of the return stack to the given value
  def set_rtos(value)
    u = unsigned(value)
    if @sepstack
      @rstack[-1] = u
    else
      mem_store(@rp, u)
    end
  end

  # set the 'next on return stack' word
  def set_rnos(value)
    u = unsigned(value)
    if @sepstack
      @rstack[-2] = u
    else
      mem_store(@rp+1, u)
    end
  end

  # return the 2's complement signed form of the unsigned integer 'n'
  def signed(n, width=@databits)
    i = integer(n)
    n[width-1] != 0 ? -((1<<width) - i) : i;
  end

  # return an integer truncated to the integer represention of the VM
  def integer(n)
    n & @max_uint
  end

  # return the unsigned form of the 2's complement signed integer 'n'
  alias unsigned integer

  # return the high part of a double integer
  def hi(n)
    n >> @databits
  end

  # return an unsigned double integer
  def udouble(low, high)
    low | (high << @databits)
  end

  # return a standard FORTH boolean value for n
  def boolean(n)
    b = n.is_a?(Numeric) ? n != 0 : n
    b ? @max_uint : 0
  end

  # return the memory word address corresponding to the given byte address
  def word_addr(byte_addr)
    w = byte_addr/@databytes
    if w < 0 || w >= @mem_size
      raise GMPForth::MemoryBoundsError
    end
    w
  end

  # return the word aligned byte address greater than the byte address
  # if the byte address is not aligned, or corresponding to the byte
  # address if it is aligned.
  def word_align(byte_addr)
    m = byte_addr % @databytes
    m == 0 ? byte_addr : byte_addr + (@databytes - m)
  end

  # return the word based byte mask corresponding to the given byte address
  def byte_mask(addr)
    b = @bigendian ? @databytes - addr%@databytes : addr%@databytes
    0xff << b*8
  end

  # return true if the given byte address is word aligned
  def word_aligned?(addr)
    (addr % @databytes) == 0
  end

  # return a word address corresponding to the given byte address if the
  # address is aligned, otherwaise raise an exception
  def aligned_word_addr(addr)
    if !word_aligned?(addr)
      log(:verbose, "Unaligned #{addr.to_s(16)}")
      raise GMPForth::MemoryAlignmentError 
    end
    word_addr(addr)
  end

  # return a word aligned byte address less than or equal to addr
  def aligned_byte_addr(addr)
    word_addr(addr) * @databytes
  end

  # return the data word at the given aligned byte address
  def fetch(addr)
    w = aligned_word_addr(addr)
    v = mem_fetch(w)
    raise GMPForth::MemoryUninitializedError if v.nil?
    v
  end

  # store a data word at the given aligned byte address
  def store(addr, value)
    raise "not Numeric" if !value.is_a?(Numeric)
    w = aligned_word_addr(addr)
    @partial.delete(w)
    mem_store(w, value)
  end

  # return a byte at the given byte address
  # will raise an exception if the byte is uninitialized
  def c_fetch(byte_addr)
    w = word_addr(byte_addr)
    v = mem_fetch(w)
    p = @partial[w]
    m = byte_addr % @databytes
    if !p.nil?
      v = p[m]
      raise GMPForth::MemoryUninitializedError if v.nil?
    else
      raise GMPForth::MemoryUninitializedError if v.nil?
      if @bigendian
        s = @databits - (m+1)*8
      else
        s = m*8
      end
      v = (v >> s) & 0xff
    end
    v
  end

  def c_form(byte, word, lane)
    if @bigendian
      s = @databits - (lane+1)*8
    else
      s = lane*8
    end
    hole =  @max_uint ^ (0xff<<s)
    word &= hole
    word |= byte<<s
  end

  # store a byte at the given byte address
  def c_store(byte_addr, value)
    raise "type mismatch" if value.kind_of?(String)
    raise "too small" if value < 0
    raise "too big" if value > 255
    w = word_addr(byte_addr)
    v = mem_fetch(w)
    m = byte_addr % @databytes
    p = @partial[w]
    if v.nil?
      # never been fully stored into
      if p.nil?
        # no partial entry, so create one
        @partial[w] = {}
        p = @partial[w]
      end
      p[m] = value

      # check that all byte lanes are full
      if p.length == @databytes
        # transfer partial data to main memory
        q = 0
        @databytes.times do |lane|
          q = c_form(p[lane], q, lane)
        end
        mem_store(w, q)
        @partial.delete(w)
      end
    else
      mem_store(w, c_form(value, v, m))
    end
    value
  end

  # return a counted string from byte_addr
  def s_fetch(byte_addr)
    s = ''
    len = c_fetch(byte_addr)
    len.times do
      byte_addr += 1
      s << c_fetch(byte_addr).chr
    end
    s
  end

  #
  # Debug
  #

  # print the parameter stack
  def dot_s(base=10)
    s = ''
    (depth-1).downto(0) { |n| s << "#{pick(n).to_s(base)} " }
    log(:out, "\n( -- #{s})")
  end

  # disassemble the code at addr
  def disassemble_at(addr)
    len = -1
    s = "%08x " % addr 
    begin
      op = c_fetch(addr)
      s << "%02x " % op
      n = op & OP_N
      if (op & OP_T) != 0
        # small push
        s << "         vm_push #{small(op)}"
        len = 1
      else
        opcode = OPCODE0[n]
        spacer = ' ' * (@databytes - 1)*3
        s << "#{spacer}#{opcode} "
        if (op & OP_R) != 0
          s << "[exit]"
        end
        len = 1
      end
    rescue
      s << '--' # + $!
    end
    log(:out, s)
    len
  end

  # disassemble memory in the given range
  def disassemble(from=0, to=@dot)
    if from.is_a?(Range)
      to   = from.end
      from = from.begin
    end
    while from <= to
      n = disassemble_at(from)
      if n > 0
        from += n
      else
        break
      end
    end
  end

  def dump_partial_word(addr, verilog)
    pw = []
    @databytes.times do |n|
      begin
        v = c_fetch(addr+n)
        sv = "%02x" % v
        pw << sv
      rescue GMPForth::MemoryUninitializedError
        if verilog
          pw << 'xx'
        else
          pw << '--'
        end
      end
    end
    pw.reverse! if !@bigendian
    pw.join
  end

  # dump memory in the given range
  def dump(from=0, to=@dot, verilog=false)
    if from.is_a?(Range)
      to   = from.end
      from = from.begin
    end
    from = aligned_byte_addr(from)
    to   = aligned_byte_addr(to)

    # 16 is a magic number to give a power of two number of words
    # that will still fit on an 80 column screen with a leading address
    wpl = 16 / @databytes
    afmt = "%0#{@addrbytes*2}x"
    afmt << ' :' if !verilog
    while from < to
      s = ''
      if verilog
        s << '@'
        s << afmt % (from/@databytes)
      else
        s << afmt % from
      end
      wpl.times do
        s << ' '
        s << dump_partial_word(from, verilog)
        from += @databytes
      end
      if block_given?
        yield s
      else
        log(:out, s)
      end
    end
  end

  # logging
  def logging?(item)
    !@logitem[item].nil?
  end

  def log(item, s)
    if logging?(item)
      # if there has been no log output yet, then start with a newline
      # this helps log output look when with test
      if @haslogged.nil?
        @haslogged = true
        $stderr.puts
      end
      $stderr.puts s
    end
  end

  def display(*items)
    items.each { |item| @logitem[item] = true }
  end

  def undisplay(*items)
    items.each { |item| @logitem.delete(item) }
  end

  def attach_console
    if @console.nil?
      @console = Console.new
    end
  end

  def redirect(inp,out)
    attach_console
    @console.redirect(inp,out)
  end

  class << self
    # opcode coverage
    def opcode_coverage
      missing = []
      OPCODE0.each { |op| missing << op.to_s if @@opex[op].nil? }
      if missing.length > 0
        $stderr.puts('Unexecuted opcodes')
        missing.sort.each do |op|
          $stderr.puts(op)
        end
      end
    end

    def gas_macros
      OPCODE0.each_with_index do |op,idx|
        puts <<EOF
        .macro #{op} nxt=0
        vm_op #{idx} \\nxt
        .endm

EOF
      end
    end

    # new with options hash
    def opt_new(options)
      dw = options[:dw] || 4
      be = options.key?(:be) ? options[:be] : true
      GMPForth::VM.new(dw,dw,be)
    end

    # load IO constants if needed
    def const_missing(name)
      if name =~ /^IO_/
        require 'gmpforth/ioconstants'
        include GMPForth::IOCONSTANTS
        const_get(name)
      else
        raise name
      end
    end

  end

end

