#
#  test_gdb_mi2.rb
# 
#  Copyright (c) 2011 by Daniel Kelley
# 
# 

require 'test/unit'
require 'stringio'
require 'noredef'
require 'gdb/mi2.rb'
require 'pp'

class TestGDB_MI2 < Test::Unit::TestCase

  extend NoRedef

  def test_record_001
    GDB::MI2::Record.new
  end

  def test_record_002
    r = GDB::MI2::Record.new
    r.kind = '^'
    assert_equal(:result, r.kind)
    assert_equal(false, r.stream)
    assert_equal('', r.info)
    assert_equal(nil, r.value)
    n = 10
    r.value = n
    assert_equal(n, r.value)
  end

  def test_record_003
    r = GDB::MI2::Record.new
    r.kind = '*'
    assert_equal(:exec, r.kind)
    assert_equal(false, r.stream)
    assert_equal('', r.info)
    assert_equal(nil, r.value)
  end

  def test_record_004
    r = GDB::MI2::Record.new
    r.kind = '+'
    assert_equal(:status, r.kind)
    assert_equal(false, r.stream)
    assert_equal('', r.info)
    assert_equal(nil, r.value)
  end

  def test_record_005
    r = GDB::MI2::Record.new
    r.kind = '='
    assert_equal(:notify, r.kind)
    assert_equal(false, r.stream)
    assert_equal('', r.info)
    assert_equal(nil, r.value)
  end

  def test_record_006
    r = GDB::MI2::Record.new
    r.kind = '~'
    assert_equal(:console, r.kind)
    assert_equal(true, r.stream)
    assert_equal(nil, r.info)
    assert_equal(nil, r.value)
  end

  def test_record_007
    r = GDB::MI2::Record.new
    r.kind = '@'
    assert_equal(:target, r.kind)
    assert_equal(true, r.stream)
    assert_equal(nil, r.info)
    assert_equal(nil, r.value)
  end

  def test_record_008
    r = GDB::MI2::Record.new
    r.kind = '&'
    assert_equal(:log, r.kind)
    assert_equal(true, r.stream)
    assert_equal(nil, r.info)
    assert_equal(nil, r.value)
  end

  def test_record_009
    r = GDB::MI2::Record.new
    assert_raise(RuntimeError) do
      r.kind = '`'
    end
  end

  def test_result_001
    r = GDB::MI2::Result.new
  end

  def test_result_002
    r = GDB::MI2::Result.new
    r.parse_line "^done"
    assert_equal(:result, r.result.kind)
    assert_equal(nil, r.result.token)
    assert_equal(nil, r.result.value)
    assert_equal(false, r.result.stream)
    assert_equal('done', r.result.info)
    assert_equal(nil, r.exec)
    assert_equal(nil, r.status)
    assert_equal(nil, r.notify)
    assert_equal(nil, r.console)
    assert_equal(nil, r.target)
    assert_equal(nil, r.log)
  end

  def test_result_003
    r = GDB::MI2::Result.new
    r.parse_line "123^done"
    assert_equal(:result, r.result.kind)
    assert_equal(123, r.result.token)
    assert_equal(nil, r.result.value)
    assert_equal(false, r.result.stream)
    assert_equal('done', r.result.info)
    assert_equal(nil, r.exec)
    assert_equal(nil, r.status)
    assert_equal(nil, r.notify)
    assert_equal(nil, r.console)
    assert_equal(nil, r.target)
    assert_equal(nil, r.log)
  end

  def test_result_004
    r = GDB::MI2::Result.new
    r.parse_line '^done,wpt={number="5",exp="C"}'
    assert_equal(:result, r.result.kind)
    assert_equal(nil, r.result.token)
    assert_equal({'wpt'=>{'number'=>5,'exp'=>'C'}}, r.result.value)
    assert_equal(false, r.result.stream)
    assert_equal('done', r.result.info)
    assert_equal(nil, r.exec)
    assert_equal(nil, r.status)
    assert_equal(nil, r.notify)
    assert_equal(nil, r.console)
    assert_equal(nil, r.target)
    assert_equal(nil, r.log)
  end

  def test_result_005
    r = GDB::MI2::Result.new
    r.parse_line '*breakpoint,nr="3",address="0x123",source="a.c:123"'
    assert_equal(:exec, r.exec.kind)
    assert_equal(nil, r.exec.token)
    assert_equal({'nr'=>3, 'address'=>0x123,'source'=>'a.c:123'}, 
          r.exec.value)
    assert_equal(false, r.exec.stream)
    assert_equal('breakpoint', r.exec.info)
    assert_equal(nil, r.result)
    assert_equal(nil, r.status)
    assert_equal(nil, r.notify)
    assert_equal(nil, r.console)
    assert_equal(nil, r.target)
    assert_equal(nil, r.log)
  end

  def test_result_006
    r = GDB::MI2::Result.new
    r.parse_line '&"print 1+2\n"'
    assert_equal(:log, r.log.kind)
    assert_equal(nil, r.log.token)
    assert_equal("print 1+2\\n", r.log.value)
    assert_equal(true, r.log.stream)
    assert_equal(nil, r.log.info)
    assert_equal(nil, r.result)
    assert_equal(nil, r.exec)
    assert_equal(nil, r.status)
    assert_equal(nil, r.notify)
    assert_equal(nil, r.console)
    assert_equal(nil, r.target)
  end

  def test_result_007
    r = GDB::MI2::Result.new
    r.parse_line '@'
    assert_equal(:target, r.target.kind)
    assert_equal(nil, r.target.token)
    assert_equal('', r.target.value)
    assert_equal(true, r.target.stream)
    assert_equal(nil, r.target.info)
    assert_equal(nil, r.result)
    assert_equal(nil, r.exec)
    assert_equal(nil, r.status)
    assert_equal(nil, r.notify)
    assert_equal(nil, r.console)
    assert_equal(nil, r.log)
  end

  def test_result_008
    r = GDB::MI2::Result.new
    h = {
      'BreakpointTable' => {
        'nr_rows' => 1,
        'nr_cols' => 6,
        'hdr' => [
          { 
            'width' => 3,
            'alignment' => -1,
            'col_name' => "number",
            'colhdr' => "Num"
          },
          {
            'width'=> 14,
            'alignment' => -1,
            'col_name' => "type",
            'colhdr' => "Type"
          },
          {
            'width' => 4,
            'alignment' => -1,
            'col_name' => "disp",
            'colhdr' => "Disp"
          },
          {
            'width' => 3,
            'alignment' => -1,
            'col_name' => "enabled",
            'colhdr' => "Enb"
          },
          {
            'width' => 10,
            'alignment' => -1,
            'col_name' => "addr",
            'colhdr' => "Address"
          },
          {
            'width' => 40,
            'alignment' => 2,
            'col_name' => "what",
            'colhdr' => "What"
          }
        ],
        'body' => [
          {
            'bkpt' => {
              'number' => 1,
              'type' => "breakpoint",
              'disp' => "keep",
              'enabled' => "y",
              'addr' => 0x000100d0,
              'func' => "main",
              'file' => "hello.c",
              'line' => 5,
              'times' => 0,
              'ignore' => 3
            }
          }
        ]
      }
    }

    r.parse_line <<EOF
