#
#  compiler.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#
# GMP Forth Compiler

require 'gmpforth/word'
require 'gmpforth/documentation'
require 'pp'
require 'yaml'
require 'tempfile'

class GMPForth::Compiler

  attr_accessor :case_sensitive
  attr_reader :dict

  # Target image is headless (no dictionary entries)
  attr_accessor :headless
  
  # Target image is host (can defined words)
  attr_accessor :hosted
  
  # Kernel is in Read Only Memory
  attr_accessor :rom

  # Verbose
  attr_accessor :verbose

  # Create boot image
  attr_accessor :bootimage

  # Save temporary files
  attr_accessor :savetemp

  BL = ' '
  LIB_INDEX = 'Library.yaml'
  FWD_LIMIT = 1000 # forward reference resolution loop limit

  # immediate words
  DICT = {
    '+loop'             => :f_plus_loop,
    '."'                => :f_dot_quote,
    ';'                 => :f_semicolon,
    'begin'             => :f_begin,
    'do'                => :f_do,
    'does>'             => :f_does,
    'else'              => :f_else,
    'if'                => :f_if,
    'leave'             => :f_leave,
    '?leave'            => :f_question_leave,
    'literal'           => :f_literal,
    'loop'              => :f_loop,
    'postpone'          => :f_postpone,
    'recurse'           => :f_recurse,
    'repeat'            => :f_repeat,
    's"'                => :f_s_quote,
    'then'              => :f_then,
    'until'             => :f_until,
    'while'             => :f_while,
    '['                 => :f_l_bracket,
    ']'                 => :f_r_bracket,
    'again'             => :f_again,
    '?do'               => :f_question_do,
    '[char]'            => :f_bracket_char,
    '[\']'              => :f_bracket_tick_bracket,
    'vocabulary'        => :f_vocabulary,
    'forth'             => :f_forth,
    'only'              => :f_only,
    'definitions'       => :f_definitions,
    'user'              => :f_user,
    'constant'          => :f_constant,
    ':'                 => :f_colon,
    'immediate'         => :f_immediate,
    'compile-only'      => :f_compile_only,
    '('                 => :f_parens,
    '\\'                => :f_backslash,
    'code'              => :f_code,
    'end-code'          => :f_end_code,
    ';code'             => :f_semi_code,
    'create'            => :f_create,
    'variable'          => :f_variable,
    'include"'          => :f_include_quote,
    'parameter'         => :f_parameter,
    'feature'           => :f_feature,
    'case'              => :f_case,
    'of'                => :f_of,
    'endof'             => :f_endof,
    'endcase'           => :f_endcase,
  }

  CODE_DICT = {
    '('                 => :f_parens,
    '\\'                => :f_backslash,
    'end-code'          => :f_end_code,
  }

  TMP_BASE = 'gfg'

  def initialize(options={})
    @dict = {}
    @dict_o = []
    @state = 0
    @code = false
    @semicode = false
    @latest = nil
    @pstack = []
    @to_in = 0
    @case_sensitive = false
    @postpone_fwd = {}
    @tokenize = true
    @include = [nil] # reserve element for 'also' dir
    @alsodir = [] # current dir of scanned file
    @libfwd = []
    @libmap = []
    @entry = nil
    @bootimage = false
    @verbose = false
    @headless = true
    @rom = false
    @savetemp = false
    @hosted = true
    @optim_combine_next = false
    @macro = {}
    @macro_file = {}
    @fstack = [] # file stack [file,line_no]
    @dependency = []
  end

  def include(*dir)
    dir.each { |d| @include << d }
  end

  def locate_relative(file)
    absfile = file
    @include.each do |dir|
      absfile = File.expand_path(file, dir)
      if File.exist? absfile
        return absfile
      end
    end
    raise "could not find #{file}"
  end

  def locate(file)
    if file !~ %r{^/}
      file = locate_relative(file)
    elsif !File.exist? file
      raise "could not find #{file}"
    end
    file
  end

  # also search directory of file
  def also_search(dir)
    if File.directory? dir
      @alsodir << dir
      @include[0] = dir
    else
      fatal("#{dir} not found")
    end
  end

  # pop 
  def also_pop
    @alsodir.pop
    @include[0] = @alsodir[-1]
  end

  def fatal(msg=$!)
    file,line = @fstack[-1]
    $stderr.puts("#{file}:#{line}: #{msg}")
    exit 1
  end

  def scan(*files)
    files.each do |file|
      _scan(file)
      @entry = @latest
      resolve_references
    end
  end

  def _scan(file)
    path = locate(file)
    @dependency << path
    also_search(File.dirname(path))
    @fstack.push([path,0])
    IO.foreach(path) do |line|
      @fstack[-1][1] += 1 # incr line#
      begin
        parse_line(line)
      rescue => detail
        print detail.backtrace.join("\n")
        fatal
      end
    end
    @fstack.pop
    also_pop
  end

  # add macro definition
  def macro(name,value=true)
    @macro[name] = value
    @macro_file[name] = @fstack[-1][0]
  end

  def parse(string)
    string.each_line { |line| parse_line(line) }
  end

  #
  # Just barely enough support to compile forth-wordlist
  #
  def interpret(token)
    case token
    when "'"
      @pstack.push(word(BL))
    when ">body"
      @pstack[-1] += "_pfa"
    else
      @pstack.push(token.to_i)
    end
  end

  def tokenize(line)
    @tib = line
    @number_tib = line.length
    @to_in = 0
    while @to_in < @number_tib
      token = word(BL)
      if token.length == 0
        next
      end

      # macro replacement
      macro = @macro[token]
      token = macro if !macro.nil? && macro != true

      t = canonical(token)
      w = @code ? CODE_DICT[t] : DICT[t]

      if w.nil?
        if @state == 0
          interpret(token)
        else
          if !@dict[t].nil? && !@code
            # dict word
            @latest.append(t)
          elsif token =~ /^-?\d+$/
            # single
            need('(dolit)')
            @latest.append('(dolit)', token.to_i)
          elsif token != '.'  && token =~ /^-?[\d\.]+$/
            # double
            n = token.gsub('.', '').to_i
            a = double_number(n)
            need('(dolit)')
            @latest.append('(dolit)', a[1])
            @latest.append('(dolit)', a[0])
          elsif token =~ /^\$([\da-fA-F]+)$/
            # single hex
            need('(dolit)')
            @latest.append('(dolit)', $1.to_i(16))
          elsif token =~ /^\$\w+\$$/
            # symbolic reference
            need('(dolit)')
            @latest.append('(dolit)', token)
          elsif token =~ /^\$([\d\.a-fA-F]+)$/
            # double hex
            n = $1.gsub('.', '').to_i(16)
            a = double_number(n)
            need('(dolit)')
            @latest.append('(dolit)', a[1])
            @latest.append('(dolit)', a[0])
          else
            # forward reference
            forward_reference(t)
            @latest.append(t)
          end
        end
      else
        # perform operation of dict word
        send(w)
      end
    end
  end

  def library_path(*lib)
    lib.each { |dir| library(dir) }
  end

  # add a library directory
  def library(dir)
    idxfile = File.expand_path(LIB_INDEX, dir)
    if File.exists?(idxfile)
      File.open(idxfile, 'r') do |f|
        map = YAML::load(f)

        # scan map for macro references
        m = []
        map.each do |k,v|
          if v.is_a?(Array)
            # macro found; load immediately
            raise "oops" if v[0] != "MACRO"
            m << k
            _scan(v[1])
          end
        end
        # delete macro from map
        m.each do |name|
          map.delete(name)
        end

        @libmap << map
      end
    else
      raise "#{idxfile} not found"
    end
  end

  def libfile(token)
    @libmap.each do |map|
      file = map[token]
      return file if !file.nil?
    end
    raise "Cannot find #{token} in libraries"
  end

  def forward_reference(token, force = false)
    if (@latest.kind != :code && @semicode == false) || force
      @libfwd << canonical(token)
    end
  end

  def resolve_references
    if @libmap.length > 0
      limit = FWD_LIMIT
      while @libfwd.length != 0
        # pop off a token
        token = @libfwd.pop
        if @dict[token].nil?
          # not resolved - scan
          file = libfile(token)
          # $stderr.puts "resolving #{token} via #{file}"
          _scan(file)
          raise "resolution failed for #{token}" if @dict[token].nil?
          raise "forward reference resolution stuck" if limit < 0
          limit -= 1
          yield(token) if block_given?
        end
      end
    end
  end

  def lineize(line)
    t = canonical(line)
    w = DICT[t]
    if w.nil?
      # only used in assembly, so forward referencing not required
      @latest.append(line)
    else
      # perform operation of dict word
      send(w)
    end
  end

  def parse_line(line)
    line.chomp!
    if @tokenize
      tokenize(line)
    else
      lineize(line)
    end
  end

  def word(delim)
    delim=delim[0].chr
    l = ''
    w = ''
    t = ''

    # Skip leading delimiter if delimiter is whitespace. Not sure how
    # to reconcile this with the requirement for WORD to skip leading
    # delimiters and have this work for non-whitespace delimiters.
    state = delim =~ /\s/ ? :skip : :collect

    start = @to_in
    (@to_in...@number_tib).each do |n|
      c = @tib[n].chr
      @to_in += 1
      case state
      when :skip
        # scan forward while the delimiter is seen
        if c == delim
          l << c
        else
          w << c
          state = :collect
        end
      when :collect
        # accumulate non-delimiter characters until the delimiter
        # is seen again, or the end of the string is reached
        if c == delim
          raise "huh?" if w.length == 0 && delim =~ /\s/
          t << c
          break
        else
          w << c
        end
      end
    end
    $stderr.puts "#{start} #{@to_in - 1} #{delim.inspect} #{l.inspect} #{w.inspect} #{t.inspect}" if @verbose
    w
  end

  def name
    n = word(BL)
    raise "no name" if n.length == 0
    n
  end

  #
  # Return the canonical form of name
  #
  def canonical(name)
    if @case_sensitive || ((@code || @semicode) && (name =~ /:::$/))
      name
    else
      name.downcase
    end
  end

  def define(kind)
    n = canonical(name)
    raise "#{n} redefined by #{@dict[n].file}" if !@dict[n].nil?
    @latest = GMPForth::Word.new(n, kind)
    file,line = @fstack[-1]
    @latest.where(file, line, @tib)
    @dict[n] = @latest
    @dict_o << @latest
    @latest
  end

  # indicate a word is needed
  def need(name, force=false)
    if @dict[name].nil?
      forward_reference(name, force)
    end
  end

  def words
    @dict.sort.each { |k,v| puts v.see }
  end

  def quote(s)
    s.gsub('"','\"')
  end

  def dot
    puts 'digraph fc {'
    @dict.each do |name,word|
      word.children.each do |child| 
        puts "  \"#{quote(name)}\" -> \"#{quote(child)}\";"
      end
    end
    puts '}'
  end

  def dep
    @dict.each do |name,word|
      word.children.each do |child| 
        puts "#{name} #{child}"
      end
    end
  end

  # substitute string metavariables
  def metasub(s)
    s.gsub(/%(\w+)%/) do |match|
      send($1)
    end
  end

  # append a string cell, plus additional dummy cells corresponding to the string length
  def append_counted_string(s)
    @latest.append(metasub(s))

    cell_len = cells(1)
    cstr_len = s.length + 1 # counted string
    num_pad_cells = (cstr_len / cell_len) - 1
    if cstr_len % cell_len != 0
      num_pad_cells += 1
    end
    raise "pad request (#{num_pad_cells}) was negative" if num_pad_cells < 0
    num_pad_cells.times { @latest.append('<<dummy>>') }
  end

  #
  # Return a library index data structure for all compiled words
  #
  def library_index
    idx = {}
    # create indicies
    @dict.each do |name,word|
      dir = File.dirname(word.file)
      if idx[dir].nil?
        idx[dir] = {}
      end
      idx[dir][name] = File.expand_path(word.file)
    end
    @macro_file.each do |name,file|
      dir = File.dirname(file)
      if idx[dir].nil?
        idx[dir] = {}
      end
      idx[dir][name] = [ "MACRO", File.expand_path(file) ]
    end
    idx
  end

  #
  # Make library index files for all compiled words
  #
  def make_index

    # write out library index
    library_index.each do |dir,lib|
      idxfile = File.expand_path(LIB_INDEX, dir)
      File.open(idxfile, 'w') do |f|
        f.puts lib.to_yaml
      end
    end
  end

  #
  # Make dependency file
  #
  def dependency(depspec)
    depfile, target = depspec.split ','

    # append local ruby libs
    $LOADED_FEATURES.each do |path|
      next if path !~ /gmpforth/
      @dependency << path
    end

    # write out dep file
    File.open(depfile, 'w') do |f|
      f.write "#{target}: "
      @dependency[0..-2].each do |path|
        f.puts " #{path} \\"
      end
      f.puts " #{@dependency[-1]}"

    end
  end

  #
  # Temporary file
  #
  def tempfile(ext='')
    tf = Tempfile.new(TMP_BASE+ext)
    if @savetemp
      # yuk - relies on some internal knowledge
      ObjectSpace.undefine_finalizer(tf)
    end
    tf
  end

  #
  #
  # Make documentation template files for all compiled words
  #
  def make_doc_template(dir)
    doc = GMPForth::Documentation.new(dir)
    doc.generate(@dict)
  end

  #
  # Set optimizations
  #
  def optimize(level)
    case level
    when 0
      @optim_combine_next = false
    when 1
      @optim_combine_next = true
    end
  end

  # Create an "automatic" message for generated files
  def automatic(pfx='')
   return <<EOF
