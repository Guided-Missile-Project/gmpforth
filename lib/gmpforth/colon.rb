#
#  colon.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

class GMPForth::Colon

  attr_reader :word, :start_addr

  def initialize(word)
    @word = word
    @body = []
  end

  def add(p)
    raise "oops: need something to add" if p.nil?
    @body << p
  end

  #
  # yield :does_comma
  #       :push, p
  #       :add_defn, body => start_addr
  #       :does body
  #       :defn, p => cfa
  #       :fwdref, p => cfa
  #       :lookup, p => cfa
  #       :integer, p => value
  #       :branch, p  => value
  #       :string, p  => value
  #       :assemble, p
  #       :label, idx
  #       :semi_code
  #
  # start_addr only saved, not used internally
  def compile
    @body = []
    compile_str = false
    definer = false
    @start_addr = nil
    end_addr = nil
    prev_p = nil
    @word.param.each_with_index do |p, index|
      if !@word.label.map[index].nil?
        # some targets don't need labels
        label = yield(:label, index)
        add(label) if !label.nil?
      end
      defn = (definer != :semi_code) ? yield(:defn, [p,index]) : nil
      if definer == :semi_code
        if p == '(dolit)'
          # skip
        elsif p == '(does,)'
          yield(:does_comma)
          # vmcompiler
          #  @vm.asm(:vm_does, 1)
          #  @vm.aligned_dot
          # continue with compiling colon-def
          definer = :does
          @body = []
        elsif p.kind_of?(Numeric)
          # in code, if it looks like a number, push it
          yield(:push, p)
          # vmcompiler
          # @vm.asm(:vm_push, p)
        else
          yield(:assemble, p)
          # vmcompiler
          # @vm.asm(p.to_sym)
        end
      elsif p == '<<dummy>>'
        # string cell padding - ignore
      elsif p == '(;code)' && prev_p != '(dolit)'
        raise 'already a defining word' if definer != false
        definer = :semi_code
        cfa = yield(:lookup, p)
        add(cfa)
        # vmcompiler
        #   lookup(p)

        @start_addr = yield(:add_defn, @body)
        # vmcompiler:
        #   start_addr= add_defn(word, interp, body)
        #   resolve_interpreter(word)
        #   return start_addr
        yield(:semi_code)
      elsif p == '(s")' && prev_p != '(dolit)'
        cfa = yield(:lookup, p)
        add(cfa)
        compile_str = true
        # vmcompiler
        #   lookup(p)
      elsif !defn.nil? && !compile_str
        add(defn)
      elsif p.is_a?(Integer)
        val = yield(:integer, p)
        add(val)
        # vmcompiler
        #   return p
      elsif p.is_a?(GMPForth::WordOffset)
        val = yield(:branch, p)
        add(val)
        # vmcompiler
        #   return p
      elsif p.is_a?(String)
        if compile_str
          val = yield(:string, p)
          add(val)
          compile_str = false
        elsif prev_p == '(dolit)' && p =~ /^\$(\w+)\$$/
          # special symbolic reference
          val = yield(:integer, $1)
          add(val)
        else
          cfa = yield(:fwdref, p)
          add(cfa)
          # forward reference
          # vmcompiler
          #  fwdsym(p)
        end
      else
        raise "Unsupported word type #{p.class} in #{p.inspect}"
      end

      prev_p = p
    end

    case definer
    when false
      @start_addr = yield(:add_defn, @body)
      #  vmcompiler:
      #    add_defn(word, interp, body)
    when :does
      yield(definer, @body)
      #  vmcompiler:
      #    body.each { |p| vm.asm(p) }
    end
    
  end

end

