#
#  documentation.rb
# 
#  Copyright (c) 2012 by Daniel Kelley
# 
#  $Id:$
#

require 'gmpforth/word'
require 'fileutils'
require 'cgi' # for CGI::escapeHTML
require 'set'

class GMPForth::Documentation

  def initialize(dir)
    @dir = dir
    @gloss_entry = Set.new
  end

  def generate(dictionary)
    generate_glossary(dictionary)
  end

  private

  def generate_glossary(dictionary)
    idx = {}
    
    # create indicies
    dictionary.each do |name,word|
      dir = File.dirname(word.file)
      voc = File.basename(dir)
      if idx[name].nil?
        idx[name] = {}
      end
      if idx[name][voc].nil?
        idx[name][voc] = word
      else
        raise "#{word.file} duplicates #{idx[name][voc].file}"
      end
    end
    fn = []
    idx.sort.each do |name,vocs|
      vocs.sort.each do |voc,word|
        
        stack = word.line_content =~ /(\(\s+.*--.*?\))/ ? $1 : nil
        case word.kind
        when :colon, :code
          raise "#{word.name} #{word.file} #{word.line_content} - no stack comment" if stack.nil?
        when :constant
          stack = '( -- n )'
        when :variable, :user
          stack = '( -- a )'
        when :vocabulary
          stack = '( -- )'
        else
          raise "handle #{word.kind}"
        end

        fn << emit_doc_template(word,voc,stack)
      end
    end
  end

  #
  # Emit doc template
  #
  def emit_doc_template(word,voc,stack_diagram)

    raise 'unexpected extension' if word.file !~ /\.fs$/
    base = File.basename(word.file, '.fs')
    dbid = "#{voc}-#{base}"
    outdir = "#{@dir}/#{voc}"
    outbase = "#{voc}/#{base}.xml"
    outfile = "#{outdir}/#{base}.xml"

    return outfile if File.exist? outfile
    raise "#{outfile} conflicts with nXML file" if base == "schemas"

    @gloss_entry.add(outfile)

    FileUtils.mkdir_p(outdir)
    
    ename = CGI::escapeHTML(word.name) # XML escaped name
    role = voc.upcase  # voc,imm,c/o Role string
    if word.immediate || word.compile_only
      role += ','
      role += 'I' if word.immediate 
      role += 'C' if word.compile_only 
    end
    stack = '' # stack effect strings
               #        <arg>a</arg>
               #        <arg>--</arg>
               #        <arg>n</arg>
    stack_a = stack_diagram.split
    if stack_a[0] != '(' || stack_a[-1] != ')'
      $stderr.puts "#{word.file} stack diagram error: #{stack_diagram}"
      stack_a = [ '(', 'FIXME', '--', ')' ]
    end
    stack_a[1..-2].each do |arg|
      stack << "        <arg>#{arg}</arg>\n" if arg.length > 0
    end
    stack.chomp! # final newline not needed
    File.open(outfile, 'w') do |f|
      f.puts <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE glossentry PUBLIC "-//OASIS//DTD DocBook XML V4.3//EN"
                  "http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd">
<glossentry id="#{dbid}" role="#{role}" xreflabel="#{ename}">
  <glossterm>
    <indexterm role="forth"><primary>#{ename}</primary></indexterm>
    <cmdsynopsis>
      <command>#{ename}</command>
      <group role="stack">
#{stack}
      </group>
    </cmdsynopsis>
  </glossterm>
  <glossdef>
    <para>
FIXME
    </para>
    <example>
      <title>#{ename}</title>
      <screen>
<userinput><keysym>&larrhk;</keysym></userinput>
      </screen>
    </example>
  </glossdef>
</glossentry>
EOF
    end
    outbase
  end

end

