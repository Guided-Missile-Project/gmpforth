#
#  hayes_test.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

require 'gets_nonblock'
require 'thread'

module HayesTest

  def xfer(fd,file)
    count = 0
    IO.foreach(file) do |line|
      line.chomp!
      $stderr.puts ">>> #{line}" if @verbose > "1"
      fd.write line
      fd.write "\r"
      fd.flush
      @mutex.synchronize { @line.wait(@mutex, @ldelay) }
      break if @fault
      count += 1
    end
    $stderr.puts "### #{file}: sent #{count} lines" if @verbose > "0"
  end

  def listener(fd)
    Thread.new(fd) do |tfd|
      done = false
      while !done do
        begin
          rsp = tfd.gets_nonblock(@gets_time)
          @mutex.synchronize { @line.signal }
        rescue
          $stderr.puts "!!! #{$!}" if  @verbose > "0"
          @fault = true
          break
        end
        $stderr.puts "<<< #{rsp}" if rsp.length > 0 && @verbose > "0"
        if rsp =~ /INCORRECT/ && rsp !~ /= 0= IF S" INCORRECT RESULT: "/
          @incorrect << rsp
        elsif rsp =~ /WRONG NUMBER/ && rsp !~ /S" WRONG NUMBER/
          @incorrect << rsp
        elsif rsp =~ @end_of_test_marker
          @end_of_test = done = true
          if  @verbose > "0"
            $stderr.puts "### Marker '#{@end_of_test_marker}' found"
          end
        end
      end
      $stderr.puts "### Listener done" if  @verbose > "0"
    end
  end

  def wait_for_completion(wait_time)
    start = Time.now
    while (@end_of_test == false) && ((Time.now - start) < wait_time) do
      sleep 0.01
    end
  end

  # end of test marker should be of the form
  # CR .( BLAH BLAH BLAH) CR
  def ht_marker(testfile)
    IO.foreach(testfile) do |line|
      if line =~ /^\s*CR\s\.\(\s(\S+.*)\)/
        marker = $1
        return Regexp.new("^#{marker}")
      end
    end
    raise "no end of test marker"
  end

  # run Hayes test on testfile
  def ht_run(testfile, xfer_delay=10)
    Thread::abort_on_exception = true
    @verbose = ENV['VERBOSE'] || "0"
    @profile = ENV['PROFILE']
    delay_opt = ENV['DELAY']
    @incorrect = []
    @end_of_test_marker = ht_marker(testfile)
    @end_of_test = false
    @fault = false
    xfer_delay = delay_opt.nil? ? xfer_delay : delay_opt.to_f
    @gets_time = !@profile.nil? ? xfer_delay*10 : xfer_delay*20
    @completion_time = @gets_time*5
    @mutex = Mutex.new
    @line = ConditionVariable.new
    testname = File.basename(testfile)
    testsuite = File.basename(File.dirname(testfile))
    arch = File.basename(File.dirname(@image))
    if !@profile.nil?
      dir = ENV['PROFILE_OUTPUT'] || '.'
      image = "#{@profile} -o #{dir}/P-#{arch}-#{testsuite}-#{testname}.y #{@image}"
      @ldelay = @ldelay * 100.0
      STDERR.puts image
    else
      image = @image
    end
    IO.popen(image, "w+") do |fd|
      listener(fd)
      xfer(fd,"src/test/hayes/tester.fr")
      if File.basename(testfile) != 'core.fr'
        # tests other than core require the following
        xfer(fd,"src/test/hayes/errorreport.fth")
        xfer(fd,"src/test/hayes/utilities.fth")
      end
      xfer(fd,testfile)
      wait_for_completion(@completion_time)
    end
    @incorrect
  end

end
