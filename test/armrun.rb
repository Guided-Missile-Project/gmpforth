#
#  armrun.rb
#
#  Copyright (c) 2015 by Daniel Kelley
#
# ARM model test runner
#
# Uses model defined externally as the stack model
#

require 'pp'
require 'target'
require 'gdb/mi2'
require 'gmpforth/armcompiler'

module ARMRun

  def model
    self.class.const_get(:MODEL)
  end

  def libs
    self.class.const_defined?(:LIBS) ? self.class.const_get(:LIBS) : []
  end

  def setup
    @arch = (model == "a64") ? "aarch64" : "arm"
    @cross_env = (model == "a64") ? "CROSS_A64" : "CROSS_A32"
    @qemu_env = (model == "a64") ? "QEMU_A64" : "QEMU_A32"
    @cross = ENV[@cross_env] || "#{@arch}-elf-"
    # minus one / mask with all bits set
    # FIXME: model dependent; should get from the compiler
    @databits = (model == "a64") ? 64 : 32
    # SAME
    @size = @databits/8
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
    n[width-1] != 0 ? -((1<<width) - i) : i
  end

  def compile(s)
    # bin/gmpfc -Btest3 -tx86 -Lsrc/gas/arm ~/tmp/test3.fs 
    srcfile = "/tmp/gas-#{@arch}-#{model}-test.fs"
    File.open(srcfile, 'w') do |f|
      f.puts s
    end
    imagefile = "/tmp/gas-#{@arch}-#{model}-image"
    c = GMPForth::ARMCompiler.new({:target_opt => model})
    c.verbose = true if !ENV['VERBOSE'].nil?
    c.library_path "src/core-ext/recursive/roll"
    c.library_path "src/gas/arm/#{model}/lib"
    c.library_path "src/gas/c10"
    libs.each { |lib| c.library_path(lib)  } # extra model specific hacks
    # c.library_path "src/gas/arm/common"
    c.library_path "src/gas/common"
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
    # c.asm_header("src/gas/arm/#{model}/const.inc")
    c.compile
    c.image imagefile
    imagefile
  end

  def gdbtalk(gdb, tgt)
    gdb.send("target remote localhost:#{@gdbport}")
    rsp = gdb.receive
    n = 1
    gdb.send("#{n}-break-insert _sysret")
    rsp = gdb.receive
    n += 1
    gdb.send("#{n}-exec-continue")
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
    gdb.send("#{n}-data-evaluate-expression _spsave")
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
    Open3.popen3("#{@cross}gdb --interpreter=mi2 #{imagefile}") do |input,output,err|
      gdb = GDB::MI2.new(input, output)
      gdb.verbose = true if !ENV['VERBOSE'].nil?
      begin
        gdbtalk(gdb, tgt)
      rescue
        Process.kill("INT", tgt.pid) if !tgt.pid.nil?
        gdb.send("-gdb-exit")
        raise
      end
    end
    tgt
  end

  # run the image file in qemu
  def qemurun(imagefile)
    @gdbport = ENV['QEMU_GDB'] || 3000
    @qemu_arm = ENV[@qemu_env] || "qemu-#{@arch}"
    @qemu = IO.popen("#{@qemu_arm} -g #{@gdbport} #{imagefile}")
  end

  def armrun(imagefile)
    tgt = nil
    qemu = qemurun(imagefile)
    if !qemu.nil?
      tgt = gdbrun(imagefile)
      Process.kill("TERM",qemu.pid)
    end
    tgt
  end

  # compile and run 's', return a response
  def exec(s)
    armrun(compile(s))
  end

  # return stack in response
  def stack(tgt)
    tgt.stack.reverse.map { |n| signed(n) }
  end


end
