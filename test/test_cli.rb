#
#  test_cli.rb
# 
#  Copyright (c) 2012 by Daniel Kelley
# 
#  $Id:$
#
#  test CLI appl called from test_top_cli.rb.
#

require 'pp'
require 'gmpforth/cli'

file = ENV["GMPFORTH_TEST_CLI_OBJ"] || "GMPFORTH_TEST_CLI_OBJ"
tgt  = ENV["GMPFORTH_TEST_CLI_TGT"]

File.open(file, 'w') do |f|
  if tgt.nil?
    c = GMPForth::CLI.cli
  elsif tgt == '-'
    c = GMPForth::CLI.target
  else
    c = GMPForth::CLI.target(tgt)
  end
  begin
    f.write Marshal.dump(c)
  rescue
    pp c
    f.rewind
    f.write Marshal.dump($!)
  end
end
