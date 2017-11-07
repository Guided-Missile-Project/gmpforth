#
#  vmdict.rb
#
#  Copyright (c) 2011 by Daniel Kelley
#
#  $Id:$
#

require 'pp'

module VMDict

  extend NoRedef

  DICT = [
    "test",
    "catch",
    "throw",
    "(\",)",
    "refill",
    "query",
    "(find)",
    "source-id",
    "definitions",
    "set-current",
    "search-wordlist",
    "(search-wordlist)",
    "(match-name)",
    ">name",
    "link>",
    "n>link",
    "l>name",
    "restore-input",
    "save-input",
    "(#i)",
    "compile,",
    "latest",
    "cs-roll",
    "cs-pick",
    "/string",
    "<>",
    "0<>",
    "casecompare",
    "sgn",
    "?do immediate compile-only",
    "again immediate compile-only",
    "pad",
    "parse",
    "parse-name",
    "(skip)",
    "(input)",
    "] immediate",
    "[char] immediate compile-only",
    "['] immediate compile-only",
    "[ immediate compile-only",
    "while immediate compile-only",
    "until immediate compile-only",
    "u.",
    "type",
    "then immediate compile-only",
    "spaces",
    "space",
    "source",
    "sign",
    "s>d",
    "s\" immediate",
    "rshift",
    "repeat immediate compile-only",
    "recurse immediate compile-only",
    "quit",
    "postpone immediate compile-only",
    "negate",
    "move",
    "within",
    "cmove>",
    "cmove",
    "bounds",
    "min",
    "max",
    "lshift",
    "loop immediate compile-only",
    "literal immediate compile-only",
    "?leave immediate compile-only",
    "leave immediate compile-only",
    "key",
    "compile-only",
    "immediate",
    "smudge",
    "ctoggle",
    "creset",
    "cset",
    "if immediate compile-only",
    "hold",
    "here",
    "fill",
    "evaluate",
    "((evaluate))",
    "(evaluate)",
    "number?",
    "(number?)",
    "(number) compile-only",
    "(word) compile-only",
    "($evaluate)",
    "((s\"))",
    "environment?",
    "emit",
    "else immediate compile-only",
    "does> immediate compile-only",
    "name>",
    "do immediate compile-only",
    "dnegate",
    "hex",
    "decimal",
    "(create)",
    "(?name)",
    "cr",
    "count",
    "chars immediate",
    "char+",
    "char",
    "cells",
    "cell-",
    "cell+",
    "c,",
    "begin immediate compile-only",
    "allot",
    "aligned",
    "align",
    "ahead immediate compile-only",
    "<resolve",
    "<mark",
    ">resolve",
    ">mark",
    "accept",
    "abs",
    "abort\" immediate compile-only",
    "(abort\") compile-only",
    "abort",
    "?dup",
    ">number",
    "d+-",
    "+-",
    "digit",
    "toupper",
    ">body",
    ">",
    "=",
    "<#",
    "; immediate compile-only",
    "2swap",
    "2over",
    "2dup",
    "2drop",
    "2@",
    "2!",
    "1-",
    "1+",
    ".\" immediate",
    ".",
    ",",
    "+loop immediate compile-only",
    "+!",
    "( immediate",
    "'",
    "#s",
    "#>",
    "#",
    "dabs",
    "ut/mod",
    "ut*",
    "ud/mod",
    "(reset)",
    "(urx?)",
    "(urx@)",
    "(utx?)",
    "(utx!)",
    "(quit)",
    "(error)",
    "(respond)",
    "(interpret)",
    "gmpforth",
    "1",
    "0",
    "false",
    "true",
    "(lex-max-name)",
    "(lex-compile-only)",
    "(lex-immediate)",
    "(lex-start)",
    "(error-write-line)",
    "(error-write-file)",
    "(error-resize-file)",
    "(error-reposition-file)",
    "(error-rename-file)",
    "(error-read-line)",
    "(error-read-file)",
    "(error-open-file)",
    "(error-flush-file)",
    "(error-file-status)",
    "(error-file-size)",
    "(error-file-position)",
    "(error-delete-file)",
    "(error-create-file)",
    "(error-close-file)",
    "(error-resize)",
    "(error-free)",
    "(error-allocate)",
    "(error-fpp)",
    "(error-char)",
    "(error-quit)",
    "(error-float-fault)",
    "(error-float-o)",
    "(error-exception-o)",
    "(error-control-o)",
    "(error-changed)",
    "(error-search-u)",
    "(error-search-o)",
    "(error-postpone)",
    "(error-deleted)",
    "(error-float-invalid)",
    "(error-float-stack-u)",
    "(error-float-stack-o)",
    "(error-float-range)",
    "(error-float-div)",
    "(error-precision)",
    "(error-base)",
    "(error-eof)",
    "(error-file-not-found)",
    "(error-file-io)",
    "(error-file-pos)",
    "(error-blk-invalid)",
    "(error-blk-write)",
    "(error-blk-read)",
    "(error-name-a)",
    "(error-body)",
    "(error-obsolete)",
    "(error-nesting)",
    "(error-interrupt)",
    "(error-recursion)",
    "(error-loop-u)",
    "(error-return-i)",
    "(error-num)",
    "(error-align)",
    "(error-control)",
    "(error-unsupported)",
    "(error-read-only)",
    "(error-def-o)",
    "(error-string-o)",
    "(error-num-o)",
    "(error-no-name)",
    "(error-forget)",
    "(error-compile-only)",
    "(error-undef)",
    "(error-type)",
    "(error-range)",
    "(error-div)",
    "(error-mem)",
    "(error-dict)",
    "(error-do)",
    "(error-return-u)",
    "(error-return-o)",
    "(error-stack-u)",
    "(error-stack-o)",
    "(error-abort\")",
    "(error-abort)",
    "bl",
    "(=cr)",
    "(=lf)",
    "(=rub)",
    "(=bs)",
    "(vocs)",
    "current",
    "context",
    "(abort\"$)",
    "(scratch)",
    "tib",
    "erf",
    "dpl",
    "(rp0)",
    "(sp0)",
    "(boot)",
    "(tx!)",
    "(tx?)",
    "(rx@)",
    "(rx?)",
    "(here)",
    "(hld)",
    "base",
    "state",
    ">in",
    "blk",
    ">in-",
    "(#line)",
    "(srcid)",
    "(src@)",
    "(src)",
    "(srcend)",
    "(src0)",
    "(#user)",
    "forth",
    "vocabulary",
    "wordlist",
    "?stack",
    "m*/",
    "(pad)",
    "(cell)",
    "user",
    "(does,)",
    "constant",
    "variable",
    ":",
    "create",
    "(;code) compile-only",
    "(io)",
    "d-",
    "d+",
    "nr> compile-only",
    "n>r compile-only",
    "2r> compile-only",
    "2r@ compile-only",
    "2>r compile-only",
    "m+",
    "u2/",
    "2/",
    "2*",
    "<",
    "0<",
    "0=",
    "xor",
    "unloop compile-only",
    "um/mod",
    "um*",
    "u<",
    "or",
    "invert",
    "and",
    "/mod",
    "/",
    "-",
    "+",
    "*/mod",
    "*/",
    "*",
    "j compile-only",
    "i compile-only",
    "(loop) compile-only",
    "(leave) compile-only",
    "(do) compile-only",
    "(+loop) compile-only",
    "(?do) compile-only",
    "exit compile-only",
    "execute",
    "bye",
    "(s\") compile-only",
    "(dolit) compile-only",
    "(branch) compile-only",
    "(0branch) compile-only",
    "swap",
    "rot",
    "roll",
    "r@ compile-only",
    "r> compile-only",
    "pick",
    "over",
    "dup",
    "drop",
    "depth",
    ">r compile-only",
    "-rot",
    "sp@",
    "rp@",
    "sp!",
    "rp!",
    "c@",
    "c!",
    "@",
    "!"
  ]

  def test_dict_001
    @vc.parse ": test ;"
    @vc.compile
    dict_out = @vc.dict
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(DICT, dict_out)
  end

