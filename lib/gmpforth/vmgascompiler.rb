#
#  vmgascompiler.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  Interface for GMP Forth VM GAS assembly macros 
#

require 'gmpforth/gascompiler'

class GMPForth::VMGASCompiler < GMPForth::GASCompiler

  def initialize(options={})
    @model = "vmgas"
    @databytes = 4
    super
    # override
  end

  def code_tokenized
    true
  end

  #
  # Issue code to handle a does list
  #
  def does_comma
    @handle.puts "        vm_does 1"
    @handle.puts "        $ALIGN"
  end

  #
  # Push a small constant value on the stack
  #
  def push(value, ret=false)
    s = "        vm_push #{value & 0x7f}"
    s << ", 1" if ret
    @handle.puts s
  end

end
