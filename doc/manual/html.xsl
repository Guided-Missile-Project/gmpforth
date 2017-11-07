<?xml version='1.0'?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:str="http://exslt.org/strings">

  <!-- only chapter,appendix in TOC -->
  <xsl:param name="generate.toc">book toc,title</xsl:param>
  <xsl:param name="toc.max.depth">1</xsl:param>

  <!-- use ID as filename -->
  <xsl:param name="use.id.as.filename">1</xsl:param>

  <!-- callout graphics -->
  <xsl:param name="callout.graphics" select="'1'"/>
  <xsl:param name="callout.graphics.path" select="'/usr/share/sgml/docbook/xsl-stylesheets/images/callouts/'"/>

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
    <table>
      <col width="80%"/>
      <col width="5%"/>
      <col width="15%"/>
      <tr>
        <td>
          <!-- name and stack effect -->
          <xsl:apply-templates select="glossterm/cmdsynopsis/command"/>
          <xsl:apply-templates select="glossterm/cmdsynopsis/group"/>
        </td>
        <td>
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
        </td>
        <td>
          <!-- vocabulary  -->
          <xsl:value-of select="str:tokenize(@role,',')[1]"/>
        </td>
      </tr>
    </table>
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
    <b>
      <xsl:copy-of select="$content"/>
      <xsl:text>&#160;&#160;&#160;</xsl:text>
    </b>
  </xsl:template>

  <!-- forth stack comment formatter -->
  <xsl:template match="group[@role='stack']/arg">
    <xsl:variable name="content">
      <xsl:value-of select="." />
    </xsl:variable>

    <tt>
      <xsl:if test="position()>1"><xsl:text>&#160;</xsl:text></xsl:if>
      <!-- If the last character of an argument name is a digit or N, then
           treat the last character as a subscript -->
      <xsl:variable name="digit" select="substring($content,string-length($content))"/>
      <xsl:variable name="subscript">
      <xsl:variable name="first" select="substring($content,1,1)"/>
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
          <xsl:copy-of select="$txt"/>
          <sub>
            <xsl:copy-of select="$digit"/>
          </sub>
        </xsl:when>
        <xsl:otherwise>
          <!-- no trailing digit so just issue content  -->
          <xsl:copy-of select="$content"/>
        </xsl:otherwise>
      </xsl:choose>
    </tt>

  </xsl:template>

  <xsl:template match="group[@role='stack']">
    <xsl:text>&#160;(&#160;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#160;)</xsl:text>
  </xsl:template>

  <xsl:template match="table[@role='cellborder']/tgroup/tbody">
    <table border="1">
      <xsl:for-each select='row'>
        <tr>
          <xsl:for-each select='entry'>
            <td>
              <xsl:apply-templates/>
            </td>
          </xsl:for-each>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>


</xsl:stylesheet>
