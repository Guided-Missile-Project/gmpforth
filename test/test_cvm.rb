#
#  test_cvm.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#
# Test CVM
#

require 'test/unit'
require 'gmpforth'
require 'noredef'
require 'open3'
require 'cvm32'

class TestCVM < Test::Unit::TestCase

  extend NoRedef
  include CVM32

  #
  # Run the VM code fragment on CVM and return stderr as an array of lines
  #
  def exec(s)
    imagefile = '/tmp/cvm-image'
    opt = { 
      :be => GMPForth::VMCompiler.host_big_endian?
    }
    @vc = GMPForth::VMCompiler.new opt
    @vc.bootimage = true
    32.times { @vc.vm.asm(:vm_nop) }
    code = "CODE test #{s} vm_halt END-CODE"
    @vc.parse(code)
    @vc.compile
    @vc.image imagefile
    rsp = []

    Open3.popen3("cvm/cvm -t -d #{imagefile}") do |input,output,err|
      done=false
      while !done
        line = err.gets
        rsp << line.chomp! if !line.nil?
        case line
        when /^===DONE===/
          done=true
        when /Abort/, nil
          done=true
        end
      end
    end
    
    rsp
  end

  #
  # Return the last trace stack before the halt
  #
  def stack(rsp, idx=-1)
    stk = rsp[-2 + idx].split
    raise "no trace" if stk[0] != 'TRACE'
    pstack = stk[8..-1].map { |n| @vc.vm.signed(n.to_i(16)) }
    if stk[7] =~ /\[(\d+)\]/
      raise "stack length mismatch" if pstack.length != $1.to_i
    else
      raise "could not parse stack length from #{stk.inspect}"
    end
    pstack
  end

end
