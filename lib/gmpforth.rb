#
#  gmpforth.rb
# 
#  Copyright (c) 2010 by Daniel Kelley
# 
#  $Id:$
#
# GMP Forth high level emulator
#
# (1) Bootstrap phase reads forth code and tokenizes words into text form.
#     This reads forth syntax, but may contain forward references. 
#     Comments are stripped out, and then is tokenized. This tokenized
#     form is then divided into words based on a fixed set of defining words
#     and then forward references are resolved iteratively until there are
#     no more resolutions.
#
#     At this point everything is divided into words.
#
# (2) Compile phase 
#

module GMPForth
end

require 'gmpforth/scanner'
require 'gmpforth/compiler'
require 'gmpforth/exception'
require 'gmpforth/constants'
require 'gmpforth/vm'
require 'gmpforth/vmcompiler'
