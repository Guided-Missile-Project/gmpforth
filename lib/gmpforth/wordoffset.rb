#
#  wordoffset.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# 


class GMPForth::WordOffset

  attr_reader :index

  def initialize(index, value)
    @index = index
    @value = value
  end

  def value=(value)
    raise "value already set" if !@value.nil?
    @value = value
  end

  def value
    raise "value not set" if @value.nil?
    @value
  end

  def to_s
    @value.to_s
  end

end
