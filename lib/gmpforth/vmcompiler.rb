#
#  vmcompiler.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# 

require 'gmpforth/constants'
require 'gmpforth/compiler'
require 'gmpforth/vm'
require 'gmpforth/vmseq'
require 'pp'

class GMPForth::VMCompiler < GMPForth::Compiler

  DEFAULT_RUN_LIMIT = 1000

  # Dictionary header-start, immediate and compile-only
  SFLAG = GMPForth::LEX_START
  IFLAG = GMPForth::LEX_IMMEDIATE
  CFLAG = GMPForth::LEX_COMPILE_ONLY

  # User area size in words
  USIZE = 64

  # TIB size in words
  TIBSIZE = 64

  # SCRATCH size in words
  SCRATCHSIZE = 64

  # Step run limit
  attr_accessor :run_limit

  attr_accessor :w_width

  # Access the VM
  attr_reader :vm

  # Dictionary
  attr_reader :latest, :link

  # coverage
  @@coverage = {}

  def initialize(options={})
    @vm = GMPForth::VM.opt_new(options)
    # forward references
    @fwd = {}
    @label_id = 1
    # definitions
    @defn = {}
    @cfa  = {}
    @run_limit = DEFAULT_RUN_LIMIT
    @interp = {}
    @interp_label = {}
    @user = false
    @latest = nil
    @link = 0
    @w_width = 31
    super
  end

  def code_tokenized
    true
  end

  def display(*flags)
    @vm.display(*flags)
  end

  def scan(*files)
    @vm.display(:verbose) if @verbose
    super(*files)
    self
  end

  def compile(output=nil)
    # compile dict to VM
    @defn_map = nil

    # Reserve space for boot image entry and user area
    # even if no boot image is requested so trace output
    # is comparable.
    n = 2 * @vm.databytes
    n.times { @vm.asm(:vm_nop) }
    @dict_o.each do |entry| 
      if entry.done?
        begin
          compile_word(entry)
        rescue => detail
          where = detail.backtrace.join("\n")
          $stderr.puts "error compiling '#{entry.name}'\n#{where}"
          pp(entry)
          raise
        end
      else
        raise "#{entry.name} not done"
      end
    end
    check_unresolved
    if !output.nil?
      image(output)
    end
    self
  end

  def check_unresolved
    # error if there are any remaining forward references
    if @fwd.length != 0
      fwd = @fwd.keys.join ' '
      raise "unresolved forward references: #{fwd}"
    end
    fwd = []
    udf = []
    @interp.each do |name, handler|
      if handler.nil?
        udf << name
      elsif !handler.is_a?(Integer) && handler =~ /^@/
        fwd << name
      end
    end
    if fwd.length != 0 || udf.length != 0
      s = "unresolved code interpreters: "
      if fwd.length != 0
        s += 'fwd: '
        s += fwd.join(' ')
      end
      if udf.length != 0
        s += 'udf: '
        s += udf.join(' ')
      end
      raise s
    end
    super
  end

  def compile_word(word)
    @vm.log(:verbose, "Compile #{word.name}")
    prev = @defn[word.name]
    if !prev.nil?
      prevw = @dict[word.name]
      if prevw.nil?
        pp(@defn)
        pp(@dict)
      end
      raise "#{word.name} #{word.loc} redefines #{prevw.loc}" 
    end

    # compile header before resolving forward reference
    if !@headless
      link = @link
      word.set_lex(IFLAG, CFLAG, SFLAG)
      @link = @vm.aligned_dot
      word.link = @link
      @vm.asm(link)                  # link
      @vm.asm(word.name, word.lex)   # name
    end

    # align dot and resolve forward references
    @vm.aligned_dot
    resolve_fwdref(word.name)

    case word.kind
    when :colon
      compile_colon(word)
    when :code
      compile_code(word)
    when :vocabulary
      compile_vocabulary(word)
    when :user
      compile_user(word)
    when :constant
      compile_scalar(word)
    when :variable
      compile_scalar(word)
    else
      pp(word)
      raise "compiling unsupported for #{word.kind}"
    end
  end

  def gensym
    label = "L%05d" % @label_id
    @label_id += 1
    label
  end

  def add_defn(word, code, body)
    @latest = word
    production = @vm.compile(nil, code, *body)
    @defn[word.name] = production
    @cfa[production] = word.name
    production
  end

  #
  # Code interpreters are initially created as a forward reference
  # and then resolved when ';code' is executed by the defining word
  #
  def get_interpreter(name, required=false)
    interp = @interp[name.to_s]
    if interp.nil?
      if required
        raise "#{name} interpreter not defined"
      end
      # create forward reference to requested interpreter
      @interp_label[name] = gensym
      interp = "@" + @interp_label[name]
      @interp[name.to_s] = interp
      @vm.log(:verbose, "Code interpreter for #{name} created #{interp}")
    end
    interp
  end

  def resolve_interpreter(word)
    if !@interp[word.name.to_s].nil?
      # resolve forward reference
      label = @interp_label[word.name]
      @vm.asm(label) if !label.nil?
    end
    # get address and save
    @interp[word.name.to_s] = @vm.dot
    ha = @vm.dot.to_s(16)
    @vm.log(:verbose, "Code interpreter for #{word.name} defined #{ha}")
  end

  def fwdref?(name)
    !@fwd[name].nil?
  end

  def fwdref(name)
    ref = @fwd[name]
    if ref.nil?
      # new forward reference
      ref = gensym
      @fwd[name] = ref
    end
    ref
  end

  def fwdsym(name)
    "@" + fwdref(name)
  end
  
  def resolve_fwdref(name)
    fwd = @fwd[name]
    if !fwd.nil?
      # resolve forward reference
      @vm.asm(fwd)
      @fwd.delete(name)
    end
  end

  def lookup(name)
    @defn[name] || fwdsym(name)
  end

  def compile_colon(word)
    interp = get_interpreter(':')
    body = []
    compile_str = false
    definer = false
    start_addr = nil
    end_addr = nil
    prev_p = nil
    word.param.each do |p|
      defn = @defn[p]
      if definer == :semi_code
        if p == '(dolit)'
          # skip
        elsif p == '(does,)'
          @vm.asm(:vm_does, 1)
          @vm.aligned_dot
          # continue with compiling colon-def
          definer = :does
          body = []
        elsif defn.nil?
          if p.kind_of?(Numeric)
            # in code, if it looks like a number, push it
            @vm.asm(:vm_push, p)
          elsif p =~ /:::$/
            # an asm label
            @vm.asm(p)
          else
            @vm.asm(p.to_sym)
          end
        else
          raise "unsupported"
        end
      elsif p == '<<dummy>>'
        # string cell padding - ignore
      elsif p == '(;code)' && prev_p != '(dolit)'
        raise 'already a defining word' if definer != false
        definer = :semi_code
        body << lookup(p)
        start_addr = add_defn(word, interp, body)
        # resolve forward references to interpreter
        resolve_interpreter(word)
      elsif p == '(s")' && prev_p != '(dolit)'
        body << lookup(p)
        compile_str = true
      elsif !defn.nil? && !compile_str
        body << defn
      elsif p == word.name && !compile_str # recurse
        body << 'CFA:::'
      elsif p.is_a?(Integer) || p.is_a?(GMPForth::WordOffset)
        body << p
      elsif p =~ /^\$(\w+)\$$/
        val = @vm.lookup_label($1)
        body << val
      elsif p.is_a?(String)
        if compile_str
          body << p # VM assembler handles directly
          compile_str = false
        else
          # forward reference
          body << fwdsym(p)
        end
      else
        pp(word)
        raise "Unsupported word type #{p.class} in #{p.inspect}"
      end

      prev_p = p
    end

    case definer
    when false
      start_addr = add_defn(word, interp, body)
    when :does
      body.each { |p| vm.asm(p) }
    end
    end_addr = @vm.dot
    start_addr += @vm.databytes
    end_addr -= 1
    word.set_region(start_addr, end_addr)
  end

  def compile_code(word)
    body = []
    seq = GMPForth::VMSeq.new(word.param)
    seq.combine_next if @optim_combine_next
    seq.each do |op|
      if op.push
        a = [ op.op.to_sym, op.arg ]
        a << 1 if op.combine
        body << a
      else
        if op.combine
          body << [ op.op.to_sym, 1 ]
        else
          body << op.op.to_sym
        end
      end
    end
    start_addr = add_defn(word, nil, body)
    end_addr = @vm.dot
    start_addr += @vm.databytes
    end_addr -= 1
    word.set_region(start_addr, end_addr)
  end
  
  def compile_scalar(word)
    word.param.each_with_index do |w,i|
      if w.is_a?(String) && w =~ /^(\w+)_pfa$/
        pword = $1
        # special word body lookup
        cfa = lookup(pword)
        raise "oops: #{pword} not defined" if cfa.nil?
        word.param[i] = cfa + cells(1) # >body
      end
    end
    add_defn(word, get_interpreter(word.kind), word.param)
  end
  
  def compile_user(word)
    raise "unsupported param" if word.param.length != 1
    add_defn(word, get_interpreter(word.kind), word.param[0] * @vm.databytes)
  end
  
  def compile_vocabulary(word)
    add_defn(word, get_interpreter(word.kind), word.param)
  end
  
  def init_user(boot_addr=0)
    u = @vm.aligned_dot
    if !@user && !@defn[canonical('user')].nil?
      start = 8
      limit = @vm.aligned_word_addr(@vm.dot) - 1
      # set user area
      USIZE.times { @vm.asm(0) }
      @vm.log(:verbose, "user area at #{u} - #{@vm.dot}")
      # set user free area pointer
      @vm.u = u
      su = fetch('(#user)')
      eu = fetch('(vocs)')
      @vm.store(u + su, (eu - su + cells(1))/cells(1))

      # set source buffer
      # (src) +   0 : input buffer
      # normally, the (src.*) variables are handled by (reset); setting
      # them here just applies sensible defaults.
      sb = @vm.aligned_dot
      TIBSIZE.times { @vm.asm(0) }
      @vm.log(:verbose, "source buffer area at #{sb} - #{@vm.dot}")
      # set source buffer
      su = fetch('(src)')
      @vm.store(u + su, sb)
      su = fetch('(src@)')
      @vm.store(u + su, sb)
      su = fetch('(src0)')
      @vm.store(u + su, sb)
      su = fetch('TIB')
      @vm.store(u + su, sb)

      # set scratch buffer and (srcend)
      # (scratch) + 0 : s" buffer
      sb = @vm.aligned_dot
      SCRATCHSIZE.times { @vm.asm(0) }
      @vm.log(:verbose, "source buffer area at #{sb} - #{@vm.dot}")
      su = fetch('(scratch)')
      @vm.store(u + su, sb)
      su = fetch('(srcend)')
      @vm.store(u + su, sb)

      # set HERE
      hu = fetch('(here)')
      @vm.store(u + hu, @vm.dot)

      # set BASE
      hu = fetch('base')
      @vm.store(u + hu, 10)
      
      @user = true

      if !@headless
        # set forth vocabulary, context, current
        wid = pfa('forth')
        cur = fetch('current')
        ctx = fetch('context')
        voc = fetch('(vocs)')
        @vm.store(wid, @link)
        @vm.store(wid + cells(2), nfa('forth'))
        @vm.store(u + cur, wid)
        @vm.store(u + ctx, wid)
        @vm.store(u + voc, wid)
        limit = @vm.aligned_word_addr(wid) - 1
      end
      @vm.mem_ro = (start..limit)
      @user = true
    end
    @vm.store(0, boot_addr)
    @vm.store(@vm.databytes, u)
  end

  # Compiler interface to get the value of a named user variable.
  # Does not check that 'name' actually corresponds to a user variable.
  def fetch_user(name, offset=0)
    raise "no user area" if !@user
    user = @vm.u
    idx = fetch(name)
    @vm.fetch(user + idx + offset)
  end

  def cold(entry)
    addr = @defn[entry]
    raise "#{entry} not found" if addr.nil?
    # 'cold' must be a colon definition, so make sure it's available
    get_interpreter(':', true)
    exit  = @defn['exit']
    raise "need exit" if exit.nil?
    init_user(addr)
    @vm.log(:verbose, "Boot #{entry} @ #{addr.to_s(16)}")
    @vm.boot(addr)
  end

  def show_defn
    make_defn_map
    @defn_map.each do |name,val|
      vs = "%08x" % val
      puts "#{vs} #{name}"
    end
  end

  def make_defn_map
    if @defn_map.nil?
      @defn_map = @defn.sort{|a,b| a[1] <=> b[1]}
      @rev_defn_map = []
      @defn_map.each_with_index do |entry,idx|
        next_entry = @defn_map[idx+1]
        boundry = next_entry.nil? ? @vm.dot : next_entry[1]
        (entry[1]...boundry).each { |n| @rev_defn_map[n] = idx }
      end
    end
  end

  def see_colon(word)
    addr = word.region.begin
    list = true
    while addr < word.region.end
      if list
        n = @vm.fetch(addr)
        w = @cfa[n]
        v = w || (n < 256 ? n : "%08x" % n)
        a = "%08x" % addr
        puts "#{a} #{v}"
        addr += @vm.databytes
        if v == '(;code)'
          list = false
        end
      else
        addr += @vm.disassemble_at(addr)
      end
    end
  end

  def see(name)
    make_defn_map
    word = @dict[canonical(name)]
    if dict.nil?
      puts "#{name} not found"
    else
      case word.kind
      when :colon
        see_colon(word)
      else
        @vm.disassemble(word.region.begin, word.region.end)
      end 
    end
  end

  def dict
    a = []
    lfa  = @link
    @defn.length.times do
      nfa  = lfa + @vm.databytes
      lex  = @vm.c_fetch(nfa)
      len  = lex & (CFLAG-1)
      name = ''
      len.times { |n| name << @vm.c_fetch(nfa + n + 1).ord }
      name << ' immediate' if (lex & IFLAG) != 0
      name << ' compile-only' if (lex & CFLAG) != 0
      a << name
      lfa = @vm.fetch(lfa)
    end
    a
  end

  def where_header
    colon = ":" + (" " * ((@w_width-2)))
    puts "idx    pc   ip   w    rp@ #{colon} op             stack"
    colon = "-" * (@w_width-1)
    puts "------ ---- ---- ---- --- #{colon} -------------- ---------------"
    @nest = 0
  end

  def where(idx, opcode, arg, ret)
    s = ''
    s += "%6d " % idx
    s += "%04x " % @vm.pc
    s += "%04x " % @vm.ip
    s += "%04x " % @vm.w
    s += "%3d " % @vm.rdepth
    s += " " * @nest
    cfa = @rev_defn_map[@vm.w]
    if cfa.nil?
      name = "???"
    else
      name = @defn_map[cfa][0]
    end
    s += "%-#{@w_width - @nest}s"  % name
    opstr = opcode.to_s.sub(/^vm_/,'')
    opstr << '*' if ret
    s += "%-14s " % opstr
    s += "[#{@vm.depth}]"
    (@vm.depth-1).downto(0) do |n|
      s += ' '
      s += @vm.pick(n).to_s(16)
    end
    case opstr
    when /^docol/, /^does/
      @nest += 1
    when /^exit/
      @nest -= 1 if @nest > 0
    end
    puts "#{s}\r"
  end

  def run(entry=@latest.name)
    cold(entry)
    n = 0
    if @verbose
      @vm.dump
      words
      show_defn
      @dict.sort.each do |k,word| 
        if word.kind == :code
          @vm.log(:out, "Disassembly of #{word.name}")
          @vm.disassemble(word.region.begin, word.region.end)
        end
      end
    end
    begin
      catch :halt do
        where_header if @verbose
        loop do
          
          if @verbose
            @vm.step do |opcode,arg,ret|
              where(n, opcode, arg, ret)
            end
          else
            @vm.step
          end
          n += 1
          raise "stuck" if @run_limit > 0 && n > @run_limit
        end
      end
    rescue
      raise
    ensure
    end
    populate_coverage
  end

  def populate_coverage
    # init
    @defn.each { |name,value| @@coverage[name] ||= 0 }
    # populate
    n = 0
    @vm.profile.each do |cfa,count|
      name = @cfa[cfa]
      next if name.nil? # created after dictionary was compiled
      if !count.nil?
        @@coverage[name] += count
        n += 1
      end
    end
    raise "no matches" if n == 0
  end

  #
  # Try to resolve references to a name via the demand loader
  #
  def resolve_word(name)
    @vm.log(:verbose, "resolve_word(#{name})")
    nm = canonical(name)
    if @dict[nm].nil?
      need(nm, true)
      resolve_references do |token|
        @vm.log(:verbose, "  compiling resolved token #{token}")
        compile_word(@dict[token])
      end
    end
    nm
  end

  #
  # Get the CFA of the given word; raise error if not found
  #
  def tick(name)
    nm = resolve_word(name)
    raise "#{name} forward referenced" if fwdref?(nm)
    addr = @defn[nm]
    raise "#{name} not found" if addr.nil?
    addr
  end

  #
  # Get the PFA of the given word; raise error if not found
  #
  def pfa(name)
    tick(name) + @vm.databytes
  end

  #
  # Get the LFA of the given word; raise error if not found
  #
  def lfa(name)
    nm = resolve_word(name)
    raise "#{name} forward referenced" if fwdref?(nm)
    word = @dict[nm]
    raise "#{name} not found" if word.nil?
    word.link
  end

  #
  # Get the NFA of the given word; raise error if not found
  #
  def nfa(name)
    lfa(name) +  @vm.databytes
  end


  #
  # Number of bytes in 'n' cells
  #
  def cells(n)
    n * @vm.databytes
  end
    

  #
  # Fetch a word from the parameter field 'name' by offset cells
  #
  def fetch(name, offset=0)
    addr = pfa(name)
    @vm.fetch(addr + cells(offset))
  end

  #
  # Store a word from the parameter field 'name' by offset cells
  #
  def store(name, value, offset=0)
    addr = pfa(name)
    @vm.store(addr + cells(offset), value)
  end


  # Compiler interface to return an array of single precision numbers
  # corresponding to the given double number.
  def double_number(d)
    [ @vm.signed(d >> @vm.databits), @vm.integer(d) ]
  end

  # write a memory image to a file
  def image(file)
    entry = @defn[@latest.name]
    endian = @vm.bigendian ? "be" : "le"
    init_user(entry)
    File.open(file, 'w') do |f|
      f.puts "// vmimage #{endian}#{@vm.databits}"
      @vm.dump(0, @vm.dot, true) do |s|
        f.puts s
      end
    end
  end

  # target name
  def target_name
    "vm-" + (@vm.bigendian ? "be" : "le")
  end

  class << self
    def show_coverage
      puts ""
      puts "Coverage"
      @@coverage.sort.each do |k,v|
        puts "#{k} #{v}"
      end
    end

    def needs_coverage
      s = "\n"
      s << "Needs Coverage\n"

      # get everything needing coverage
      w = []
      @@coverage.sort.each { |k,v| w << k if v == 0 }
      w.delete '(does)' # never called directly by design

      if w.length > 0
        # get the length of the longest word
        m = w.map { |k| k.length }.max
        m += 1

        # how many words fit on a Hollerith card?
        c = 80/m

        n = 0
        w.each do |k|
          s << k
          n += 1
          if n == c
            s << "\n"
            n = 0
          else
            s <<  ' ' * (m - k.length)
          end
        end
        s << "\n#{w.length} words\n"
        puts s
      end
    end

    def host_big_endian?
      a = [0x12345678]
      a.pack('N') == a.pack('L')
    end

  end

end