#{pfx}Automatically generated by #{$0}
#{pfx}
#{pfx}Do not edit as changes may be lost
EOF
  end

  #
  # Make C header
  #
  def macro_header(file)
    base = File.basename(file)
    guard = '_'
    guard << base.gsub('.','_').upcase
    guard << '_'
    defs = ""
    @macro.sort.each do |k,v|
      next if v == false
      defs << "#define #{k}"
      defs << " #{v}" if v != true
      defs << "\n"
    end
    defs << "#define ROM 1\n" if @rom
    File.open(file, 'w') do |f|
      f.puts <<EOF
/* 
   #{base}

#{automatic('   ')}
*/

#ifndef   #{guard}
#define   #{guard}

#{defs}
#endif /* #{guard} */
EOF
    end
  end

  #
  # make Ruby constants
  #
  def constant_module(file)
    base = File.basename(file)
    modname = base.sub(/\.rb$/,'').upcase
    defs = ""
    @macro.sort.each do |k,v|
      defs << "#{k} = #{v}\n"
    end
    defs << "ROM = 1\n" if @rom
    File.open(file, 'w') do |f|
      f.puts <<EOF
#
# #{base}
#
#{automatic('# ')}
module GMPForth::#{modname}

#{defs}
end

EOF
    end
  end

  #
  # make GAS assembly header
  #
  def asm_header(file)
    base = File.basename(file)
    defs = ""
    @macro.sort.each do |k,v|
      next if v == false || v.nil?
      defs << "        .set #{k}"
      defs << ", #{v}" if v != true
      defs << "\n"
    end
    defs << "        .set ROM, 1\n" if @rom
    File.open(file, 'w') do |f|
      f.puts <<EOF
