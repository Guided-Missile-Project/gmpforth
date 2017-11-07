#
#  mi2.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# GDB MI2 protocol interface
#
# zero or more out-of-band records followed by result
#
# 

require 'gdb/gdb'
require 'gets_nonblock'
require 'pp'

class GDB::MI2

  DEFAULT_GETS_TIMEOUT = 5

  attr_accessor :verbose
  attr_accessor :timeout

  class Record
    attr_accessor :token
    attr_accessor :value
    attr_reader :kind
    attr_reader :stream
    attr_reader :info

    RECORD_TYPE = {
      '^' => :result,
      '*' => :exec,
      '+' => :status,
      '=' => :notify,
      '~' => :console,
      '@' => :target,
      '&' => :log
    }

    STREAM = [ :console, :target, :log ]

    def initialize
      @token = nil
      @kind = :unknown
      @value = nil
      @info = nil
      @stream = false
    end

    def kind=(char)
      @kind = RECORD_TYPE[char]
      raise "Unknown record type '#{char}'" if @kind.nil?
      @stream = STREAM.include?(@kind)
      @info = '' if !@stream
    end
    
    def append(record)
      if @kind != record.kind
        raise "record mismatch: expected #{@kind} but got #{record.kind}"
      end
      @value << record.value
    end

  end

  class Parse
    attr_reader :record

    def initialize
      @record = Record.new
      @data = ''
      @value = ''
      @token = ''
      @state = [:token]
      @openbrace = 0
    end
    
    def token(c, idx)
      if c =~ /\d/
        @token << c
      else
        @record.token = @token.to_i if @token.length > 0
        @record.kind = c
        @state[-1] = @record.stream ? :stream : :rclass
      end
    end

    def rclass(c, idx)
      case c
      when /\w/, '-'
        @record.info << c
      when "\n"
        @state[-1] = :done
      when ','
        @state[-1] = :variable
        @data << '{' # start result hash
        @data << "'" # start key string
        @openbrace += 1
      else
        raise "char '#{c}'@#{idx} unexpected in #{@state}"
      end
    end

    def variable(c, idx)
      case c
      when /\w/, '-'
        @data << c
      when '='
        @state[-1] = (@state[-1] == :variable) ? :value_tuple : :value
        @data << "'" # end key string
        @data << '=>' # start hash key
      else
        raise "char '#{c}'@#{idx} unexpected in #{@state}"
      end
    end

    def value(c, idx)
      case c
      when '"'
        @state << :string
        @value = ''
      when '['
        @state << :value
        @data << c
      when '{'
        @state << :variable
        @data << c
        @data << "'" # start key string
      when '}', ']'
        @data << c
        @state.pop
      when ','
        @data << c
        if @state[-1] == :value_tuple
          @state[-1] = :variable
          @data << "'" # start key string
        end
      when /\w/
        # really a variable
        @state[-1] = :variable
        @data << "'"
        variable(c, idx)
      when /\s/
        # ignore whitespace
      else
        raise "char '#{c}'@#{idx} unexpected in #{@state}"
      end
    end

    alias :value_tuple :value
    alias :stream :value

    def escape(c, idx)
      @state.pop
      case @state[-1]
      when :string
        @value << c
      else
        @data << c
      end
    end

    def string(c, idx)
      case c
      when '\\'
        @value << c
        @state << :escape
      when '"'
        case @value
        when /^0x[0-9a-fA-F]+$/, /^-?\d+$/
          @data << @value
        else
          # otherwise keep as quoted string
          @data << "'"
          @data << @value
          @data << "'"
        end
        @state.pop
        
        case @state
        when :stream
          @state[-1] = :done
        end
      else
        @value << c
      end
    end

    def done(c, idx)
      raise "char #{c} unexpected in #{@state[-1]}"
    end

    def parse(str)
      str.length.times do |idx|
        c = str[idx].chr
        send(@state[-1], c, idx)
      end

      # Much of the data format is so close to Ruby data syntax, is
      # doesn't seem worth it to construct a separate parser for it;
      # faster to transform to Ruby syntax and evaluate.

      if !@record.stream && @openbrace > 0
        @openbrace.times do
          @data << '}' # close result hash if not stream data
        end
      end
      if @data.length > 0
        begin
          @record.value = eval(@data)
        rescue Exception
          $stderr.puts "error evaluating '#{@data}' from '#{str}'"
          raise
        end
      elsif @record.stream
        @record.value = ''
      end

    end
  end

  class Result
    attr_accessor :result
    attr_accessor :exec
    attr_accessor :status
    attr_accessor :notify
    attr_accessor :console
    attr_accessor :target
    attr_accessor :log
    attr_accessor :verbose

    def initialize
      @result = nil
      @exec = nil
      @status = nil
      @notify = nil
      @console = nil
      @target = nil
      @log = nil
      @verbose = false
    end

    def parse_line(str)
      $stderr.puts "Parsing #{str}" if @verbose
      parse = Parse.new

      parse.parse(str)

      case parse.record.kind
      when :result
        raise 'result already set' if !@result.nil?
        @result = parse.record
      when :exec
        raise 'exec already set' if !@exec.nil?
        @exec = parse.record
      when :status
        raise 'status already set' if !@status.nil?
        @status = parse.record
      when :notify
        if @notify.nil?
          @notify = []
        end
        @notify << parse.record
      when :console
        if @console.nil?
          @console = parse.record
        else
          @console.append(parse.record)
        end
      when :target
        if @target.nil?
          @target = parse.record
        else
          @target.append(parse.record)
        end
      when :log
        if @log.nil?
          @log = parse.record
        else
          @log.append(parse.record)
        end
      else
        raise "unexpected record kind #{parse.record.kind}"
      end
    end
  end

  END_MARKER = /^\(gdb\)/

  def initialize(input, output=input)
    @input = input
    @output = output
    @verbose = false
    @timeout = DEFAULT_GETS_TIMEOUT
  end

  def send(command)
    $stderr.puts "Sending #{command}" if @verbose
    @input.puts command
  end

  def receive(verbose = false)
    res = Result.new
    res.verbose = @verbose || verbose
    loop do
      rsp = @output.gets_nonblock(@timeout, @verbose)
      break if rsp.nil? || rsp =~ END_MARKER
      res.parse_line(rsp.chomp)
    end

    res
  end

end


