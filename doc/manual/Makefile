#
#  Makefile
#
#  Copyright (c) 2012 by Daniel Kelley
#
#  $Id:$
#

# xmlto uses locale to establish paper.type; it's not yet
# known if it's possible to override with a style sheet.
# Attempts to do so have so far been unsuccessful.

LC_ALL := en_US

.SUFFIXES: .xml .svg .png .pdf

SRC := gmpforth.xml
SRC += $(wildcard *.xml)
SRC += w/glossary.xml

WSRC += $(wildcard w/*/*.xml)

FO_SRC := $(SRC)
FO_SRC += w/impl/figure/paren-semis-code.pdf
FO_SRC += fo.xsl

HTML_SRC := $(SRC)
HTML_SRC += w/impl/figure/paren-semis-code.svg
HTML_SRC += html.xsl

all: gmpforth.pdf

#
# PDF
#

test: test.pdf

gmpforth.pdf: $(FO_SRC)
	xmlto -m fo.xsl pdf $<

#
# FO Debugging
#
gmppretty.fo: $(FO_SRC) pretty.xml
	xmlto -m fo.xsl fo $<
	xsltproc pretty.xml gmpforth.fo > $@

#
# Used for FO stylesheet development
#
test.pdf: test.xml $(FO_SRC)
	xmlto -m fo.xsl fo $<
	xsltproc pretty.xml test.fo > testpretty.xml
	xmlto -m fo.xsl pdf $<

#
# Used for FOP stylesheet development
#
test-fop.pdf: test.xml $(FO_SRC)
	xmlto -m fo-fop.xsl fo $<
	xsltproc pretty.xml test.fo > testpretty.xml
	fop testpretty.xml test-fop.pdf

#
# WEB
#

web: html/index.html

html/index.html: $(HTML_SRC) html
	-rm -rf html/*
	xmlto -o html -m html.xsl xhtml $<
	@(tar cf - w/*/figure/*) | (cd html; tar xvf -)

html:
	mkdir $@

#
# MISC
#

generated: w/glossary.xml

w/glossary.xml: $(WSRC)
	bin/schemagen $(WSRC)
	bin/glossgen $(WSRC) > $@

clean:
	-rm -rf gmpforth.pdf gmppretty.* gmpforth.fo \
	       test.pdf testpretty.* test.fo html w/glossary.xml w/*/schemas.xml

