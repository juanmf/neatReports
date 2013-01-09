<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xbrl="http://www.xbrl.org/core/2000-07-31/instance"
 xmlns:jpcoci="http://www.xbrl-jp.org/jp/comm/ci/2001-10-09">
    <!-- TODO customize transformation rules 
         syntax recommendation http://www.w3.org/TR/xslt 
    -->
    <xsl:template match="Persona">
        <fo:block>
            <fo:text>
                <xsl:apply-templates select="id"/>
            </fo:text>
        </fo:block>
    </xsl:template>

    <xsl:template match="id">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
