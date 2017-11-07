#
#  cli.rb
#
#  Copyright (c) 2012 by Daniel Kelley
#
#  $Id:$
#

require 'optparse'
require 'gmpforth'

module GMPForth::CLI

  class Args
    attr_reader :op
    attr_reader :limit   
    attr_reader :verbose 
    attr_reader :trace   
    attr_reader :heads   
    attr_reader :image   
    attr_reader :output  
    attr_reader :include 
    attr_reader :lib     
    attr_reader :savetemp
    attr_reader :docdir  
    attr_reader :sysopt  
    attr_reader :opts  
    attr_reader :c  
    attr_reader :rc  
    attr_reader :optimization  

    DEFAULT_OPTIMIZATION = 1
    #
    # Parse ARGV, setting Args attributes as appropriate
    #
    def initialize
      @op=nil
      @limit=1000
      @verbose=nil
      @trace=[]
      @heads=false
      @image=nil
      @output=nil
      @include=[]
      @lib=[]
      @savetemp=false
      @docdir=nil
      @sysopt = {}
      @c = nil
      @sys = nil
      @rc = nil
      @optimization = nil
      @macro = []
      @macro_header = nil
      @constant_module = nil
      @asm_header = nil
      @dependency = nil

      @opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options]"
        opts.on('--scan', '-s', 'Check forth stream file for validity') do
          require 'gmpforth/scanner'
          sys(GMPForth::Scanner)
          @op=:scan
        end
        opts.on('--compile', '-c', 'Compile forth stream file to some form') do
          @op=:compile
        end
        opts.on('--exec', '-e', 'Execute forth stream on VM') do
          @op=:exec
        end
        opts.on('--heads', '-H', 'Compile dictionary headers') do
          @heads=true
        end
        opts.on('--boot IMAGE', '-B', 'Create target boot image') do |arg|
          @image=arg
          @op=:boot
        end
        opts.on('--output FILE', '-o', 'Output to file') do |arg|
          @output=arg
        end
        opts.on('--verbose', '-v', 'Verbose messages') do
          @verbose=true
        end
        opts.on('--limit N', '-N', 'VM step limit') do |arg|
          @limit = arg.to_i
        end
        opts.on('--target MACH', '-t', 'Use <target> for machine') do |arg|
          sys(GMPForth::CLI::target(arg))
        end
        opts.on('--dot', 'Generate DOT file') do
          sys(GMPForth::Compiler)
          @op = :dot
        end
        opts.on('--dep', '-P', 'Generate dependency pairs for tsort') do
          sys(GMPForth::Compiler)
          @op = :dep
        end
        opts.on('--trace FLAG', '-T', 'Set trace flag') do |arg|
          @trace << arg.to_sym
        end
        opts.on('--include DIR', '-I', 'Directory to search for files') do |arg|
          @include << arg
        end
        opts.on('--library-path DIR', '-L', 'Directory to search for libraries') do |arg|
          @lib << arg
        end
        opts.on('--make-index', '-X', 'Make an index file') do
          sys(GMPForth::Compiler)
          @op = :makeindex
        end
        opts.on('--make-dependency=DEP', '-M', 'Make dependency file') do |arg|
          @dependency = arg
        end
        opts.on('--save-temps', '-A', 'Save temporary files') do
          @savetemp=true
        end
        opts.on('--make-doc-template DIR', '-Q', 'Make an document template') do |arg|
          sys(GMPForth::Compiler)
          @op = :make_doc_template
          @docdir = arg
        end
        opts.on('--help', '-h', 'Issue this message') do
          puts opts
          @rc = 0
        end
        opts.on('--endian ENDIAN', '-E', 'Target endian') do |arg|
          @sysopt[:be] = GMPForth::CLI::endian(arg)
        end
        opts.on('--width BYTES', '-W', 'Target data/address bus width') do |arg|
          @sysopt[:dw] = arg.to_i
        end
        opts.on('--target-opt OPTION', '-u', 'Target option') do |arg|
          @sysopt[:target_opt] = arg
        end
        opts.on('--optimize [LEVEL]', '-O', 'Optimization level') do |arg|
          @optimization = arg || DEFAULT_OPTIMIZATION
        end
        opts.on('--define[=MACRO]', '-D[MACRO]', 'Define macro') do |arg|
          @macro << arg
        end
        opts.on('--make-defines=FILE', 'Write macro definitions to C file') do |arg|
          @macro_header = arg
        end
        opts.on('--make-constants=FILE', 'Write Ruby constant definitions to file') do |arg|
          @constant_module = arg
        end
        opts.on('--make-asm-header=FILE', 'Write GAS assembler macro definitions to file') do |arg|
          @asm_header = arg
        end
      end
      @opts.parse! ARGV
    end
    
    #
    # Apply parsed arguments to 'sys'
    #
    def apply(sys=nil)

      if @op.nil?
        @rc = 2
        raise "No operation specified"
      end

      @sys ||= GMPForth::CLI::target('vm')
      @c = @sys.new @sysopt
      @c.include(*@include)  if @include.length > 0 && @c.respond_to?(:include)
      @c.library_path(*@lib) if @lib.length > 0 && @c.respond_to?(:library_path)
      @c.verbose=@verbose    if !@verbose.nil?     && @c.respond_to?(:verbose=)
      @c.display(*@trace)    if @trace.length > 0  && @c.respond_to?(:display)
      @c.run_limit=@limit    if !@limit.nil?    && @c.respond_to?(:run_limit=)
      @c.headless=!@heads    if                    @c.respond_to?(:headless=)
      @c.savetemp=@savetemp  if                    @c.respond_to?(:savetemp=)
      @c.optimize(@optimization) if @c.respond_to?(:optimize)
      @macro.each { |m| macro(m) }

      case op
      when :scan
        @c.scan(*ARGV)
        @c.groom

      when :compile
        @c.scan(*ARGV)
        @c.compile(output)
        @c.macro_header(@macro_header) if !@macro_header.nil?
        @c.constant_module(@constant_module) if !@constant_module.nil?
        @c.asm_header(@asm_header) if !@asm_header.nil?
        @c.dependency(@dependency) if !@dependency.nil?

      when :dot
        @c.scan(*ARGV)
        @c.dot

      when :dep
        @c.scan(*ARGV)
        @c.dep

      when :exec
        @c.scan(*ARGV)
        @c.compile
        @c.run

      when :boot
        @c.hosted = heads
        @c.bootimage = true
        @c.scan(*ARGV)
        @c.compile
        @c.image(image)

      when :makeindex
        @c.scan(*ARGV)
        @c.make_index

      when :make_doc_template
        @c.scan(*ARGV)
        @c.make_doc_template(docdir)

      end
    end
    
    # set @sys to nil if not set; error if already set
    def sys(inp)
      if !@sys.nil?
        @rc = 3
        raise "target already set to #{@sys}"
      end
      @sys = inp
    end

    # add macro K or K=V
    def macro(spec)
      @c.macro(*spec.split('='))
    end

  end

  module_function

  def cli(sys=nil)
    args = GMPForth::CLI::Args.new
    if ARGV.length > 0
      begin
        args.apply(sys)
      rescue
        $stderr.puts $!
        return 2
      end
    else
      return args.rc || 1
    end
    args.c
  end

  # return compiler Class for machine
  def target(machine='vm')
    if machine == 'vm'
      require 'gmpforth/vm'
    end
    require "gmpforth/#{machine}compiler"
    GMPForth::const_get "#{machine.upcase}Compiler"
  end

  # return endian flag
  def endian(arg)
    case arg
    when /^[Bb]/
      return true
    when /^[Ll]/
      return false
    else
      raise "#{arg} not a recognized endian"
    end
  end

  # test arguments
  def sysopt
    @sysopt ||= GMPForth::CLI::Args.new.sysopt
  end


end
