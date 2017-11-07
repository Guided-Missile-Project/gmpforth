#
#  label.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# 

require 'gmpforth/wordoffset'

class GMPForth::Label

  attr_reader :label, :map

  def initialize
    @idx = 0
    @label = []
    @map = {}
  end

  def create(value=nil)
    label = GMPForth::WordOffset.new(@idx, value)
    @label[@idx] = label
    @idx += 1
    @map[value] = label
    label
  end

  def resolve(label, value)
    label.value = value
  end

end
