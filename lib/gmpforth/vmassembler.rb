#
#  vmassembler.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

module GMPForth::VMAssembler

  def initialize(*args)
    @dot = 0
    @label = {}
    @cfa = nil
    @opmap0 = {}
    _k(:OPCODE0).each_with_index { |k,v| @opmap0[k]=v }

  end

  def _k(sym)
    self.class.const_get(sym)
  end

  #
  # Assembler
  #

  # align 'dot', filling unused memory with valid values
  def aligned_dot
    while @dot % @databytes != 0
      asm(:vm_nop)
    end
    @dot
  end

  # assemble the opcode 'op' at 'dot' with the optional argument if op
  # is a symbol or store 'op' in memory as a word at 'dot'. Increment
  # 'dot'.
  def asm(op, arg=nil)
    here = dot
    if op.is_a?(Numeric)
      asm_word(op)
    elsif op == 'CFA:::'
      asm_word(@cfa)
    elsif op.is_a?(String)
      if op =~ /^(@)?(L\d+)$/ || op =~ /^\w+:::$/
        asm_label(op, arg)
      else
        asm_string(op, arg)
      end
    elsif op.is_a?(Array)
      asm_op(*op)
    elsif op.is_a?(GMPForth::WordOffset)
      asm_word(@cfa + @databytes + (op.value * @databytes))
    else
      asm_op(op, arg)
    end
    here
  end

  # store a word at dot
  def asm_word(n)
    store(aligned_dot, n)
    @dot += @databytes
  end

  # store a counted string at dot
  def asm_string(s, arg=nil)
    len = s.length
    # this doesn't catch all cases, just the obvious ones
    limit = arg.nil? ? 256 : (arg == 0 ? 256 : arg)
    raise "string #{s.inspect} too long (#{limit})" if len >= limit
    len |= arg if !arg.nil?
    c_store(@dot, len)
    @dot += 1
    s.each_byte do |c|
      c_store(@dot, c)
      @dot += 1
    end
    while @dot % @databytes != 0
      c_store(@dot, 0)
      @dot += 1
    end
  end

  def asm_byte_op(n)
      c_store(@dot, n)
      @dot += 1
  end

  # assemble an opcode at dot
  def asm_op(op, arg, set_n=false)
    macro = "asm_#{op}".to_sym
    if self.class.method_defined? macro
      return send(macro, arg)
    end
    if arg.nil?
      arg = 0
    elsif arg.is_a?(String)
      label = @label[arg]
      if label.nil?
        # forward reference
        @label[arg] = [@dot]
        log(:asm, "label fw 1 #{arg}")
        arg = 0
      elsif label.is_a?(Array)
        @label[arg] << @dot
        arg = 0
        log(:asm, "label fw 2 #{arg}")
      else
        arg = label
      end
    end

    if op != :vm_push
      # byte op
      n = @opmap0[op]
      raise GMPForth::UnknownOpcodeError, op.inspect if n.nil?
      n |= _k(:OP_R) if arg != 0
      raise "illegal op" if n > 127
    else
      # small push; return if set_n is true
      # numbers out of range will be truncated
      n = arg & _k(:OP_N)
      n |= _k(:OP_R) if set_n
      n |= _k(:OP_T)
      raise "illegal op" if n > 255 || n < 128
    end
    asm_byte_op(n)
  end

  def asm_reg(reg, op)
    asm(:vm_push, _k(reg))
    asm(op)
  end

  def asm_vm_halt(arg)
    asm(:vm_push, _k(:IO_HALT))
    asm(:vm_io)
  end

  def asm_vm_next(arg)
    asm(:vm_nop, 1)
  end

  def asm_vm_push_0(arg)
    asm(:vm_push, 0)
  end

  def asm_vm_push_1(arg)
    asm(:vm_push, 1)
  end

  def asm_vm_push_m1(arg)
    asm(:vm_push, -1)
  end

  # emulate old I opcode
  def asm_vm_i(arg)
    asm(:vm_r_fetch)
  end

  # emulate vm_rp_fetch
  def asm_vm_rp_fetch(arg)
    asm_reg(:REG_RP, :vm_reg_fetch)
  end

  # emulate vm_rp_store
  def asm_vm_rp_store(arg)
    asm_reg(:REG_RP, :vm_reg_store)
  end

  # emulate vm_sp_fetch
  def asm_vm_sp_fetch(arg)
    asm_reg(:REG_SP, :vm_reg_fetch)
  end

  # emulate vm_sp_store
  def asm_vm_sp_store(arg)
    asm_reg(:REG_SP, :vm_reg_store)
  end

  # vm_up_fetch
  def asm_vm_up_fetch(arg)
    asm_reg(:REG_UP, :vm_reg_fetch)
  end

  # vm_up_store
  def asm_vm_up_store(arg)
    asm_reg(:REG_UP, :vm_reg_store)
  end

  # resolve forward references
  def asm_resolve(ref, value)
    old_w = fetch(ref)
    new_w = old_w | value
    store(ref, new_w)
    log(:asm, "resolve #{ref.to_s(16)} #{old_w.to_s(16)} #{new_w.to_s(16)}")
  end

  # manage labels
  def asm_label(label, arg)
    if label =~ /^@(L\d+)/
      # '@' labels are label references and store the value of the
      # label. If the label is not defined yet, then a forward
      # reference is created, which is resolved when the label is
      # instantiated.
      target = $1
      value = @label[target]
      if value.nil?
        # forward reference
        @label[target] = [ @dot ]
        value = 0
      elsif value.is_a?(Array)
        # more forward reference
        @label[target] << @dot
        value = 0
      end
      store(@dot, value)
      @dot += @databytes
      return value
    elsif label =~ /(\w+):::$/
      label = $1
    end
    existing_label = @label[label]
    value = arg || @dot
    log(:asm, "asm_label #{label} #{existing_label.inspect} #{value.to_s(16)}")
    if !existing_label.nil?
      if existing_label.is_a?(Array)
        # this label was a forward reference, so resolve the references
        existing_label.each do |ref|
          asm_resolve(ref, value)
        end
      end
    end
    @label[label] = value
  end

  # compile a simple definition
  def compile(header, interp, *body)
    if !header.nil?
      raise "unsupported"
    end
    @cfa = aligned_dot
    asm(interp || dot + databytes)
    body.each { |param| asm(param) }
    @cfa
  end

  def lookup_label(label)
    @label[label]
  end

end
