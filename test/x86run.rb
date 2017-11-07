#
#  x86run.rb
#
#  Copyright (c) 2016 by Daniel Kelley
#

require 'pp'
require 'target'
require 'gdb/mi2'
require 'gmpforth/x86compiler'
require 'gmpforth/x86_64compiler'

module X86Run

  def model
    self.class.const_get(:MODEL)
  end

  def libs
    self.class.const_defined?(:LIBS) ? self.class.const_get(:LIBS) : []
  end

  def setup
    # data size
    @databits = (model == "i386") ? 32 : 64
    @size = @databits/8
    @compiler = (model == "i386") ?
        GMPForth::X86Compiler : GMPForth::X86_64Compiler
    # minus one / mask with all bits set
    @m1 = 2**@databits - 1
    # largest negative
    @m = 2**(@databits - 1)
    # largest positive
    @n = @m-1
    # largest double negative
    @mm = 2 ** (@databits * 2 - 1)
    # largest double positive
    @nn = @mm-1
  end

  # return the 2's complement signed form of the unsigned integer 'n'
  def signed(n, width=@databits)
    i = n & ((1<<width) - 1)
    n[width-1] != 0 ? -((1<<width) - i) : i;
  end

  def compile(s)
    srcfile = "/tmp/gas-#{model}-test.fs"
    File.open(srcfile, 'w') do |f|
      f.puts s
    end
    imagefile = "/tmp/gas-#{model}-image"
    c = @compiler.new
    c.verbose = true if !ENV['VERBOSE'].nil?
    c.library_path "src/gas/#{model}/lib"
    c.library_path "src/core"
    c.library_path "src/core-ext"
    c.library_path "src/fig"
    c.library_path "src/f83/sp-down"
    c.library_path "src/f83"
    c.library_path "src/double"
    c.library_path "src/string"
    c.library_path "src/#{@databits}"
    c.library_path "src/user/lib"
    c.library_path "src/impl"
    c.bootimage = true
    c.hosted = false
    c.savetemp = true if !ENV['SAVE_TEMP'].nil?
    c.scan srcfile
    c.compile
    c.image imagefile
    imagefile
  end

  def gdbtalk(gdb, tgt)
    n = 1
    gdb.send("#{n}-break-insert _atexit_begin")
    rsp = gdb.receive
    n += 1
    gdb.send("#{n}-exec-run")
    rsp = gdb.receive # run
    rsp = gdb.receive # stopped
    if !rsp.notify.nil?
      rsp.notify.each do |notify|
        if notify.info == "thread-created"
          # group-id happens to correspond to the PID of the
          # target process, but this could be subject to change
          tgt.pid = notify.value['group-id']
          $stderr.puts "Target PID is #{tgt.pid}" if gdb.verbose
        end
      end
    end
    n += 1
    gdb.send("#{n}-data-evaluate-expression &_SP0")
    sp0 = nil
    2.times do |t|
      rsp = gdb.receive
      if !rsp.result.nil? && rsp.result.token == n
        sp0 = rsp.result.value['value']
        break
      elsif !rsp.exec.nil?
        assert_equal('stopped', rsp.exec.info)
        assert_equal('breakpoint-hit', rsp.exec.value['reason'])
      end
    end
    n += 1
    gdb.send("#{n}-data-evaluate-expression sp_save")
    rsp = gdb.receive
    sp1 = rsp.result.value['value']
    if !sp0.nil? && !sp1.nil?
      depth = sp0-sp1
      if depth > 0
        n += 1
        gdb.send("#{n}-data-read-memory #{sp1} x #{@size} 1 #{depth/@size}")
        rsp = gdb.receive
        if !rsp.result.nil?
          tgt.stack = rsp.result.value['memory'][0]['data']
        end
      end
    end
    n += 1
    gdb.send("#{n}-exec-continue")
    rsp = gdb.receive
    n += 1
    gdb.send("#{n}-gdb-exit")
    rsp = gdb.receive
    n += 1
    tgt
  end

  # run the image file in gdb
  def gdbrun(imagefile)
    tgt = Target.new
    Open3.popen3("gdb --interpreter=mi2 #{imagefile}") do |input,output,err|
      gdb = GDB::MI2.new(input, output)
      gdb.verbose = true if !ENV['VERBOSE'].nil?
      begin
        gdbtalk(gdb, tgt)
      rescue
        $stderr.puts "Caught #{$!} from GDB talk"
        begin
          Process.kill("INT", tgt.pid) if !tgt.pid.nil?
        rescue
          $stderr.puts "Caught #{$!} from Process.kill"
        end
        gdb.send("-gdb-exit")
        raise
      end
    end
    tgt
  end

  # compile and run 's', return a response
  def exec(s)
    gdbrun(compile(s))
  end

  # return stack in response
  def stack(tgt)
    tgt.stack.reverse.map { |n| signed(n) }
  end

end