# current
  def test_dict_002
    @vc.parse(": test current @ ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_not_equal(0, @vc.vm.tos)
    wid = @vc.vm.tos
    assert_equal(@vc.pfa('forth'), wid)
  end

  def test_dict_002_1
    @vc.parse(": test current @ @ ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_not_equal(0, @vc.vm.tos)
    assert_equal(@vc.lfa('test'), @vc.vm.tos)
  end

  def test_dict_002_2
    @vc.parse(": test current @ @ l>name ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_not_equal(0, @vc.vm.tos)
    assert_equal(@vc.nfa('test'), @vc.vm.tos)
  end

  def test_dict_002_3
    @vc.parse(": test current @ @ l>name latest = ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
  end

# context
  def test_dict_003
    @vc.parse(": test current @ context @ = ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
  end

# (context) removed
# test_dict_004*

# latest
  def test_dict_005
    @vc.parse(": test latest count (lex-max-name) and ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_not_equal(0, @vc.vm.nos)
    buf = @vc.vm.nos
    assert_equal(4, @vc.vm.tos)
    assert_equal(DICT[0][0].ord,  @vc.vm.c_fetch(buf + 0))
    assert_equal(DICT[0][1].ord,  @vc.vm.c_fetch(buf + 1))
    assert_equal(DICT[0][2].ord,  @vc.vm.c_fetch(buf + 2))
    assert_equal(DICT[0][3].ord,  @vc.vm.c_fetch(buf + 3))
  end

  def test_dict_005_1
    @vc.parse <<EOF
: test
    1 latest n>link begin @ ?dup while swap 1+ swap repeat ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(DICT.length, @vc.vm.tos)
  end

# name>
  def test_dict_006
    @vc.parse(": test latest name> ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.tick('test'), @vc.vm.tos)
  end

  def test_dict_006_1
    @vc.parse(": tes latest name> ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.tick('tes'), @vc.vm.tos)
  end

  def test_dict_006_2
    @vc.parse(": te latest name> ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.tick('te'), @vc.vm.tos)
  end

  def test_dict_006_3
    @vc.parse(": t latest name> ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.tick('t'), @vc.vm.tos)
  end

  def test_dict_006_4
    @vc.parse(": t latest name> ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.tick('t'), @vc.vm.tos)
  end

  def test_dict_006_5
    @vc.parse(": testx latest name> ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.tick('testx'), @vc.vm.tos)
  end

  def test_dict_006_6
    @vc.parse(": testxy latest name> ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.tick('testxy'), @vc.vm.tos)
  end

  def test_dict_006_7
    @vc.parse(": testxyz latest name> ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.tick('testxyz'), @vc.vm.tos)
  end

# search-wordlist
  def test_dict_007
    @vc.parse <<EOF
: test
   s" catch" context @ search-wordlist ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@vc.tick('catch'), @vc.vm.nos)
  end

  def test_dict_007_1
    @vc.parse <<EOF
: test
   s" do" context @ search-wordlist ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(@vc.tick('do'), @vc.vm.nos)
  end

  def test_dict_007_2
    @vc.parse <<EOF
: test
   s" !" context @ search-wordlist ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
    assert_equal(@vc.tick('!'), @vc.vm.nos)
  end

  def test_dict_007_3
    @vc.parse <<EOF
: test
   s" foobar" context @ search-wordlist ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

# '
  def test_dict_008
    @vc.parse <<EOF
: test
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! ( ' )
   refill if ' then ;
EOF
    @vc.compile
    inp = "   catch  \r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.tick('catch'), @vc.vm.tos)
  end

  def test_dict_008_1
    @vc.parse <<EOF
: setup
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! ;
: search
   refill if ' then ;
: test
   setup ['] search catch ;
EOF
    @vc.compile
    inp = "   !  \r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(@vc.tick('!'), @vc.vm.nos)
  end

  def test_dict_008_2
    @vc.parse <<EOF
: setup
   ['] (utx!) (tx!) ! ['] (urx@) (rx@) ! ;
: search
   refill if ' then ;
: test
   setup ['] search catch ;
EOF
    @vc.compile
    inp = "   foo  \r"
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-13, @vc.vm.signed(@vc.vm.tos))
  end

# >name
  def test_dict_009
    @vc.parse(": test ['] catch >name ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.nfa('catch'), @vc.vm.tos)
  end

  def test_dict_009_1
    @vc.parse(": test ['] if >name ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.nfa('if'), @vc.vm.tos)
  end

  def test_dict_009_2
    @vc.parse(": test ['] ( >name ;")
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.nfa('('), @vc.vm.tos)
  end

# (find)
  def test_dict_010
    @vc.parse <<EOF
: test
   s" catch" (find) ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    flag  = GMPForth::VMCompiler::SFLAG
    flag += 5
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(flag, @vc.vm.tos)
    assert_equal(@vc.tick('catch'), @vc.vm.nos)
  end

  def test_dict_010_1
    @vc.parse <<EOF
: test
   s" do" (find) ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    flag  = GMPForth::VMCompiler::SFLAG
    flag += GMPForth::VMCompiler::IFLAG
    flag += GMPForth::VMCompiler::CFLAG
    flag += 2
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(flag, @vc.vm.tos)
    assert_equal(@vc.tick('do'), @vc.vm.nos)
  end

  def test_dict_010_2
    @vc.parse <<EOF
: test
   s" !" (find) ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    flag  = GMPForth::VMCompiler::SFLAG
    flag += 1
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(flag, @vc.vm.tos)
    assert_equal(@vc.tick('!'), @vc.vm.nos)
  end

  def test_dict_010_3
    name = "foobar"
    @vc.parse <<EOF
: test
    s" #{name}" (find) ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(6, @vc.vm.nos)
    assert_not_equal(0, @vc.vm.pick(2))
    buf = @vc.vm.pick(2)
    assert_equal(name[0].ord,  @vc.vm.c_fetch(buf + 0))
    assert_equal(name[1].ord,  @vc.vm.c_fetch(buf + 1))
    assert_equal(name[2].ord,  @vc.vm.c_fetch(buf + 2))
    assert_equal(name[3].ord,  @vc.vm.c_fetch(buf + 3))
    assert_equal(name[4].ord,  @vc.vm.c_fetch(buf + 4))
    assert_equal(name[5].ord,  @vc.vm.c_fetch(buf + 5))

  end

  def test_dict_010_4
    name = "foobar"
    @vc.parse <<EOF
: fill-context
   current context cell+ do context @ I ! (cell) +loop ;
: test
   fill-context s" #{name}" (find) ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1125
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(6, @vc.vm.nos)
    assert_not_equal(0, @vc.vm.pick(2))
    buf = @vc.vm.pick(2)
    assert_equal(name[0].ord,  @vc.vm.c_fetch(buf + 0))
    assert_equal(name[1].ord,  @vc.vm.c_fetch(buf + 1))
    assert_equal(name[2].ord,  @vc.vm.c_fetch(buf + 2))
    assert_equal(name[3].ord,  @vc.vm.c_fetch(buf + 3))
    assert_equal(name[4].ord,  @vc.vm.c_fetch(buf + 4))
    assert_equal(name[5].ord,  @vc.vm.c_fetch(buf + 5))
    context = @vc.fetch_user('context')
    assert_not_equal(0, context)
    assert_equal(context, @vc.fetch_user('context', @vc.cells(1)))
    assert_equal(context, @vc.fetch_user('context', @vc.cells(2)))
    assert_equal(context, @vc.fetch_user('context', @vc.cells(3)))
    assert_equal(context, @vc.fetch_user('context', @vc.cells(4)))
    assert_equal(context, @vc.fetch_user('context', @vc.cells(5)))
    assert_equal(context, @vc.fetch_user('context', @vc.cells(6)))
    assert_equal(context, @vc.fetch_user('context', @vc.cells(7)))
  end


# (evaluate)
  def test_dict_011
    # n-i interp
    @vc.parse <<EOF
: test1 10 ;
: test
   s" test1" ($evaluate) ['] (evaluate) catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
  end

  def test_dict_011_01
    # i   interp
    @vc.parse <<EOF
: test1 10 ; immediate
: test
   s" test1" ($evaluate) ['] (evaluate) catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
  end

  def test_dict_011_02
    # i+c interp
    @vc.parse <<EOF
: test1 10 ; immediate compile-only
: test
   s" test1" ($evaluate) ['] (evaluate) catch ; ( ' )
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-14, @vc.vm.signed(@vc.vm.tos)) # compile-only
    # cannot make any assumptions about the values of the rest 
    # of the stack because an exception was thrown
  end

  def test_dict_011_03
    # n/f interp
    @vc.parse <<EOF
: test
   s" test1" ($evaluate) ['] (evaluate) catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-13, @vc.vm.signed(@vc.vm.tos))
    # cannot make any assumptions about the values of the rest 
    # of the stack because an exception was thrown
  end

  def test_dict_011_04_01
    # s#  interp
    @vc.parse <<EOF
: test  s" 10" ($evaluate) ['] (evaluate) catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
    # DPL
    assert_equal(@m1, @vc.fetch_user('dpl'))
  end

  def test_dict_011_04_02
    # s#  interp
    @vc.parse <<EOF
: test  s" -10" ($evaluate) ['] (evaluate) catch ; ( ' )
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(-10, @vc.vm.signed(@vc.vm.nos))
    # DPL
    assert_equal(@m1, @vc.fetch_user('dpl'))
  end

  def test_dict_011_05_01
    # d#  interp
    @vc.parse <<EOF
: test  s" 1.0" ($evaluate) ['] (evaluate) catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(10, @vc.vm.pick(2))
    # DPL
    assert_equal(1, @vc.fetch_user('dpl'))
  end

  def test_dict_011_05_02
    # d#  interp
    @vc.parse <<EOF
: test  s" 1.00" ($evaluate) ['] (evaluate) catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(100, @vc.vm.pick(2))
    # DPL
    assert_equal(2, @vc.fetch_user('dpl'))
  end

  def test_dict_011_05_03
    # d#  interp
    @vc.parse <<EOF
: test  s" -1.0" ($evaluate) ['] (evaluate) catch ; ( ' )
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(-10, @vc.vm.signed(@vc.vm.pick(2)))
    # DPL
    assert_equal(1, @vc.fetch_user('dpl'))
  end

  def test_dict_011_05_04
    # d#  interp
    @vc.parse <<EOF
: test  s" -1.00" ($evaluate) ['] (evaluate) catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(-100, @vc.vm.signed(@vc.vm.pick(2)))
    # DPL
    assert_equal(2, @vc.fetch_user('dpl'))
  end

  def test_dict_011_06
    # ?#  interp
    @vc.parse <<EOF
: test  s" 1x0" ($evaluate) ['] (evaluate) catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-13, @vc.vm.signed(@vc.vm.tos))
  end

  def test_dict_011_07
    # multiple words
    @vc.parse <<EOF
: test  s" 1 2 +" ($evaluate) ['] (evaluate) catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(3, @vc.vm.nos)
  end

  def test_dict_011_08
    # n-i compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test
   here s" +" ($evaluate) ['] (evaluate) ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(@vc.tick('+'), @vc.vm.fetch(@vc.vm.nos))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.nos + @vc.vm.databytes)
  end

  def test_dict_011_09
    # i   compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test1 10 ; immediate

: test
   here s" test1" ($evaluate) ['] (evaluate) ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
    assert_not_equal(0, @vc.vm.pick(2))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.pick(2))
  end

  def test_dict_011_10
    # i+c compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test1 10 ; immediate compile-only

: test
   here s" test1" ($evaluate) ['] (evaluate) ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
    assert_not_equal(0, @vc.vm.pick(2))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.pick(2))
  end

  def test_dict_011_11
    # n/f compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test
   here s" test1" ($evaluate) ['] (evaluate) ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(-13, @vc.vm.signed(@vc.vm.tos))
  end

  def test_dict_011_12
    # s#  compile
    @vc.parse <<EOF

: ]]  -1 state ! ;

: test
   here s" 10" ($evaluate) ['] (evaluate) ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(@vc.tick('(dolit)'), @vc.vm.fetch(@vc.vm.nos))
    assert_equal(10, @vc.vm.fetch(@vc.vm.nos + @vc.vm.databytes))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.nos + (2*@vc.vm.databytes))
  end

  def test_dict_011_13
    # d#  compile
    @vc.parse <<EOF

: ]]  -1 state ! ;

: test
   here s" 1.0" ($evaluate) ['] (evaluate) ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(@vc.tick('(dolit)'), @vc.vm.fetch(@vc.vm.nos))
    assert_equal(10, @vc.vm.fetch(@vc.vm.nos + @vc.vm.databytes))
    assert_equal(@vc.tick('(dolit)'), @vc.vm.fetch(@vc.vm.nos + (2*@vc.vm.databytes)))
    assert_equal(0, @vc.vm.fetch(@vc.vm.nos + (3*@vc.vm.databytes)))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.nos + (4*@vc.vm.databytes))
  end

  def test_dict_011_14
    # ?#  compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test
   here s" 1x0" ($evaluate) ['] (evaluate) ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(-13, @vc.vm.signed(@vc.vm.tos))
  end


# evaluate
  def test_dict_012
    # n-i interp
    @vc.parse <<EOF
: test1 10 ;
: test
   s" test1" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
  end

  def test_dict_012_01
    # i   interp
    @vc.parse <<EOF
: test1 10 ; immediate
: test
   s" test1" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
  end

  def test_dict_012_02
    # i+c interp
    @vc.parse <<EOF
: test1 10 ; immediate compile-only
: test
   s" test1" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(-14, @vc.vm.signed(@vc.vm.tos)) # compile-only
    # cannot make any assumptions about the values of the rest 
    # of the stack because an exception was thrown
  end

  def test_dict_012_03
    # n/f interp
    @vc.parse <<EOF
: test
   s" test1" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(-13, @vc.vm.signed(@vc.vm.tos))
    # cannot make any assumptions about the values of the rest 
    # of the stack because an exception was thrown
  end

  def test_dict_012_04_01
    # s#  interp
    @vc.parse <<EOF
: test  s" 10" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
    # DPL
    assert_equal(@m1, @vc.fetch_user('dpl'))
  end

  def test_dict_012_04_02
    # s#  interp
    @vc.parse <<EOF
: test  s" -10" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(-10, @vc.vm.signed(@vc.vm.nos))
    # DPL
    assert_equal(@m1, @vc.fetch_user('dpl'))
  end

  def test_dict_012_05_01
    # d#  interp
    @vc.parse <<EOF
: test  s" 1.0" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(10, @vc.vm.pick(2))
    # DPL
    assert_equal(1, @vc.fetch_user('dpl'))
  end

  def test_dict_012_05_02
    # d#  interp
    @vc.parse <<EOF
: test  s" 1.00" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(100, @vc.vm.pick(2))
    # DPL
    assert_equal(2, @vc.fetch_user('dpl'))
  end

  def test_dict_012_05_03
    # d#  interp
    @vc.parse <<EOF
: test  s" -1.0" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(-10, @vc.vm.signed(@vc.vm.pick(2)))
    # DPL
    assert_equal(1, @vc.fetch_user('dpl'))
  end

  def test_dict_012_05_04
    # d#  interp
    @vc.parse <<EOF
: test  s" -1.00" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(@m1, @vc.vm.nos)
    assert_equal(-100, @vc.vm.signed(@vc.vm.pick(2)))
    # DPL
    assert_equal(2, @vc.fetch_user('dpl'))
  end

  def test_dict_012_06
    # ?#  interp
    @vc.parse <<EOF
: test  s" 1x0" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(-13, @vc.vm.signed(@vc.vm.tos))
  end

  def test_dict_012_07
    # multiple words
    @vc.parse <<EOF
: test  s" 1 2 +" ['] evaluate catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(3, @vc.vm.nos)
  end

  def test_dict_012_08
    # n-i compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test
   here s" +" ['] evaluate ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(@vc.tick('+'), @vc.vm.fetch(@vc.vm.nos))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.nos + @vc.vm.databytes)
  end

  def test_dict_012_09
    # i   compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test1 10 ; immediate

: test
   here s" test1" ['] evaluate ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
    assert_not_equal(0, @vc.vm.pick(2))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.pick(2))
  end

  def test_dict_012_10
    # i+c compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test1 10 ; immediate compile-only

: test
   here s" test1" ['] evaluate ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
    assert_not_equal(0, @vc.vm.pick(2))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.pick(2))
  end

  def test_dict_012_11
    # n/f compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test
   here s" test1" ['] evaluate ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(-13, @vc.vm.signed(@vc.vm.tos))
  end

  def test_dict_012_12
    # s#  compile
    @vc.parse <<EOF

: ]]  -1 state ! ;

: test
   here s" 10" ['] evaluate ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(@vc.tick('(dolit)'), @vc.vm.fetch(@vc.vm.nos))
    assert_equal(10, @vc.vm.fetch(@vc.vm.nos + @vc.vm.databytes))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.nos + (2*@vc.vm.databytes))
  end

  def test_dict_012_13
    # d#  compile
    @vc.parse <<EOF

: ]]  -1 state ! ;

: test
   here s" 1.0" ['] evaluate ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_not_equal(0, @vc.vm.nos)
    assert_equal(@vc.tick('(dolit)'), @vc.vm.fetch(@vc.vm.nos))
    assert_equal(10, @vc.vm.fetch(@vc.vm.nos + @vc.vm.databytes))
    assert_equal(@vc.tick('(dolit)'), @vc.vm.fetch(@vc.vm.nos + (2*@vc.vm.databytes)))
    assert_equal(0, @vc.vm.fetch(@vc.vm.nos + (3*@vc.vm.databytes)))
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.nos + (4*@vc.vm.databytes))
  end

  def test_dict_012_14
    # ?#  compile
    @vc.parse <<EOF

: ]] -1 state ! ;

: test
   here s" 1x0" ['] evaluate ]] catch ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(4, @vc.vm.depth)
    assert_equal(-13, @vc.vm.signed(@vc.vm.tos))
  end

  def test_dict_012_15
    # nested evaluate
    @vc.parse <<EOF

: test15 s" 15 " evaluate ;

: test
     s" 10 test15 20 " evaluate ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(20, @vc.vm.tos)
    assert_equal(15, @vc.vm.nos)
    assert_equal(10, @vc.vm.pick(2))
  end

  def test_dict_012_16
    # check gmpforth#171
    @vc.parse <<EOF

: test
     s" source-id blk @" evaluate ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
  end

# (?name)
  def test_dict_013
    @vc.parse ": test  10 1 (?name) ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
  end

  def test_dict_013_1
    @vc.parse ": test  10 0 ['] (?name) catch ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(-16, @vc.vm.signed(@vc.vm.tos))
  end

  def test_dict_013_2
    @vc.parse ": test  10 (lex-max-name) (?name) ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(31, @vc.vm.tos)
    assert_equal(10, @vc.vm.nos)
  end

  def test_dict_013_3
    @vc.parse ": test  10 (lex-max-name) 1+ ['] (?name) catch ;"
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(-19, @vc.vm.signed(@vc.vm.tos))
  end

# (create)
  def test_dict_014
    @vc.parse <<EOF
: test here s" test1" (create) latest n>link - ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_dict_014_01
    @vc.parse <<EOF
: test here s" t" (create) here swap - ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    # 1 cell for link, 1 for name, 1 for code field
    assert_equal(3 * @vc.vm.databytes, @vc.vm.tos)
  end

  def test_dict_014_02
    @vc.parse <<EOF
: test s" t" (create) latest ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_not_equal(0, @vc.vm.tos)
    assert_equal(GMPForth::VMCompiler::SFLAG + 1,  @vc.vm.c_fetch(@vc.vm.tos))
    assert_equal("t"[0].ord,  @vc.vm.c_fetch(@vc.vm.tos + 1))
  end

  def test_dict_014_03
    name = 'weird name'
    @vc.parse <<EOF
: test s" #{name}" (create) latest ;
EOF
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_not_equal(0, @vc.vm.tos)
    assert_equal(GMPForth::VMCompiler::SFLAG + name.length,  @vc.vm.c_fetch(@vc.vm.tos))
    assert_equal(name[0].ord,  @vc.vm.c_fetch(@vc.vm.tos + 1))
    assert_equal(name[1].ord,  @vc.vm.c_fetch(@vc.vm.tos + 2))
    assert_equal(name[2].ord,  @vc.vm.c_fetch(@vc.vm.tos + 3))
    assert_equal(name[3].ord,  @vc.vm.c_fetch(@vc.vm.tos + 4))
    assert_equal(name[4].ord,  @vc.vm.c_fetch(@vc.vm.tos + 5))
    assert_equal(name[5].ord,  @vc.vm.c_fetch(@vc.vm.tos + 6))
    assert_equal(name[6].ord,  @vc.vm.c_fetch(@vc.vm.tos + 7))
    assert_equal(name[7].ord,  @vc.vm.c_fetch(@vc.vm.tos + 8))
    assert_equal(name[8].ord,  @vc.vm.c_fetch(@vc.vm.tos + 9))
    assert_equal(name[9].ord,  @vc.vm.c_fetch(@vc.vm.tos + 10))
  end

# create
  def test_dict_015
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
create x
x
bye
EOF
    inp.gsub!("\n","\r")
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.tos)
  end

  def test_dict_015_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
create x
create y
x
y
bye
EOF
    inp.gsub!("\n","\r")
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.tos)
    assert_not_equal(@vc.vm.nos, @vc.vm.tos)
  end

  def test_dict_015_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
1 allot
create x
x
bye
EOF
    inp.gsub!("\n","\r")
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.fetch_user('(here)'), @vc.vm.tos)
  end

# variable
  def test_dict_016
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
variable x
x
bye
EOF
    inp.gsub!("\n","\r")
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@vc.fetch_user('(here)')-@vc.vm.databytes, @vc.vm.tos)
    assert_equal(0, @vc.vm.fetch(@vc.vm.tos))
  end

  def test_dict_016_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
variable x
20 x !
x
bye
EOF
    inp.gsub!("\n","\r")
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(20, @vc.vm.fetch(@vc.vm.tos))
  end

# constant
  def test_dict_017
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
10 constant x 0 , x
bye
EOF
    inp.gsub!("\n","\r")
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
  end

# user
  def test_dict_018
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
11 user balias
balias base -
bye
EOF
    inp.gsub!("\n","\r")
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

# :
  def test_dict_019
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 10 ;
test
bye
EOF
    inp.gsub!("\n","\r")
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
  end

# :
# ;
# (",)
# ]
# [
  def test_dict_019_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
0 constant zero
1 constant one
2 constant two
: test zero one two + + ;
test
bye
EOF
    inp.gsub!("\n","\r")
    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
  end

# immediate
  def test_dict_020
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: imm cr ." imm " ; immediate
: test imm ." test " ;
test
imm
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: imm cr ." imm " ; immediate  ok
: test imm ." test " ; 
imm  ok
test test  ok
imm 
imm  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# compile-only
  def test_dict_021
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: co cr ." co " ; immediate compile-only
: test co ." test " ;
test
co
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: co cr ." co " ; immediate compile-only  ok
: test co ." test " ; 
co  ok
test test  ok
co co ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# postpone
  def test_dict_022
    # postpone immediate
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: imm cr ." imm " ; immediate
: test-i postpone imm ." test-i " ; immediate
: test test-i ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: imm cr ." imm " ; immediate  ok
: test-i postpone imm ." test-i " ; immediate  ok
: test test-i ; 
imm test-i  ok
test  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_022_1
    # postpone non-immediate
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: n-imm cr ." n-imm " ;
: test-n postpone n-imm ." test-ni " ; immediate
: test test-n ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: n-imm cr ." n-imm " ;  ok
: test-n postpone n-imm ." test-ni " ; immediate  ok
: test test-n ; test-ni  ok
test 
n-imm  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# recurse
  def test_dict_023
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: rcf ?dup if dup . 1- recurse then ;
5 rcf
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: rcf ?dup if dup . 1- recurse then ;  ok
5 rcf 5 4 3 2 1  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_023_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: rPICK ?dup if 1- swap >r recurse r> swap else dup then ;
1 2 3 1 rpick .
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: rPICK ?dup if 1- swap >r recurse r> swap else dup then ;  ok
1 2 3 1 rpick . 2  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 10000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# literal
  def test_dict_024
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: xlit [ 2 3 + ] literal ;
xlit .
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: xlit [ 2 3 + ] literal ;  ok
xlit . 5  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# compile,
  def test_dict_025
    @vc.parse ": test here dup compile, here compile, here compile, here ;"
    @vc.compile
    @vc.init_user
    here = @vc.vm.dot
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(here + @vc.cells(3), @vc.vm.tos)
    assert_equal(here + @vc.cells(0), @vc.vm.nos)
    assert_equal(here + @vc.cells(2), @vc.vm.fetch(here + @vc.cells(2)))
    assert_equal(here + @vc.cells(1), @vc.vm.fetch(here + @vc.cells(1)))
    assert_equal(here + @vc.cells(0), @vc.vm.fetch(here + @vc.cells(0)))
  end

# char
  def test_dict_026
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
char 0 char 1 char 2 . . .
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
char 0 char 1 char 2 . . . 50 49 48  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# (
  def test_dict_027
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
char 0 ( char 1 ) char 2 . .
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
char 0 ( char 1 ) char 2 . . 50 48  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_027_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
char 0 ( char 1 
char 2 . .
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
char 0 ( char 1   ok
char 2 . . 50 48  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# [char]
  def test_dict_028
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test  [char] 0 [char] 1 [char] 2 . . . ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test  [char] 0 [char] 1 [char] 2 . . . ;  ok
test 50 49 48  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# [']
  def test_dict_029
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test1  ." test1 " ;
: test ['] test1 execute ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test1  ." test1 " ;  ok
: test ['] test1 execute ;  ok
test test1  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end


  def test_dict_029_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test ['] test1 execute ;
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test ['] test1 execute ; test1 ? er-13 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_029_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
1
: test ['] test1 execute ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
1  ok
: test ['] test1 execute ; test1 ? er-13 
test test ? er-13 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# s"
  def test_dict_030
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
s" hello there" type
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
s" hello there" type hello there ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_030_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test s" hello there" ;
test type
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test s" hello there" ;  ok
test type hello there ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# abort
  def test_dict_031
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
abort
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
abort 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_031_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test abort ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test abort ;  ok
test 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_031_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: iabort abort ; immediate
: danger iabort ;
state @
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: iabort abort ; immediate  ok
: danger iabort ; 
state @  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(exp, out)
    
  end

# begin
# while
# repeat
  def test_dict_032
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
begin
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
begin begin ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_032_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
while
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
while while ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_032_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
repeat
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
repeat repeat ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_032_3
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test begin 0 while repeat ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test begin 0 while repeat ;  ok
test  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_032_4
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 5 begin ?dup while dup . 1- repeat ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 5 begin ?dup while dup . 1- repeat ;  ok
test 5 4 3 2 1  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_032_5
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 5 begin ?dup while ." abcde" 1- repeat ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 5 begin ?dup while ." abcde" 1- repeat ;  ok
test abcdeabcdeabcdeabcdeabcde ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end



# until
  def test_dict_033
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
until
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
until until ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_033_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test begin 1 dup . until ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test begin 1 dup . until ;  ok
test 1  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_033_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 5 begin dup . 1- dup 0= until drop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 5 begin dup . 1- dup 0= until drop ;  ok
test 5 4 3 2 1  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1125
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# if
# else
# then
  def test_dict_034
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
if
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
if if ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_034_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
then
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
then then ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_034_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
else
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
else else ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_034_3
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 0 if ." NO" then ." YES" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 0 if ." NO" then ." YES" ;  ok
test YES ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_034_4
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 0 if ." NO" then ." YES" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 0 if ." NO" then ." YES" ;  ok
test YES ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_034_5
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 0 if ." NO" else ." Y" then ." ES" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 0 if ." NO" else ." Y" then ." ES" ;  ok
test YES ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_034_6
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 1 if ." Y" else ." NO" then ." ES" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 1 if ." Y" else ." NO" then ." ES" ;  ok
test YES ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# ahead
  def test_dict_035
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
ahead
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
ahead ahead ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_035_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test ahead ." NO" then ." YES" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test ahead ." NO" then ." YES" ;  ok
test YES ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# again
  def test_dict_036
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
again
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
again again ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_036_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 5 begin dup 0= if drop exit then 1- dup .  again ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 5 begin dup 0= if drop exit then 1- dup .  again ;  ok
test 4 3 2 1 0  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# do
# loop
  def test_dict_037
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
do
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
do do ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_037_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
loop
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
loop loop ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_037_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 0 5 0 do dup . 1+ loop drop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 0 5 0 do dup . 1+ loop drop ;  ok
test 0 1 2 3 4  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_037_3
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 5 0 do I . loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 5 0 do I . loop ;  ok
test 0 1 2 3 4  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_037_4
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 5 0 do 4 1 do j . I . loop ." x" loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 5 0 do 4 1 do j . I . loop ." x" loop ;  ok
test 0 1 0 2 0 3 x1 1 1 2 1 3 x2 1 2 2 2 3 x3 1 3 2 3 3 x4 1 4 2 4 3 x ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_037_5
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test -4 10 0 do dup 1 > if drop unloop exit then dup . 1+ loop ." x" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test -4 10 0 do dup 1 > if drop unloop exit then dup . 1+ loop ." x" ;  ok
test -4 -3 -2 -1 0 1  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_037_6
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test -4 10 0 do dup 1 > if drop leave then dup . 1+ loop ." x" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test -4 10 0 do dup 1 > if drop leave then dup . 1+ loop ." x" ;  ok
test -4 -3 -2 -1 0 1 x ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_037_7
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test -4 10 0 do dup 1 > ?leave dup . 1+ loop ." x" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test -4 10 0 do dup 1 > ?leave dup . 1+ loop ." x" ;  ok
test -4 -3 -2 -1 0 1 x ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(exp, out)
    
  end

# ?do
  def test_dict_038
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
?do
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
?do ?do ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_038_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 5 0 ?do I . loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 5 0 ?do I . loop ;  ok
test 0 1 2 3 4  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_038_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 0 0 ?do I . loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 0 0 ?do I . loop ;  ok
test  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_038_3
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 5 0 do 4 1 ?do j . I . loop ." x" loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 5 0 do 4 1 ?do j . I . loop ." x" loop ;  ok
test 0 1 0 2 0 3 x1 1 1 2 1 3 x2 1 2 2 2 3 x3 1 3 2 3 3 x4 1 4 2 4 3 x ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_038_4
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test -4 10 0 ?do dup 1 > if drop unloop exit then dup . 1+ loop ." x" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test -4 10 0 ?do dup 1 > if drop unloop exit then dup . 1+ loop ." x" ;  ok
test -4 -3 -2 -1 0 1  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_038_5
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test -4 10 0 ?do dup 1 > if drop leave then dup . 1+ loop ." x" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test -4 10 0 ?do dup 1 > if drop leave then dup . 1+ loop ." x" ;  ok
test -4 -3 -2 -1 0 1 x ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# +loop
  def test_dict_039
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
+loop
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
+loop +loop ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_039_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 10 0 do I . 3 +loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 10 0 do I . 3 +loop ;  ok
test 0 3 6 9  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_039_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 0 0 ?do I . 1 +loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 0 0 ?do I . 1 +loop ;  ok
test  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_039_3
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 5 0 do 4 1 ?do j . I . loop ." x" 2 +loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 5 0 do 4 1 ?do j . I . loop ." x" 2 +loop ;  ok
test 0 1 0 2 0 3 x2 1 2 2 2 3 x4 1 4 2 4 3 x ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_039_4
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 10 0 ?do I 5 > if unloop exit then I . 2 +loop ." x" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 10 0 ?do I 5 > if unloop exit then I . 2 +loop ." x" ;  ok
test 0 2 4  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_039_5
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 10 0 ?do I 5 > if leave then I . 2 +loop ." x" ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 10 0 ?do I 5 > if leave then I . 2 +loop ." x" ;  ok
test 0 2 4 x ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_039_6
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 6 10 ?do i . -1 +loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 6 10 ?do i . -1 +loop ;  ok
test 10 9 8 7 6  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_039_7
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 0 3 ?do i . -1 +loop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 0 3 ?do i . -1 +loop ;  ok
test 3 2 1 0  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# does>
# (does)
  def test_dict_040
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: foo create 10 , does> @ ;
foo bar
bar .
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: foo create 10 , does> @ ;  ok
foo bar  ok
bar . 10  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# quit
  def test_dict_041
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
quit
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
quit 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# forth
  def test_dict_042
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
context @ ' forth >body =
forth
context @ ' forth >body =
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
context @ ' forth >body =  ok
forth  ok
context @ ' forth >body =  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
    assert_equal(exp, out)
    
  end

  # check that the wid name is set up for xc forth name
  def test_dict_042_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
' forth dup >name swap >body 2 cells + @ =
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
' forth dup >name swap >body 2 cells + @ =  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(exp, out)
    
  end

# vocabulary
  def test_dict_043
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
vocabulary foo
foo
context @ ' foo >body =
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
vocabulary foo  ok
foo  ok
context @ ' foo >body =  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(exp, out)
    
  end

  # check that the wid name is set up for vocabulary
  def test_dict_043_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
vocabulary foo
' foo dup >name swap >body 2 cells + @ =
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
vocabulary foo  ok
' foo dup >name swap >body 2 cells + @ =  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(exp, out)
    
  end

# http://www.barelyworking.com/issues/103
  def test_dict_044_1
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
rp@
quit
rp@ = .
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
rp@  ok
quit 
rp@ = . -1  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_044_2
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
1 2 3
quit
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
1 2 3  ok
quit 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(3, @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
    assert_equal(1, @vc.vm.pick(2))
    assert_equal(exp, out)
    
  end

  def test_dict_045
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
source-id
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
source-id  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
    assert_equal(exp, out)
    
  end

  # interactive refill
  def test_dict_046
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
1 refill 3
2
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
1 refill 3 2  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
    assert_equal(1, @vc.vm.pick(2))
    assert_equal(exp, out)
    
  end

  # long definitions
  def test_dict_047
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
variable aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
variable bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
variable ccccccccccccccccccccccccccccccccc
: dddddddddddddddddddddddddddddddd ;
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
variable aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  ok
variable bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb ? er-19 
variable ccccccccccccccccccccccccccccccccc ccccccccccccccccccccccccccccccccc ? er-19 
: dddddddddddddddddddddddddddddddd ; dddddddddddddddddddddddddddddddd ? er-19 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  # negative parse
  def test_dict_048
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: } ." CLOSE BRACE " ;
: ?str ?dup if type else drop ." EMPTY " then ;
: get{ [char] } parse ?str ;
get{ ABC}
get{ }
get{
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: } ." CLOSE BRACE " ;  ok
: ?str ?dup if type else drop ." EMPTY " then ;  ok
: get{ [char] } parse ?str ;  ok
get{ ABC} ABC ok
get{ } EMPTY  ok
get{ EMPTY  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# >body
  def test_dict_049
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
variable test ' test >body test - .
: test2 create 0 , does> ;
test2 test3
' test3 >body test3 - .
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
variable test ' test >body test - . 0  ok
: test2 create 0 , does> ;  ok
test2 test3  ok
' test3 >body test3 - . 0  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)

  end

# smudge
  def test_dict_050
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test ;
' test 0= .
smudge
' test 0= .
smudge
' test 0= .
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test ;  ok
' test 0= . 0  ok
smudge  ok
' test 0= . test ? er-13 
smudge  ok
' test 0= . 0  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 2000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)

  end

# abort"
  def test_dict_051_01
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
abort" test"
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
abort" test" abort" ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_051_02
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test abort" test" ;
0 test
1 test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test abort" test" ;  ok
0 test  ok
1 test test
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_051_03
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
: test 0 >r 0 abort" test" r> drop ;
test
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
: test 0 >r 0 abort" test" r> drop ;  ok
test  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  # wordlist
  #  check:
  #    first cell is empty
  #    second cell is linked to (vocs)
  #    third cell is empty
  #                 
  def test_dict_052
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
(vocs) @ wordlist dup @ 0= -rot dup cell+ @ rot = swap 2 cells + @ 0=
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
(vocs) @ wordlist dup @ 0= -rot dup cell+ @ rot = swap 2 cells + @ 0=  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 10000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(-1, @vc.vm.signed(@vc.vm.tos))
    assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
    assert_equal(-1, @vc.vm.signed(@vc.vm.pick(2)))
    assert_equal(exp, out)
    
  end

# (number?)
  def test_dict_053_01
    @vc.parse(': test s" x" (number?) ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_dict_053_02
    @vc.parse(': test s" 2" (number?) ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
  end

  def test_dict_053_03
    @vc.parse(': test s" 4." (number?) ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(4, @vc.vm.pick(2))
  end

  def test_dict_053_04
    @vc.parse(': test s" 3.x" (number?) ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_dict_053_05
    @vc.parse(': test s" -" (number?) ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_dict_053_06
    @vc.parse(': test s" -2" (number?) ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
  end

  def test_dict_053_07
    @vc.parse(': test s" -3." (number?) ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
    assert_equal(-3, @vc.vm.signed(@vc.vm.pick(2)))
  end

  def test_dict_053_08
    @vc.parse(': test s" -3.x" (number?) ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

# number?
  def test_dict_054_01
    @vc.parse(': test s" x" number? ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_dict_054_02
    @vc.parse(': test s" 2" number? ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(2, @vc.vm.nos)
  end

  def test_dict_054_03
    @vc.parse(': test s" 4." number? ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(4, @vc.vm.pick(2))
  end

  def test_dict_054_04
    @vc.parse(': test s" 3.x" number? ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_dict_054_05
    @vc.parse(': test s" -" number? ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_dict_054_06
    @vc.parse(': test s" -2" number? ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(-2, @vc.vm.signed(@vc.vm.nos))
  end

  def test_dict_054_07
    @vc.parse(': test s" -4." number? ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(-1, @vc.vm.signed(@vc.vm.nos))
    assert_equal(-4, @vc.vm.signed(@vc.vm.pick(2)))
  end

  def test_dict_054_08
    @vc.parse(': test s" -3.x" number? ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(0, @vc.vm.tos)
  end

  def test_dict_054_09
    @vc.parse(': test s" \'x\'" number? ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(2, @vc.vm.depth)
    assert_equal(1, @vc.vm.tos)
    assert_equal(120, @vc.vm.nos)
  end

  def test_dict_054_10
    @vc.parse(': test s" %1011" number? base @ ;')
    @vc.compile
    @vc.run_limit = @vc.run_limit * 2
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
    assert_equal(11, @vc.vm.pick(2))
  end

  def test_dict_054_11
    @vc.parse(': test s" %1010.1010" number? ;')
    @vc.compile
    @vc.run_limit = @vc.run_limit * 2
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(2, @vc.vm.tos)
    assert_equal(0, @vc.vm.nos)
    assert_equal(0xaa, @vc.vm.pick(2))
  end

  def test_dict_054_12
    @vc.parse(': test s" $27" number? base @ ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(10, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
    assert_equal(0x27, @vc.vm.pick(2))
  end

  def test_dict_054_13
    @vc.parse(': test hex s" #27" number? base @ ;')
    @vc.compile
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(3, @vc.vm.depth)
    assert_equal(16, @vc.vm.tos)
    assert_equal(1, @vc.vm.nos)
    assert_equal(27, @vc.vm.pick(2))
  end

# (number)
  def test_dict_055
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
(number)
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
(number) (number) ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# (word)
  def test_dict_056
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
(word)
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
(word) (word) ? er-14 
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# (error)
  def test_dict_057
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
0 (error)
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
0 (error)  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

  def test_dict_057_01
    @vc.scan "src/fig/cold.fs"
    @vc.compile
    inp = <<EOF
-3 (error)
bye
EOF
    inp.gsub!("\n","\r")

    exp = <<EOF
#{@vc.target_name} GMP Forth
-3 (error)  ok
bye 
EOF
    exp.gsub!("\n","\r\n")
    exp.chomp!

    out = ""
    @vc.vm.redirect(inp,out)
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run
    assert_equal(:halt, @vc.vm.state)
    assert_equal(0, @vc.vm.depth)
    assert_equal(exp, out)
    
  end

# set-current
  def test_dict_058
    @vc.parse <<EOF
: test
   -1 set-current current @ ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
  end

# definitions
  def test_dict_059
    @vc.parse <<EOF
: test
   -1 context ! definitions current @ ;
EOF
    @vc.compile
    @vc.run_limit = @vc.run_limit * 1000
    @vc.run

    assert_equal(:halt, @vc.vm.state)
    assert_equal(1, @vc.vm.depth)
    assert_equal(@m1, @vc.vm.tos)
  end



end
