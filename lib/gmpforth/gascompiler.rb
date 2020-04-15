#
#  gascompiler.rb
#
#  Copyright (c) 2011 by Daniel Kelley
#
#

require 'gmpforth/constants'
require 'gmpforth/compiler'
require 'gmpforth/vmcompiler'
require 'gmpforth/colon'
require 'gmpforth/vmseq'
require 'mhandle'

class GMPForth::GASCompiler < GMPForth::Compiler

  #
  # Forth word to Assembler symbol conversion
  #
  Graph = {
    '!' => 'store',
    '"' => 'quote',
    '#' => 'number',
    '$' => 'dollar',
    '%' => 'percent',
    '&' => 'and',
    '\'' => 'tick', # ' here to keep fontify happy
    '(' => 'paren',
    ')' => '', # deliberately blank
    '*' => 'star',
    '+' => 'plus',
    ',' => 'comma',
    '-' => 'minus',
    '.' => 'dot',
    '/' => 'slash',
    ':' => 'colon',
    ';' => 'semis',
    '<' => 'less',
    '=' => 'equals',
    '>' => 'greater', # 'to' will clash with the standard word "TO"
    '?' => 'question',
    '@' => 'fetch',
    '[' => 'bracket',
    '\\' => 'backsl',
    ']' => 'bracket', # deliberately the same as [
    '^' => 'hat',
    #  '_' => '', deliberately left out
    '`' => 'backtick',
    '{' => 'brace',
    '|' => 'bar',
    '}' => 'brace', # deliberately the same as {
    '~' => 'tilde',
    '0' => 'zero',
    '1' => 'one',
    '2' => 'two',
    '3' => 'three',
    '4' => 'four',
    '5' => 'five',
    '6' => 'six',
    '7' => 'seven',
    '8' => 'eight',
    '9' => 'nine',
  }

  Word = {
    '[' => 'left_bracket',
    ']' => 'right_bracket',
  }

  Interp = {
    ':' => 'DOCOL',
    'vocabulary' => 'DOVOC',
    'code' => nil,
    'user' => 'DOUSE',
    'constant' => 'DOCON',
    'variable' => 'DOVAR',
    'create' => 'DOCRE',
  }

  DotWord = {
    2 => ".short",
    4 => ".long",
    8 => ".quad",
  }

  Indent = ' '*8

  def initialize(options={})
    @databits = @databytes * 8
    @datamask = (2**@databits) - 1
    @sym = {}
    @vardef = []
    @dotword = DotWord[@databytes]
    @prev_sym = nil
    raise 'oops' if @dotword.nil?
    super
  end

  def code_tokenized
    false
  end

  #
  # Generic GAS compiler implementation
  #

  def asm_symbol(s)
    sa = Word[s]
    return sa if !sa.nil?
    a = ['']
    s.each_char do |c|
      g = Graph[c]
      if g.nil?
        a[-1] << c
      else
        # graph char found
        if g != ''
          if a[-1] == ''
            a[-1] << g
            a << ''
          else
            a << "#{g}"
            a << ''
          end
        end
      end
    end
    if a[-1] == ''
      a.pop
    end
    a.join('_').downcase
  end

  def lookup(name)
    word = @dict[name]
    $stderr.puts("#{name} ?") if @verbose && word.nil?
    word.nil? ? nil : "#{Indent}#{@dotword} #{word.asm_symbol}"
  end

  def body(word, content)
  end

  def compile_oplist(oplist)
    seq = GMPForth::VMSeq.new(oplist)
    seq.combine_next if @optim_combine_next
    seq.each do |op|
      if op.push
        if op.combine
          push(op.arg, true)
        else
          push(op.arg)
        end
      else
        case op.op
        when /:\s*$/
          # don't indent if it looks like a label
          s = op.op
        when /GASCOMPILER:NOINDENT/
          # don't indent if requested not to indent
          s = op.op
        else
          s = "#{Indent}#{op.op}"
        end
        if op.combine
          s << " 1"
        end
        if s =~ /(\w+):::$/
          # comment out funky VM labels
          s = "# #{s}"
        end
        @handle.puts s 
      end
    end
  end

  def compile_code(word)
    compile_oplist(word.param)
    @handle.puts "#{Indent}$ENDCODE"
  end

  #
  # Unhappy. Escaping \ and " isn't sufficient. Escaping all graphic
  # chars is a problem if a graphic char is followed by number, which
  # is then considered as part of the previous hex sequence. So just
  # escape all of them.
  #
  def gas_escape(str)
    str.gsub(/./) { |s| "\\x#{s[0].ord.to_s(16)}"}
  end

  def interpreter_label(word)
    label = Interp[word.name]
    if !label.nil?
      @handle.puts "#{Indent}$MACH_FUNC_MARK " + label
      @handle.puts label + ':'
    else
      # FIXME: a label is only needed if the defining word is actually used
      # in the cross-compiler context, so it is only an error when a defining
      # word is used, not when it is created.

      # raise "no label for #{word.name} in #{self.class}::Interp"
    end
  end

  def compile_colon_op(word, op, param, oplist)
    case op
    when :does_comma
      does_comma

    when :push
      push(param)

    when :lookup
      return lookup(param)

    when :add_defn
      param.each_with_index do |p,idx| 
        cmt = if idx >= word.does || @hosted
          ""
        else
          "# "
        end
        @handle.puts "#{cmt}#{p}"
      end
      return word.asm_symbol

    when :fwdref
      return lookup(param)

    when :does
      param.each { |p| @handle.puts p }

    when :defn
      return lookup(param)

    when :integer
      return "#{Indent}#{@dotword} #{param}"

    when :branch
      return "#{Indent}#{@dotword} #{word.asm_symbol}_#{param}"

    when :string
      str = gas_escape(param)
      
      return <<EOF
        .byte  #{param.length}
        .ascii "#{str}"
        $ALIGN
