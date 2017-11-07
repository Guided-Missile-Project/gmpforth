#
#  word.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#
#

require 'gmpforth/label'

class GMPForth::Word

  attr_reader :name, :immediate, :compile_only, :file, :line, :param, :kind
  attr_reader :region, :lex, :label, :line_content
  attr_accessor :rank, :link, :asm_symbol, :does

  def initialize(name, kind)
    @kind = kind
    @name = name
    @param = []
    @words = {}
    @immediate = false
    @compile_only = false
    @file = nil
    @line = nil
    @cstack = []
    @done = false
    @label = GMPForth::Label.new
    @region = nil
    @rank = -1
    @lex = 0
    @does = 0
  end

  def where(file, line_no, line_content=nil)
    @file = file
    @line = line_no
    @line_content = line_content
  end

  def loc
    "#{@file}:#{@line}"
  end

  def add_param(token)
    @param << token
  end

  def append(token, *args)
    raise "definition already done" if @done
    add_param(token)
    @words[token] = true
    args.each { |a| add_param(a) }
  end

  # mark this position in the parameter list as a branch destination
  def mark_dest
    @cstack.push(@param.length)
  end

  # resolve destination to position on top of the control stack
  def resolve_dest
    raise "control stack empty" if @cstack.length == 0
    @param.push(@label.create(@cstack.pop))
  end

  # mark this position in the parameter list as a branch origin
  def mark_orig
    @cstack.push(@param.length)
    @param.push(:branch_target) # dummy target to be replaced by a label
  end

  # resolve origin at position on top of the control stack to 
  # this position in the parameter list
  def resolve_orig
    raise "control stack empty" if @cstack.length == 0
    offset = @cstack.pop
    raise "branch target error" if @param[offset] != :branch_target
    @param[offset] = @label.create(@param.length)
  end

  # mark the beginning of a CASE statement
  def mark_case
    @cstack.push(:case)
  end

  # return false while an endcase is unresolved else return true
  # when the top cstack item is the case marker (and pop the marker)
  def resolve_endcase?
    if @cstack[-1] == :case
      @cstack.pop
      false
    else
      true
    end
  end

  # swap top of control stack
  def cs_swap
    raise 'control stack shallow' if @cstack.length < 2
    @cstack[-1], @cstack[-2] = @cstack[-2], @cstack[-1]
  end

  def isa(kind)
    if @kind != :unknown
      raise "#{@name} is already a #{@kind} from #{loc}"
    end
    @kind = kind
  end

  def code_or_colon
    if !(@kind == :code || @kind == :colon)
      raise "expected code or colon definition"
    end
  end

  def immediate=(value)
    code_or_colon
    @immediate = true
  end

  def compile_only=(value)
    code_or_colon
    @compile_only = value
  end

  def done
    raise "unbalanced control stack" if @cstack.length != 0
    @done = true
  end

  def done?
    @done
  end

  def colon?
    @kind == :colon
  end

  def w
    case @kind
    when :colon, :code
      ww = @words.keys.sort.join(' ')
      "#{@name} #{ww}"
    else
      ''
    end
  end

  def children
    @words.keys
  end

  def see
    case @kind
    when :user
      return "#{@param[0]} user #{@name}"
    when :vocabulary
      return "vocabulary #{@name}"
    when :constant
      return "#{@param[0]} constant #{@name}"
    when :colon, :code
      definer = @kind == :colon ? ':' : 'code'
      param = @param.join(' ')
      mod = ''
      mod << " immediate" if @immediate
      mod << " compile-only" if @compile_only

      return "#{definer} #{@name} #{param}#{mod}"
    else
      return "\\ #{@name} #{@kind}"
    end
  end

  def set_region(from, to)
    @region = Range.new(from, to)
  end
  
  def set_lex(iflag, cflag, sflag)
    @lex = 0
    @lex |= iflag if @immediate
    @lex |= cflag if @compile_only
    @lex |= sflag
  end

  # remember the beginning of the does> list
  def set_does
    @does = @param.length
  end

end

