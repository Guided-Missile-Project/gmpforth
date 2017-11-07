#
#  gets_nonblock.rb
# 
#  Copyright (c) 2012 by Daniel Kelley
# 
#  $Id:$
#

require 'stringio'

class IO

  # get a line of characters, but don't block so allow
  # things like timeout handlers to work
  def gets_nonblock(timeout=10, verbose=false)
    start = Time.now
    s = ''
    eol = false
    while !eol do
      begin
        c = read_nonblock(1)
      rescue
        c = ''
      end
      if c.length > 0
        s << c
        eol = (c == "\n")
      else
        # nothing received, so wait a little bit
        sleep(0.001)
        current = Time.now
        delta = current-start
        if delta > timeout
          $stderr.puts "gets_nonblock timeout" if verbose
          raise 'timeout'
        end
      end
    end
    s
  end

end

class StringIO

  def gets_nonblock(timeout=10, verbose=false)
    gets
  end

end
