#
#  scan.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#
# GMP Forth VM

require 'gmpforth/word'

class GMPForth::Scanner

  def initialize(options={})
    @dict = {}
    @state = :interp
    @latest = nil
    @pstack = []
  end

  def scan(file)
    @file = file
    IO.foreach(file) do |line|
      line.chomp
      begin
        parse(line) if line !~ /^\s*$/
      rescue => detail
        $stderr.puts("#{file}:#{$.}: #{$!}")
        $stderr.puts detail.backtrace.join("\n")
        raise
      end
    end
  end

  def parse(line)
    # puts line
    
    # preprocess line comment token
    # parens comment handled in tokenizer
    # because of things like ': ('
    line.gsub!(/\\.*$/,'')

    if line =~ /\(\s/
      # yeah - ugly
      if line =~ /^(\s*:\s+\(\s+)/
        b = $1
        newline = b + line[b.length..-1].gsub(/\(\s+.*\)/,'')
      else
        newline = line.gsub(/\(\s+.*\)/,'')
      end
      line = newline
    end
    # handle .", but not more than one per line    
    if line =~ /(.*)(\."\s+.*"\s+)(.*)/
    end

    tokens = line.split
    
    tokens.each do |t|
      t.downcase!
      self.send(@state, t)
    end
  end

  def interp(token)
    case token
    when 'vocabulary'
      @state = :vocab
    when 'forth', 'only', 'definitions'
      add(token)
    when 'user'
      @state = :user
    when 'constant'
      @state = :const
    when ':'
      @state = :colon
    when 'immediate'
      @latest.immediate
    when 'compile-only'
      @latest.compile-only
    when '('
      raise "fix this"
      @state = :comment
    when '."'
      raise "not supported"
    when 'code'
      @state = :code
    else
      @pstack.push(token.to_i)
    end
  end

  def add(token)
    if @dict[token].nil?
      @dict[token] = GMPForth::Word.new(token, :unknown)
    end
  end

  def vocab(token)
    w = @dict[token]
    if w.nil?
      w = @dict[token] = GMPForth::Word.new(token, :vocabulary)
      w.where(@file, $.)
    else
      w.isa(:vocabulary)
    end
    @state = :interp
  end

  def user(token)
    raise "expected user var index" if @pstack.length == 0
    # should not expect forward references
    w = @dict[token]
    raise "#{token} already defined" if !w.nil?
    w = GMPForth::Word.new(token, :user)
    w.where(@file, $.)
    w.append(@pstack.pop)
    @dict[token] = w
    @state = :interp
  end

  def const(token)
    raise "expected constant value" if @pstack.length == 0
    # should not expect forward references
    w = @dict[token]
    raise "#{token} already defined @ #{w.loc}" if !w.nil?
    w = GMPForth::Word.new(token, :constant)
    w.where(@file, $.)
    w.append(@pstack.pop)
    @dict[token] = w
    @state = :interp
  end

  def colon(token)
    w = @dict[token]
    if w.nil?
      w = @dict[token] = GMPForth::Word.new(token, :colon)
      w.where(@file, $.)
    else
      w.isa(:colon)
    end
    @latest = w
    @state = :colon_def
  end

  # immediate words
  # +loop
  # ."
  # ;
  # begin
  # do
  # does>
  # else
  # if
  # leave
  # literal
  # loop
  # postpone
  # recurse
  # repeat
  # s" (*)
  # then
  # until
  # while
  # [
  # ]
  # again
  # ?do
  # [char]
  # [']

  def colon_def(token)
    ap = true
    case token
      when ';'
      @state = :interp

      when '('
      raise "fix this"
      comment(token)
      ap = false

      when '."'
      ap = false
      string(token)


      when '[char]'
      ap = false
      bracket_char(token)


    end
    @latest.append(token) if ap
  end

  def string(token)
    case token
    when '."'
      # start
      @oldstate = @state
      @state = :string
      @str = []
    when /(.*)"/
      # end
      @str << $1
      @state = @oldstate
      @latest.append(@str)
    else
      # middle
      @str << token
    end
  end

  def bracket_char(token)
    case token
    when '[char]'
      # start
      @oldstate = @state
      @state = :bracket_char
    else
      # end
      @state = @oldstate
      @latest.append([token[0]])
    end
  end

  def code(token)
    w = @dict[token]
    if w.nil?
      w = @dict[token] = GMPForth::Word.new(token, :code)
      w.where(@file, $.)
    else
      w.isa(:code)
    end
    @latest = w
    @state = :code_def
  end

  def code_def(token)
    ap = true
    case token
      when 'end-code'
      @state = :interp
      when '('
      raise "fix this"
      comment(token)
      ap = false
    end
    @latest.append(token) if ap
  end

  def comment(token)
    case token
    when '('
      raise "fix this"
      @oldstate = @state
      @state = :comment
    when /\)$/
      @state = @oldstate
    end
  end

  def words
    @dict.sort.each { |k,v| puts v.see }
  end

  def groom
    u = {}
    @dict.each_value do |v|
      if v.colon?
        v.param.each do |p|
          if p.kind_of?(String) && @dict[p].nil? && u[p].nil?
            (u[p] ||= []) << v.name
          end
        end
      end
    end
    u.sort.each do |k,v|
      w = v.join(' ')
      puts "#{k} #{w}"
    end
  end

end

