#
#  x86compiler.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# 

require 'gmpforth/gascompiler'

class GMPForth::X86Compiler < GMPForth::GASCompiler

  HERE = File.expand_path(File.dirname(__FILE__))
  ROOT = File.expand_path("#{HERE}/../..")
  SRC  = File.expand_path("#{ROOT}/src")
  GAS  = File.expand_path("#{SRC}/gas")
  I386 = File.expand_path("#{GAS}/i386")

  def initialize(options={})
    @model = "i386"
    @databytes = 4
    @align_arg = :bytes
    super
  end

  #
  #
  #
  def need_user
    # user is ;code
  end

  #
  # Issue code to execute a does list
  #
  def does_comma
    cmt = @hosted ? "  " : "# "
    @handle.puts "#{cmt}      $DODOES"
  end

  #
  # Push a small constant value on the stack
  #
  def push(value)
    @handle.puts "        $PUSH #{value & 0x7f}"
  end

  def run(cmd)
    $stderr.puts(cmd) if @verbose
    if !system(cmd)
      $stderr.puts("#{cmd} returned #{$?}")
      exit $?
    end
  end
  #
  # Create an executable image
  #
  def image(file)
    # done writing
    @handle.close

    # now write outer file
    kernel = tempfile '-krn-'
    
    mod = false
    IO.foreach("#{I386}/kernel.s") do |line|
      if line =~ /^(\s+\.include)\s+"kernel.inc"\s*/
        dot_inc = $1
        if @headless
          kernel.puts "#{dot_inc} \"headless.inc\""
        end
        kernel.puts "#{dot_inc} \"#{@handle.path}\""
        mod = true
      elsif line !~ /^\s*\.end/
        kernel.puts line
      end
    end
    @vardef.each do |vardef|
      kernel.puts "#{Indent}.ifndef #{vardef}"
      kernel.puts "#{Indent}.set #{vardef}, 0"
      kernel.puts "#{Indent}.endif"
    end
    kernel.puts "#{Indent}.end"
    kernel.close

    raise "did not expect kernel.inc in kernel.s" if !mod

    obj = tempfile '-obj-'
    obj.close
    inc = "-I#{I386} -I#{GAS} -I#{ROOT}/include"
    as = "as --32 -g #{inc} -o #{obj.path} #{kernel.path}"

    run(as)
    cc = "cc -m32 -g #{inc} -Wl,-e_start -Wl,-N -nostartfiles -nodefaultlibs -nostdlib -o #{file} #{I386}/start.o #{I386}/io.o #{I386}/trap.o #{obj.path}"

    run(cc)

  end

end