/*
 * #{base}
 *
#{automatic(' * ').chomp}
 *
 */

#{defs}

EOF
    end
  end



  #
  # Forth compiler words
  #

  def f_plus_loop
    need('(+loop)')
    @latest.append('(+loop)')
    @latest.resolve_dest
    @latest.resolve_orig
  end

  def f_dot_quote
    need('(s")')
    need('type')
    @latest.append('(s")')
    append_counted_string(word('"'))
    @latest.append('type')
  end

  def f_semicolon
    need('exit')
    @latest.append('exit')
    @latest.done
    @state = 0
  end

  def f_begin
    @latest.mark_dest
  end

  def f_do
    need('(do)')
    @latest.append('(do)')
    @latest.mark_orig
    @latest.mark_dest
  end

  def f_does
    if @hosted
      need('(;code)')
      need('(does,)')
      @latest.append('(;code)', '(does,)')
    end
    @latest.set_does
  end

  def f_else
    need('(branch)')
    @latest.append('(branch)')
    @latest.mark_orig
    @latest.cs_swap
    @latest.resolve_orig
  end

  def f_if
    need('(0branch)')
    @latest.append('(0branch)')
    @latest.mark_orig
  end

  def f_leave
    need('(leave)')
    @latest.append('(leave)')
  end

  def f_question_leave
    need('(0branch)')
    need('(leave)')
    f_if
    @latest.append('(leave)')
    f_then
  end

  def f_literal
    need('(dolit)')
    @latest.append('(dolit)', @pstack.pop)
  end

  def f_loop
    need('(loop)')
    @latest.append('(loop)')
    @latest.resolve_dest
    @latest.resolve_orig
  end

  def postpone_fwdref(name, defn)
    if @postpone_fwd[name].nil?
      @postpone_fwd[name] = []
    end
