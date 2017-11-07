#
#  vmseq.rb
# 
#  Copyright (c) 2013 by Daniel Kelley
# 
# 

class GMPForth::VMSeq

  Op = Struct.new("Op", :op, :arg, :ret, :avoid, :push, :combine)

  class Op
    # true if this op is combinable with 'next'
    def combinable?
      !combine && !ret && !avoid
    end
  end

  def initialize(oplist)
    @seq=[]
    expand(oplist)
  end

  def expand(oplist)
    prev = nil
    oplist.each do |p|
      if prev == '(dolit)'
        @seq << Op.new('vm_push', p, false, false, true, false)
      elsif p != '(dolit)'
        raise 'did not expect oplist parameter' if p.nil?
        @seq <<  Op.new(p, nil, p == 'vm_next', p == 'vm_execute', false, false)
      end
      prev = p
    end
  end

  def combine_next
    end_seq = 0
    @seq.each_with_index do |op,idx|
      prev = idx-1
      if idx > 0 && op.ret && @seq[prev].combinable?
        @seq[prev].combine = true
        end_seq = prev
        break
      elsif op.ret
        end_seq = idx
        break
      end
      end_seq = idx
    end
    if end_seq < @seq.length
      @seq.slice!(end_seq+1,@seq.length-end_seq)
    end
    if @seq.length > 0 && @seq[-1].combinable?
      @seq[-1].combine = true
    end
  end

  def each
    @seq.each do |p| 
      yield p 
      # if .combine stop there will be no executions after that
      break if p.combine
    end
  end

end
