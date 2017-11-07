#
#  mhandle.rb
#
#  Copyright (c) 2016 by Daniel Kelley
#
#

#
# IO handle that can avoid Marshal errors
#

class MHandle

  def initialize(iohandle)
    @io = iohandle
  end

  def puts(s)
    @io.puts(s)
  end

  def close
    @io.close
  end

  def path
    @io.path
  end

  def marshal_dump
    []
  end

  def marshal_load array
    @io = nil
  end

end