#    $stderr.puts "#{defn.name} - postpone forward reference to #{name}"
    @postpone_fwd[name] << [ defn, defn.param.length + 2 ]
  end

  def postpone_resolve(defn)
    if !@postpone_fwd[defn.name].nil?
      if defn.immediate
        @postpone_fwd[defn.name].each do |target, offset|
#          $stderr.puts "#{defn.name} - resolving postpone forward reference to #{target.name}@#{offset}"
          raise "expected compile," if target.param[offset] != 'compile,'
          target.param[offset] = 'execute'
        end
      else
#        $stderr.puts "#{defn.name} - not immediate, no resolution needed"
      end
      @postpone_fwd.delete(defn.name)
    end
  end

  def check_unresolved
    # any remaining unresolved postpone forward references must be non-immediate
    del = []
    @postpone_fwd.each_key { |key| del << key if !@dict[key].immediate }
    del.each { |key| @postpone_fwd.delete(key) }

    # now what's left is unresolved
    if @postpone_fwd.length != 0
      fwd = @postpone_fwd.keys.join ' '
      raise "unresolved postpone forward references: #{fwd}"
    end
    false
  end

  def f_postpone
    w = canonical(word(BL))
    pw = 'compile,'
    defn = @dict[w]
    if defn.nil?
      # forward reference; resolve when word becomes known
      postpone_fwdref(w, @latest)
    else
      pw = 'execute' if defn.immediate
    end
    need('(dolit)')
    need(w)
    need(pw)
    @latest.append('(dolit)', w, pw)
  end

  def f_recurse
    @latest.append(@latest.name)
  end

  def f_repeat
    f_again
    f_then
  end

  def f_s_quote
    need('(s")')
    @latest.append('(s")')
    append_counted_string(word('"'))
  end

  def f_then
    @latest.resolve_orig
  end

  def f_until
    need('(0branch)')
    @latest.append('(0branch)')
    @latest.resolve_dest
  end

  def f_while
    f_if
    @latest.cs_swap
  end

  def f_l_bracket
    raise "unsupported"
  end

  def f_r_bracket
    raise "unsupported"
  end

  def f_again
    need('(branch)')
    @latest.append('(branch)')
    @latest.resolve_dest
  end

  def f_question_do
    need('(?do)')
    @latest.append('(?do)')
    @latest.mark_orig
    @latest.mark_dest
  end

  def f_bracket_char
    need('(dolit)')
    w = word(BL)
    @latest.append('(dolit)', w[0].ord)
  end

  def f_bracket_tick_bracket
    w = canonical(word(BL))
    need('(dolit)')
    need(w)
    @latest.append('(dolit)', w)
  end

  def f_vocabulary
    define(:vocabulary)
    @latest.add_param(0) # word list head
    @latest.add_param(0) # voc-link
    @latest.add_param(0) # pointer to name counted string
    @latest.done
  end

  def f_forth
    if @state == 1
      @latest.append('forth')
    end
  end

  def f_only
    if @state == 1
      @latest.append('only')
    end
  end

  def f_definitions
    if @state == 1
      @latest.append('definitions')
    end
  end

  def f_user
    if @state == 0
      raise "stack empty" if @pstack.length == 0
      need_user if respond_to? :need_user
      define(:user)
      uoffset = @pstack.pop
      if @macro['USER_LAST'].nil?
        @macro['USER_LAST'] = "0"
      end
      ulast = [ uoffset, @macro['USER_LAST'].to_i ].max
      @macro['USER_LAST'] = ulast
      @latest.add_param(uoffset)
      uname = @latest.name.upcase
      # FIXME: need to eventually convert all user variables to assembly
      # constants, but this is sufficient for trap.S
      if uname =~ /^[A-Z_]+$/
        @macro['USER_' + uname] = uoffset
      end
      @latest.done
    else
      @latest.append('user')
    end
  end

  def f_constant
    if @state == 0
      raise "stack empty" if @pstack.length == 0
      define(:constant)
      @latest.add_param(@pstack.pop)
      @latest.done
    else
      @latest.append('constant')
    end
  end

  def f_create
    if @state == 0
      # no parameter expected
      raise "stack not empty" if @pstack.length != 0
      define(:variable)
      @latest.done
    else
      @latest.append('create')
    end
  end

  def f_variable
    if @state == 0
      define(:variable)
      @latest.add_param(0)
      @latest.done
    else
      @latest.append('variable')
    end
  end

  def f_colon
    define(:colon)
    @state = 1
  end

  def f_immediate
    if @state == 0
      @latest.immediate = true
      postpone_resolve(@latest)
    else
      @latest.append('immediate')
    end
  end

  def f_compile_only
    if @state == 0
      @latest.compile_only = true
    else
      @latest.append('compile-only')
    end
  end

  def f_parens
    word(')')
  end

  def f_backslash
    @to_in = @number_tib
  end

  def f_code
    define(:code)
    @state = 1
    @code = true
    @tokenize = respond_to?(:code_tokenized) ? code_tokenized : true
  end

  def f_end_code
    @state = 0
    @code = false
    @latest.done
    @tokenize = true
    @semicode = false
  end

  def f_semi_code
    need('(;code)')
    @latest.append('(;code)')
    @tokenize = respond_to?(:code_tokenized) ? code_tokenized : true
    @semicode = true
  end

  def f_include_quote
    raise "interpret only" if @state != 0
    file = word('"')
    scan(file)
  end

  def f_parameter
    raise "stack empty" if @pstack.length == 0
    raise "interpret only" if @state != 0
    # because parameters are replaced at the token processing phase
    # they need to be strings
    macro(name,@pstack.pop.to_s)
  end

  def f_feature
    raise "stack not empty" if @pstack.length != 0
    raise "interpret only" if @state != 0
    macro(name,true)
  end

  def f_case
    @latest.mark_case
  end

  def f_of
    need('(of)')
    @latest.append('(of)')
    f_if
  end

  def f_endof
    f_else
  end

  def f_endcase
    while @latest.resolve_endcase? do
      f_then
    end
  end

  #
  # Stubs
  #
  def cells(n)
    n
  end

  # Compiler interface to return an array of single precision numbers
  # corresponding to the given double number.
  def double_number(d)
    [d]
  end

  # compiler interface to return the target name
  def target_name
    "none"
  end

end

