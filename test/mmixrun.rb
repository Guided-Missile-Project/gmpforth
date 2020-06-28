#
#  mmixrun.rb
#
#  Copyright (c) 2015 by Daniel Kelley
#
# MMIX model test runner
#
# Uses model defined externally as the stack model
#

require 'pp'
require 'target'
require 'gmpforth/mmixcompiler'

module MMIXRun

  MMIXSTAT = ENV['MMIXSTAT']

  def model
    self.class.const_get(:MODEL)
  end

  def libs
    self.class.const_defined?(:LIBS) ? self.class.const_get(:LIBS) : []
  end

  def setup
    # minus one / mask with all bits set
    @databits = 64

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
    # bin/gmpfc -Btest3 -tx86 -Lsrc/gas/mmix ~/tmp/test3.fs 
    srcfile = "/tmp/gas-mmix-#{model}-test.fs"
    File.open(srcfile, 'w') do |f|
      f.puts s
    end
    imagefile = "/tmp/gas-mmix-#{model}-image"
    c = GMPForth::MMIXCompiler.new({:target_opt => model})
    c.verbose = true if !ENV['VERBOSE'].nil?
    c.library_path "src/core-ext/recursive/roll"
    c.library_path "src/gas/mmix/#{model}/lib"
    c.library_path "src/gas/#{model}"
    libs.each { |lib| c.library_path(lib)  } # extra model specific hacks
    c.library_path "src/gas/mmix/common"
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
    # c.asm_header("src/gas/mmix/#{model}/const.inc")
    c.compile
    c.image imagefile
    imagefile
  end

  # run the image file in mmix
  # need symbol table
  # need addr of _exit
  # need addr of _SP0
  # need GREG defns
  # rDoes       $254
  # a           $253
  # b           $252
  # c           $251
  # d           $250
  # ip          $249
  # rp          $248
  # sp          $247
  # w           $246
  # u           $245
  # _SP0 = #2000000000000828 (2)
  # set bx at addr of _exit
  # run
  # error if not at _exit
  # dump stack

  def mmixsymtab(imagefile)
    symtab = {}
    cross = ENV["CROSS_MMIX"] || ENV['CROSS'] || "#{@model}-elf-"
    IO.popen("#{cross}nm #{imagefile}") do |f|
      f.readlines.each do |line|
        if line =~ /(\w+)\s+(\w+)\s+(\w+)/
          symtab[$3] = $1.to_i(16)
        end
      end
      f.close
    end
    # pp symtab
    symtab
  end

  def mmixstat(mmix_stat, insn, mems, oops, good, bad)

    fn = nil
    # find test function that called
    caller.each do |c|
      if c =~ /`(test_\w+)'/
        fn = $1
        break
      end
    end
    raise "cannot find test fn in #{caller.inspect}" if fn.nil?

    stat = [{
      'insn' => insn,
      'mems' => mems,
      'oops' => oops,
      'good' => good,
      'bad'  => bad,
      'fn'  => fn,
      'when' => Time.now.to_f
    }]

    # cut out YAML header except for first time
    start = !File.exist?(mmix_stat) ? 0 : 4

    File.open(mmix_stat, 'a') do |fd|
      fd.puts stat.to_yaml[start..-1]
    end

  end

  def mmixrun(imagefile)
    symtab = mmixsymtab(imagefile)
    tgt = Target.new
    sp0 = symtab['_SP0']
    sreg = 253
    Open3.popen3("mmix -i #{imagefile}") do |input,output,err|
      input.puts "c"
      input.puts "g#{sreg}"
      line = output.gets
      if line =~ /g\[#{sreg}\]=(\S+)/
        sp = $1.to_i
        raise "oops: stack pointer error - #{sp} > #{sp0}" if sp > sp0
        raise "oops: stack pointer error - #{sp} zero" if sp == 0
        raise "oops: stack pointer error - #{sp} weird" if (sp - sp0).abs > 256
        # pp ["sp", sp, sp0]
        (sp...sp0).step(8) do |n|
          nx=n.to_s(16)
          # pp ["n", n, nx]
          input.puts "M#{nx}"
          line = output.gets
          # pp ["resp", line]
          if line =~ /M8\[#(\S+)\]=(\S+)/
            addr=$1.to_i(16)
            val = $2.to_i
            if addr == n
              # $stderr.puts "pushing #{val}"
              tgt.stack.push(val)
            else
              $stderr.puts "addr #{addr} did not match request #{n}"
            end
          else
            $stderr.puts "Could not handle #{line}"
          end
          sp += 8
        end
      else
        $stderr.puts "Could not handle #{line}"
      end
      input.puts "s"
      line = output.gets
      if line =~ /(\d+)\s+instructions?,\s+(\d+)\s+mems?,\s+(\d+)\s+oops?;\s+(\d+)\s+good guesse?s?,\s+(\d+)\s+bad/
        if !MMIXSTAT.nil?
          mmixstat(MMIXSTAT, $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i)
        end
      else
        $stderr.puts "Could not handle #{line}"
      end
    end
    tgt
  end

  # compile and run 's', return a response
  def exec(s)
    mmixrun(compile(s))
  end

  # return stack in response
  def stack(tgt)
    tgt.stack.reverse.map { |n| signed(n) }
  end


end
