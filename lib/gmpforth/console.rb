#
#  console.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#
# GMPForth console emulator

require 'stringio'

class Console

  def initialize(input=$stdin, output=$stdout)
    @input = []
    @output = []
    @rawmode = false
    @isatty  = false
    redirect(input,output)
    at_exit { cooked if @rawmode }
  end

  def input
    @input[-1]
  end

  def output
    @output[-1]
  end

  def raw
    if @isatty
      system("stty raw -echo")
      @rawmode = true
    end
  end

  def cooked
    if @isatty
      system("stty sane")
      @rawmode = false
    end
  end

  def key
    raw
    resp = nil
    if @isatty && input.respond_to?(:readpartial)
      resp = input.readpartial(1)
    else
      resp = input.read(1)
    end
    if resp.nil?
      if input.respond_to?(:string) && input.respond_to?(:pos)
        $stderr.puts "Q #{input.string.inspect}@#{input.pos}"
      end
      raise "no response from #{input.inspect}"
    end
    resp[0].ord
  end

  def key?
    true
  end

  def emit(c)
    raw
    output.write(c.chr)
    output.flush
  end

  def emit?
    true
  end

  def redirect(inp,out)
    @input.push inp.is_a?(String) ? StringIO.new(inp) : inp
    @output.push out.is_a?(String) ? StringIO.new(out, 'w') : out
    @isatty = input.isatty
  end

  def undirect
    raise if @input.length < 2
    cooked
    @input.pop
    @output.pop
    @isatty = input.isatty
  end

end