^done,BreakpointTable={nr_rows="1",nr_cols="6",hdr=[{width="3",alignment="-1",col_name="number",colhdr="Num"},{width="14",alignment="-1",col_name="type",colhdr="Type"},{width="4",alignment="-1",col_name="disp",colhdr="Disp"},{width="3",alignment="-1",col_name="enabled",colhdr="Enb"},{width="10",alignment="-1",col_name="addr",colhdr="Address"},{width="40",alignment="2",col_name="what",colhdr="What"}],body=[bkpt={number="1",type="breakpoint",disp="keep",enabled="y",addr="0x000100d0",func="main",file="hello.c",line="5",times="0",ignore="3"}]}
EOF

    assert_equal(:result, r.result.kind)
    assert_equal(nil, r.result.token)
    assert_equal('done', r.result.info)
    assert_equal(h, r.result.value)
    assert_equal(nil, r.exec)
    assert_equal(nil, r.status)
    assert_equal(nil, r.notify)
    assert_equal(nil, r.console)
    assert_equal(nil, r.target)
    assert_equal(nil, r.log)
  end

  def test_result_009
    h = {
      'reason' => "breakpoint-hit",
      'bkptno' => 1,
      'thread-id' => 0,
      'frame' => {
        'addr' => 0x080480a6,
        'func' => "_atexit_begin",
        'args' => [],
        'file' => "start.S",
        'line' => 31
      }
    }
    sio = StringIO.new <<'EOF'
