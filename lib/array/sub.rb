#
#  sub.rb
# 
#  Copyright (c) 2012 by Daniel Kelley
# 
# 

class Array

  # if array 'a' is contained in self, replace 'a' with 'b'
  def sub!(a,b)
    repl = nil
    idx = 0
#    backstop = 0
    while idx < self.length
      sidx = self[idx..-1].index(a[0])
      if sidx
        eidx = idx + sidx
        lim = eidx + a.length - 1
        sub = self[eidx..lim]
#        p [idx,eidx,lim,sub,]
        if a == sub
          self[eidx..lim] = b
          repl = self
          break
        else
          idx = eidx + 1
        end
      else
        break
      end
#      backstop += 1
#      raise "stuck" if backstop > 10
    end
    repl
  end

  # if array 'a' is contained in self, create a new array
  # with 'a' replaced by 'b'
  def sub(a,b)
    y = self.dup
    y.sub!(a,b)
    y
  end

  # keep substituting until no more subs
  def gsub!(a,b)
    subst = false
    while true
      repl = sub!(a,b)
#      p [a,b,self,repl]
      if !repl
        break
      elsif !subst
        subst = true
      end
    end
    subst ? self : nil
  end

  # keep substituting until no more subs returning copy
  def gsub(a,b)
    y = self.dup
    y.gsub!(a,b)
    y
  end

end

