#
#  test_coverage.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
#  $Id:$
#

require 'vmcompiler'

class TestVMCoverage < Test::Unit::TestCase

  def test_zzzzzzzz
    at_exit { GMPForth::VMCompiler.needs_coverage }
  end

end