~"Current language:  auto; currently asm\n"
*stopped,reason="breakpoint-hit",bkptno="1",thread-id="0",frame={addr="0x080480a6",func="_atexit_begin",args=[],file="start.S",line="31"}
(gdb) 
EOF
    gdb = GDB::MI2.new(sio)
    rcv = gdb.receive
    assert_equal(h, rcv.exec.value)
  end

  def test_result_010
    sio = StringIO.new <<'EOF'
^done,value="3"
EOF
    gdb = GDB::MI2.new(sio)
    rcv = gdb.receive
    assert_equal({'value' => 3}, rcv.result.value)
  end

  def test_result_011
    h = {
      'addr' => 0x08049544,
      'nr-bytes' => 12,
      'total-bytes' => 12,
      'next-row' => 0x08049550,
      'prev-row' => 0x08049538,
      'next-page' => 0x08049550,
      'prev-page' => 0x08049538,
      'memory' => [
        {
          'addr' => 0x08049544,
          'data' => [
            0x00000003,0x00000002,0x00000001
          ]
        }
      ]
    }
    sio = StringIO.new <<'EOF'
^done,addr="0x08049544",nr-bytes="12",total-bytes="12",next-row="0x08049550",prev-row="0x08049538",next-page="0x08049550",prev-page="0x08049538",memory=[{addr="0x08049544",data=["0x00000003","0x00000002","0x00000001"]}]
EOF
    gdb = GDB::MI2.new(sio)
    rcv = gdb.receive
    assert_equal(h, rcv.result.value)
  end

  def test_result_012
    console = 'console 1\nconsole 2\nconsole 3\n'
    target = 'target 1\ntarget 2\ntarget 3\n'
    log = 'log 1\nlog 2\nlog 3\n'
    sio = StringIO.new <<'EOF'
~"console 1\n"
~"console 2\n"
~"console 3\n"
@"target 1\n"
@"target 2\n"
@"target 3\n"
&"log 1\n"
&"log 2\n"
&"log 3\n"
^done
(gdb) 
EOF
    gdb = GDB::MI2.new(sio)
    rcv = gdb.receive
    assert_equal(console, rcv.console.value)
    assert_equal(target, rcv.target.value)
    assert_equal(log, rcv.log.value)
  end

  def test_result_013
    console = 'a\nb\nc\nd\ne \\"f\\" g.\n'
    sio = StringIO.new <<'EOF'
~"a\n"
~"b\n"
~"c\n"
~"d\n"
~"e \"f\" g.\n"
^done
(gdb) 
EOF
    gdb = GDB::MI2.new(sio)
    rcv = gdb.receive
    assert_equal(console, rcv.console.value)
  end

  def test_result_014
    console = 'a\nb\nc\nd\ne \\"f\\" g.\n'
    sio = StringIO.new <<'EOF'
=thread-group-created,id="25543"
=thread-created,id="1",group-id="25572"
(gdb) 
EOF
    gdb = GDB::MI2.new(sio)
    rcv = gdb.receive
    assert_equal(2, rcv.notify.length)
    assert_equal({"id"=>25543}, rcv.notify[0].value)
    assert_equal({"id"=>1, "group-id"=>25572}, rcv.notify[1].value)
  end

end