EOF

    when :assemble
      oplist << param

    when :semi_code
       interpreter_label(word)

    when :label
      return "#{word.asm_symbol}_#{param}:"

    else
      raise "#{op} unsupported"
    end
  end


  def compile_colon(word)
    oplist = []
    cdef = GMPForth::Colon.new(word)
    cdef.compile do |op, param|
      compile_colon_op(word, op, param, oplist)
    end
    if oplist.length > 0
      compile_oplist(oplist)
    end
  end

  def compile_scalar(word)
    word.param.each do |p|
      @handle.puts "#{Indent}#{@dotword} #{p}"
    end
  end

  def compile_variable(word)
    word.param.each do |p|
      vardef = "#{word.asm_symbol}_default"
      @handle.puts "#{Indent}#{@dotword} #{vardef}"
      @vardef << vardef
    end
  end

  def compile_user(word)
    word.param.each do |p|
      @handle.puts "#{Indent}#{@dotword} #{p} * _SZ"
    end
  end

  def compile_vocabulary(word)
    word.param.each_with_index do |p, index|
      case index
      when 0
        @handle.puts "#{Indent}#{@dotword} #{word.asm_symbol}_last"
      when 1
        @handle.puts "#{Indent}#{@dotword} #{p}"
      when 2
        @handle.puts "#{Indent}#{@dotword} #{word.asm_symbol}_nfa"
      else
        raise "needs support"
      end
    end
  end

  alias :compile_constant    :compile_scalar

  def compile_word(word)
    macro = '$' + word.kind.to_s.upcase # ' here to keep fontify happy
    lex(word)
    lexbyte = word.lex + word.name.length
    name = word.name
    ename = gas_escape(name)
    sym = word.asm_symbol
    wstr = "#{Indent}#{macro} #{lexbyte}, \"#{ename}\", #{sym}"
    if !@prev_sym.nil?
      wstr << ", #{@prev_sym}"
    end
    @prev_sym = sym
    @handle.puts ""
    @handle.puts wstr
    send("compile_#{word.kind}", word)
  end

  def lex(word)
      word.set_lex(GMPForth::LEX_IMMEDIATE, GMPForth::LEX_COMPILE_ONLY, GMPForth::LEX_START)
  end


  def assign_asm_symbol(word)
    asym = asm_symbol(word.name)

    # make sure there's no dups from the symbol algorithm
    raise "unexpected duplicate symbol #{asym}" if !@sym[asym].nil?
    @sym[asym] = true

    word.asm_symbol = asym
  end

  #
  # Compiler interfaces
  #

  def cells(n)
    n * @databytes
  end

  # Compiler interface to return an array of single precision numbers
  # corresponding to the given double number.
  def double_number(d)
    [ (d >> @databits), (d & @datamask) ]
  end

  def compile_output(output)
    if output.nil?
      if @bootimage
        tempfile '-prg-'
      else
        $stdout
      end
    else
      File.open(output, 'w')
    end
  end

  def compile(output=nil)
    @handle = MHandle.new(compile_output(output))

    # assign symbols
    @dict_o.each { |word| assign_asm_symbol(word) }

    # generate code
    @dict_o.each do |word|
      if word.done?
        compile_word(word)
      else
          raise "#{word.name} not done"
      end
    end
    @handle.puts ""
    @handle.puts "#{Indent}$ENTRY #{@entry.asm_symbol}, #{@prev_sym}"
    @handle.puts ""
    self
  end

  def image(file)
  end
  
  def target_name
    @submodel.nil? ? @model : "#{@model}/#{@submodel}"
  end

end
