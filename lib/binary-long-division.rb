#
#  binary-long-division.rb
#
#  Copyright (c) 2016 by Daniel Kelley
#
#

class BinaryLongDivision

  def initialize(bits)
    @bits = bits
    @lmask = (1<<(bits/2)) - 1
    @mA = (1<<(bits)) - 1
    @mP = @mA << bits
    @mS = 1<<(bits*2)
  end

  def div(v,s)
    # [q,r] = v/s
    # v     double length dividend
    # s     double length divisor
    # x     double length trial subtract
    # q     single length quotient
    # p     quotient bits
    # clz   count leading zeroes

    # handle division by zero
    if s == 0
      return [0,0] # based on i386
    end

    # handle divisor greater than dividend
    if s > v
      return [0,s]
    end

    q = 0
    m = clz(s)            # count leading zeroes in (extended) divisor
    m -= clz(v)           # subtract leading zeroes in dividend

    # divisor checks above should ensure that 'm' is never negative
    raise "oops" if m < 0

    if m > 0
      s <<= m             # shift s such that leading set bits align
      # if s is too big, divide shift right by 1
      if s > v
        s >>= 1
        m -= 1
      end
    end

    p = 1<<m            # set first quotient bit
    q = p
    while p != 0
      x = v - s         # trial subtract
      t = if x >= 0
            v = x
            q |= p
          end
      if block_given?
        yield [!t.nil?,v,q,p,x,s]
      end
      p >>= 1
      s >>= 1
    end

    r = lo(v)
    [ q, r ]
  end

  #
  # Restore subtract instead of trial subtract
  #
  def div_no_x(v,s)
    q = 0
    c = clz(s)            # count leading zeroes in dividend
    d = clz(v)            # count leading zeroes in (extended) divisor
    m = c-d
    if c >= d
      s <<= m             # shift s such that leading bits align
      if s > v
        s >>= 1
        m -= 1
      end
      p = 1<<m            # set first quotient bit
      q = p
      while p != 0
        v -= s            # subtract
        t = if v >= 0
          q |= p
        else
          v += s          # s too big, so put v back
        end
        if block_given?
          yield [!t.nil?,v,q,p,x,s]
        end
        p >>= 1
        s >>= 1
      end
    end
    r = lo(v)
    q = q
    [ q, r ]
  end

  # Hennessey and Patterson Computer Architecture Appendix I, p.I-5
  # restoring division
  def div_h_p_r(a,b)
    p = 0

    @bits.times do
      # (i) shift combined pa register left one bit
      pa = ((p<<@bits)|a)<<1
      # (ii) p=p-b
      a = pa & @mA
      p = signed((pa & @mP) >> @bits)
      p -= b
      if (p < 0)
        # (iv) restore p
        p += b
      else
        # (iii) if p >= 0
        a |= 1
      end
    end
    [lo(a),lo(p)]
  end

  # restoring division with trial subtract
  def div_h_p_r2(a,b)
    p = 0

    @bits.times do
      # (i) shift combined pa register left one bit
      pa = ((p<<@bits)|a)<<1
      # (ii) p=p-b
      a = pa & @mA
      p = signed((pa & @mP) >> @bits)
      x = p - b
      if (x >= 0)
        # (iii) if p >= 0
        p = x
        a |= 1
      end
    end
    [lo(a),lo(p)]
  end

  # non-restoring division
  # NOT WORKING
  def div_h_p_nr(a,b)
    p = 0

    @bits.times do
      if p < 0
        # (i-a) shift combined pa register left one bit
        pa = ((p<<@bits)|a)<<1
        # (ii-a) p=p+b
        a = pa & @mA
        p = signed((pa & @mP) >> @bits)
        p += b
      else
        # (i-b) shift combined pa register left one bit
        pa = ((p<<@bits)|a)<<1
        # (ii-b) p=p-b
        a = pa & @mA
        p = signed((pa & @mP) >> @bits)
        p -= b
        if (p < 0)
# Tests pass if the following is uncommented
#          # (iv) restore p
#          p += b
        else
          # (iii) if p >= 0
          a |= 1
        end
      end
    end
    # FIXME - need a test case that exercises this last step
    if p < 0
      p += b
    end
    [lo(a),lo(p)]
  end

  def lo(n)
    @lmask & n
  end

  def clz(n)
    z=0
    b=(@bits-1)
    while b >= 0 && n[b] == 0
      z += 1
      b -= 1
    end
    z
  end

  def integer(n)
    n & @mA
  end

  def signed(n, width=@bits)
    i = integer(n)
    n[width-1] != 0 ? -((1<<width) - i) : i;
  end

end
