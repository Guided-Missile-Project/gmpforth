#
#  armcompiler.rb
# 
#  Copyright (c) 2013 by Daniel Kelley
# 
# 

require 'gmpforth/gascompiler'

class GMPForth::ARMCompiler < GMPForth::GASCompiler

  HERE = File.expand_path(File.dirname(__FILE__))
  ROOT = File.expand_path("#{HERE}/../..")
  SRC  = File.expand_path("#{ROOT}/src")
  GAS  = File.expand_path("#{SRC}/gas")
  MACH = File.expand_path("#{GAS}/arm")

  def initialize(options={})
    @submodel = options[:target_opt] || "a32"
    @model = "arm"
    @arch = @submodel == "a64" ? "aarch64" : "arm"
    @cross_env = @submodel == "a64" ? "CROSS_A64" : "CROSS_A32"
    @cross = ENV[@cross_env] || "#{@arch}-elf-"
    @databytes = @submodel == "a64" ? 8 : 4
    @as = "#{@cross}as"
    @ld = "#{@cross}ld"
    @abi = @submodel == "a64" ? "" : "-meabi=5"
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
      exit $?.to_i
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
    IO.foreach("#{GAS}/common/kernel.s") do |line|
      if line =~ /^(\s+\.include)\s+"kernel.inc"\s*/
        # substitute generated kernel for default
        dot_inc = $1
        kernel.puts "#{dot_inc} \"#{@handle.path}\""
        mod = true
      elsif line =~ /^(\s+\.include)\s+"pre.inc"\s*/
        # add headless before pre.inc
        dot_inc = $1
        if @headless
          kernel.puts "#{dot_inc} \"headless.inc\""
        end
        kernel.puts line
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
    listing = tempfile '-lst-'
    listing.close

    inc = "-I#{GAS} -I#{GAS}/common -I#{GAS}/c10 -I#{MACH}/common -I#{MACH}/#{@submodel} -I#{ROOT}/include"
    asflags = "-g #{@abi} -aldm=#{listing.path}"
    ldflags = "-g"
    if @submodel != "a64"
      # turn of deprecated feature warning; it's a red herring and
      # they'll be seen on the full image build anyway
      asflags += " -mno-warn-deprecated"
    end
    if @submodel == "t32"
      ldflags += " --thumb-entry=_start"
    end

    as = "#{@as} #{asflags} #{inc} -o #{obj.path} #{kernel.path}"
    run(as)
    ld = "#{@ld} #{ldflags} -o #{file} #{obj.path}"
    run(ld)

  end

end
