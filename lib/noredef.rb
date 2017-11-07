#
#  noredef.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#

module NoRedef

  #
  # Error if a method is redefined
  #
  @@noredef_m = {}

  def method_added(name)
      raise "redefinition not allowed" if !@@noredef_m[name].nil?
      @@noredef_m[name] = true
  end

end
