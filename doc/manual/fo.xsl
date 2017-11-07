<?xml version='1.0'?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:str="http://exslt.org/strings"
    xmlns:fo="http://www.w3.org/1999/XSL/Format">
  <xsl:attribute-set name="index.div.title.properties">
    <!-- xmltex/passivetex doesn't like math in the default value of this attribute -->
    <xsl:attribute name="space-before.minimum">8pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- only chapter,appendix in TOC -->
  <xsl:param name="generate.toc">book toc,title</xsl:param>
  <xsl:param name="toc.max.depth">1</xsl:param>

  <!-- before r1989, passivetex.extensions could be set to "1", and PDF bookmarks
       and comma separators in the index could coexist; after r1989, comma separators in the index
       in the index broke. Turning off passivetex.extensions brought the comma separators back.
       Looks like things changed in RHEL/CentOS 6, as header.column.widths behavior was made 
       dependent on passivetex.extensions being set -->
  <xsl:param name="passivetex.extensions" select="1"/>
 
  <!-- passivetex callouts need unicode -->
  <xsl:param name="callout.graphics" select="'0'"></xsl:param>
  <xsl:param name="callout.unicode" select="1"></xsl:param>

  <!-- stylesheet documentation says that the header and footer column
       width attributes specify the widths of the columns relative to
       each other, but the FO generates used these as straight
       percentages. Must be a passivetex thing. -->
  <xsl:param name="header.column.widths" select="'10 80 10'"/>
  <xsl:param name="footer.column.widths" select="'10 80 10'"/>
  <xsl:param name="header.rule" select="0"/>

  <!-- xref -->
  <xsl:attribute-set name="xref.properties">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <!-- forth glossary support -->
  <xsl:template match="glossary[@role='forth']">
    <xsl:param name="glossary.as.blocks" select="1"></xsl:param>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="glossary[@role='forth']/glossentry">
    <!-- two empty paragraphs -->
    <fo:block space-before.optimum="2em" space-before.minimum="1.6em" space-before.maximum="2.4em"/>
    <fo:inline font-style="normal">
      <fo:table table-layout="fixed" width="100%">
        <fo:table-column column-number="1" column-width="75%"/>
        <fo:table-column column-number="2" column-width="5%"/>
        <fo:table-column column-number="3" column-width="20%"/>
        <fo:table-body>
          <fo:table-row>
            <fo:table-cell>
              <!-- name and stack effect -->
              <xsl:apply-templates select="glossterm/cmdsynopsis/command"/>
              <xsl:apply-templates select="glossterm/cmdsynopsis/group"/>
            </fo:table-cell>
            <fo:table-cell>
              <!-- immediate,compile-only  -->
              <!-- there's got to be an easier way of dealing with empty table cells -->
              <xsl:variable name="ic" select="str:tokenize(@role,',')[2]"/>
              <xsl:choose>
                <xsl:when test="$ic">
                  <xsl:value-of select="$ic"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>&#160;</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </fo:table-cell>
            <fo:table-cell>
              <!-- vocabulary  -->
              <xsl:value-of select="str:tokenize(@role,',')[1]"/>
            </fo:table-cell>
          </fo:table-row>
        </fo:table-body>
      </fo:table>
    </fo:inline>
    <xsl:apply-templates/>
  </xsl:template>

  <!--  cmdsynopsis already extracted in glossentry -->
  <xsl:template match="glossary[@role='forth']/glossentry/glossterm/cmdsynopsis">
  </xsl:template>

  <xsl:template match="glossary[@role='forth']/glossentry/glossdef">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- make the forth glossary command element bold -->
  <xsl:template match="glossary[@role='forth']/glossentry/glossterm/cmdsynopsis/command">
    <xsl:variable name="content">
      <xsl:value-of select="." />
    </xsl:variable>
    <fo:inline font-weight="bold">
      <fo:text>
        <xsl:copy-of select="$content"/>
      </fo:text>
      <xsl:text>&#160;&#160;&#160;</xsl:text>
    </fo:inline>
  </xsl:template>

  <!-- forth stack comment formatter -->
  <xsl:template match="group[@role='stack']/arg">
    <xsl:variable name="content">
      <xsl:value-of select="." />
    </xsl:variable>

    <fo:inline font-style="italic" font-family="monospace">
      <xsl:if test="position()>1"><xsl:text>&#160;</xsl:text></xsl:if>
      <!-- If the last character of an argument name is a digit or N, then
           treat the last character as a subscript -->
      <xsl:variable name="digit" select="substring($content,string-length($content))"/>
      <xsl:variable name="first" select="substring($content,1,1)"/>
      <xsl:variable name="subscript">
        <xsl:choose>
          <xsl:when test="string-length($content) = 1">0</xsl:when>
          <xsl:when test="contains($first,'-')">0</xsl:when>
          <xsl:when test="contains($digit,'0')">1</xsl:when>
          <xsl:when test="contains($digit,'1')">1</xsl:when>
          <xsl:when test="contains($digit,'2')">1</xsl:when>
          <xsl:when test="contains($digit,'3')">1</xsl:when>
          <xsl:when test="contains($digit,'4')">1</xsl:when>
          <xsl:when test="contains($digit,'5')">1</xsl:when>
          <xsl:when test="contains($digit,'6')">1</xsl:when>
          <xsl:when test="contains($digit,'7')">1</xsl:when>
          <xsl:when test="contains($digit,'8')">1</xsl:when>
          <xsl:when test="contains($digit,'9')">1</xsl:when>
          <xsl:when test="contains($digit,'N')">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$subscript != 0">
          <!-- trailing digit -->
          <xsl:variable name="txt" select="substring-before($content,$digit)"/>
          <fo:text>
            <xsl:copy-of select="$txt"/>
          </fo:text>
          <fo:inline font-size="75%" baseline-shift="sub">
            <fo:text>
              <xsl:copy-of select="$digit"/>
            </fo:text>
          </fo:inline>
        </xsl:when>
        <xsl:otherwise>
          <!-- no trailing digit so just issue content  -->
          <fo:text>
            <xsl:copy-of select="$content"/>
          </fo:text>
        </xsl:otherwise>
      </xsl:choose>
    </fo:inline>

  </xsl:template>

  <xsl:template match="group[@role='stack']">
    <xsl:text>&#160;(&#160;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#160;)</xsl:text>
  </xsl:template>
  <!-- header/footer -->

  <xsl:template name="header.content">
    <!-- nothing -->
  </xsl:template>

  <xsl:template name="footer.content">
    <xsl:param name="pageclass" select="''"/>
    <xsl:param name="sequence" select="''"/>
    <xsl:param name="position" select="''"/>
    <xsl:param name="gentext-key" select="''"/>
    <!--
        <fo:block>
        <xsl:value-of select="$pageclass"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$sequence"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$position"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$gentext-key"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$double.sided"/>
        </fo:block>
    -->
    <fo:block>
      <!-- pageclass can be front, body, back -->
      <!-- sequence can be odd, even, first, blank -->
      <!-- position can be left, center, right -->
      <xsl:choose>
        <xsl:when test="$pageclass = 'titlepage'">
          <!-- nop; no footer on title pages -->
        </xsl:when>

        <xsl:when test="$double.sided != 0 and $sequence = 'even'
                        and $position='left'">
          <fo:page-number/><xsl:text>(A-)</xsl:text>
        </xsl:when>

        <xsl:when test="$double.sided != 0 and ($sequence = 'odd' or $sequence = 'first')
                        and $position='right'">
          <fo:page-number/><xsl:text>(B-)</xsl:text>
        </xsl:when>

        <xsl:when test="$double.sided = 0 and $position='right'">
          <fo:page-number/>
        </xsl:when>

        <xsl:when test="$double.sided = 0 and $position='left'">
          <xsl:apply-templates select="." mode="titleabbrev.markup"/>
        </xsl:when>

        <xsl:when test="$sequence='blank'">
          <xsl:choose>
            <xsl:when test="$double.sided != 0 and $position = 'left'">
              <fo:page-number/><xsl:text>(D-)</xsl:text>
            </xsl:when>
            <xsl:when test="$double.sided = 0 and $position = 'center'">
              <fo:page-number/><xsl:text>(E+)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <!-- nop -->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>


        <xsl:otherwise>
          <!-- nop -->
        </xsl:otherwise>
      </xsl:choose>
    </fo:block>
  </xsl:template>

  <xsl:template match="table[@role='cellborder']/tgroup/tbody">
    <fo:table-body start-indent="0pt" end-indent="0pt">
      <xsl:for-each select='row'>
        <fo:table-row>
          <xsl:for-each select='entry'>
            <fo:table-cell
                border-after-color="black"
                border-after-style="solid"
                border-after-width="0.5pt"
                border-before-color="black"
                border-before-style="solid"
                border-before-width="0.5pt"
                border-end-color="black"
                border-end-style="solid"
                border-end-width="0.5pt"
                border-start-color="black"
                border-start-style="solid"
                border-start-width="0.5pt"
                padding-after="2pt"
                padding-before="2pt"
                padding-end="2pt"
                padding-start="2pt"
                margin-top="-2pt">
              <xsl:apply-templates/>
            </fo:table-cell>
          </xsl:for-each>
        </fo:table-row>
      </xsl:for-each>
    </fo:table-body>
  </xsl:template>


</xsl:stylesheet>
