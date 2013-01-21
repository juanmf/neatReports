<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:aml="http://schemas.microsoft.com/aml/2001/core"
                xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:my="dummy.namespace"
                version="2.0">


    <!--<xsl:include href="./Word2FO/stylesheets/Word2FO.xsl"/>-->
    <xsl:import href=".\Word2FO\stylesheets\Word2FO.xsl"/>

    <!-- =================== -->
    <!-- MAIN ROOT TRANSFORM -->
    <!-- =================== -->
    <xsl:template match="/w:wordDocument" priority="1">
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:siup="http://siup.gov.ar/XSL/Format"<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>xsl:template match='/'<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>xsl:apply-templates select="root" /<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>/xsl:template<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>xsl:template match='root'<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        <fo:root>
            <!-- Set default font-family attribute on fo:root -->
            <xsl:apply-templates select="w:fonts/w:defaultFonts"/>

            <!-- Create physical page layout and generate page sequences -->
            <xsl:call-template name="CreatePageLayout"/>
            <xsl:call-template name="GeneratePageSequences"/>
        </fo:root>
        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>/xsl:template<xsl:text disable-output-escaping="yes">&gt;</xsl:text>

        <xsl:apply-templates 
            select="//w:tbl[w:tr[w:tc[w:p[w:r[aml:annotation[contains(aml:content, 'repeatTable')]]]]]]
                |//w:tr[w:tc[w:p[w:r[aml:annotation[contains(aml:content, 'repeatRow')]]]]]
                |//w:tc[w:p[w:r[aml:annotation[contains(aml:content, 'repeatCell')]]]]" 
            mode="repetitive-template" />
        <!--Esto rompe todo. -->

        <xsl:text disable-output-escaping="yes">&lt;</xsl:text>/xsl:stylesheet<xsl:text disable-output-escaping="yes">&gt;</xsl:text>

    </xsl:template>
    <!-- ======================== -->
    <!-- Represents text content. -->
    <!-- Parent elements: w:r.    -->
    <!-- ======================== -->                
    <xsl:template match="w:t[text()='#' and ../following-sibling::aml:annotation[@w:type='Word.Comment.End']]" priority="1">
        <!-- Preserve initial whitespace characters. -->
        <!-- fo:leader with zero lenght affects on white-space-treatment:   -->
        <!-- initial white-space characters are not surround line-feed now. -->
        <fo:leader leader-length="0pt"/>
        <!-- text content -->

        <!-- juanmf@gmail.com: I'll use comments as the select attr value of xsl:value-of elements for the report template -->
        <!-- commmented "#" elements will render <xsl:value-of select=".//comment"/> -->
        <!--<xsl:when test="node()[text()='#']/../preceding-sibling::aml:annotation[@w:type='Word.Comment.Start']">-->
        <xsl:call-template name="Value-of-Selector" />
    </xsl:template>

    <!-- juanmf@gmail.com: I'll use comments as the select attr value of xsl:value-of elements for the report template -->
    <!-- commmented "#" elements will render <xsl:value-of select=".//comment"/> -->
    <!-- Where .// prefix in ".//comment" will depend on the existence of a function or an absolute path in the comment expression-->
    <!--<xsl:when test="node()[text()='#']/../preceding-sibling::aml:annotation[@w:type='Word.Comment.Start']">-->
    <xsl:template name="Value-of-Selector">
        <xsl:variable name="commentId" select="../following-sibling::aml:annotation[1]/@aml:id" />
        <xsl:variable name="nodeSelector" select="../../w:r/aml:annotation[@w:type='Word.Comment' and @aml:id=$commentId]/aml:content" />
        <xsl:variable name="prefix" >
            <!--select="'.//'"--> 
            <xsl:if test="not(contains($nodeSelector, '(')) and not(contains($nodeSelector, '//'))">
                <xsl:text>.//</xsl:text>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="contains($nodeSelector, '[position()]')">
            <xsl:text disable-output-escaping="yes">&lt;</xsl:text>xsl:variable name="pos" select="position()"<xsl:text disable-output-escaping="yes">/></xsl:text>
</xsl:if>

<xsl:variable name="processedNodeSelector" >
    <!--select="'.//'"--> 
    <xsl:call-template name="replace-string">
        <xsl:with-param name="text" select="$nodeSelector"/>
        <xsl:with-param name="replace" select="'[position()]'"/>
        <xsl:with-param name="with" select="'[position() = $pos]'"/>
    </xsl:call-template>
</xsl:variable>
<!--Rendering disable-output-escaping="yes" will allow style markup in data XML.-->
<xsl:text disable-output-escaping="yes">&lt;</xsl:text>xsl:value-of disable-output-escaping="yes" select="<xsl:value-of select="concat($prefix, $processedNodeSelector)"/>"<xsl:text disable-output-escaping="yes">/></xsl:text>
</xsl:template>

<!-- ================ -->
<!-- Tabular elements -->
<!-- ================ -->
<!-- ============================= -->
<!-- Represents the table element. -->
<!-- ============================= -->
<xsl:template name="w:tbl" >
    <!-- Internal links -->
    <xsl:apply-templates select="aml:annotation"/>
    <fo:table>
        <!-- Set default-style table properties -->
        <xsl:apply-templates select="$default-table-style"/>
        <!-- Set style-level table properties -->
        <xsl:apply-templates select="key('styles', w:tblPr/w:tblStyle/@w:val)[@w:type='table']"/>
        <!-- Set direct table properties -->
        <xsl:apply-templates select="w:tblPr/*[not(self::w:tblStyle) and not(self::w:tblCellMar)]"/>
        <!-- Set table columns -->
        <xsl:apply-templates select="w:tblGrid"/>
        <!-- table-header -->
        <!-- 03/05/2006: Need to add w: namepace to tblHeader to fix a bug in the application of repeating table header -->
        <xsl:variable name="header-rows" select="w:tr[w:trPr/w:tblHeader[not(@w:val='off')]]"/>
        <xsl:if test="$header-rows">
            <fo:table-header start-indent="0pt" end-indent="0pt">
                <xsl:apply-templates select="$header-rows"/>
            </fo:table-header>
        </xsl:if>
        <fo:table-body start-indent="0pt" end-indent="0pt">
            <!-- There are situations when child of w:tbl is not from standard namespace.-->
            <!-- Currently style sheet does not support rendering of such elements. -->
            <!-- e.g. Smart-tag can contain w:tr element.   -->
            <!-- TODO: Add w: namepace to tblHeader to fix a bug in the application of repeating table header -->
            <xsl:apply-templates select="*[self::w:tr[not(w:trPr/w:tblHeader) or w:trPr/w:tblHeader/@w:val='off'] or not(contains($standard-namespace-prefixes, concat(' ', substring-before(name(), ':'), ' ')))]"/>
        </fo:table-body>
    </fo:table>
</xsl:template>

<!--juanmf@gmail.com replace normal w:tbl transformation with an xsl:apply-tempates for repetitive tables -->
<!--<xsl:template match="aml:annotation[contains(content, 'repeatTable')]/ancestor::w:tbl[1]" priority="1">-->

<xsl:template match="w:tbl[w:tr[w:tc[w:p[w:r[aml:annotation[contains(aml:content, 'repeatTable')]]]]]]" priority="2">
    <xsl:variable name="commentId" select="w:tr/w:tc/w:p/w:r/aml:annotation[contains(aml:content, 'repeatTable')][1]/@aml:id" /> 
    <xsl:variable name="nodeSelector" select="substring-after(.//aml:annotation[@w:type='Word.Comment' and @aml:id=$commentId]/aml:content, 'repeatTable ')" />
    <xsl:text disable-output-escaping="yes">&lt;xsl:apply-templates select=".//</xsl:text>
    <xsl:value-of select="$nodeSelector"/>" mode="repetitive-table-<xsl:value-of select="$commentId"/>"<xsl:text disable-output-escaping="yes">/&gt;</xsl:text>
</xsl:template>

<!--juanmf@gmail.com after closing fo:root this should get called to render repetitive row templates-->
<xsl:template match="w:tbl[w:tr[w:tc[w:p[w:r[aml:annotation[contains(aml:content, 'repeatTable')]]]]]]" priority="1" mode="repetitive-template">
    <xsl:variable name="commentId" select="w:tr/w:tc/w:p/w:r/aml:annotation[contains(aml:content, 'repeatTable')][1]/@aml:id" /> 
    <xsl:variable name="nodeSelector" select="substring-after(.//aml:annotation[@w:type='Word.Comment' and @aml:id=$commentId]/aml:content, 'repeatTable ')" />
    <xsl:text disable-output-escaping="yes">&lt;xsl:template match="</xsl:text>
    <xsl:value-of select="$nodeSelector"/>" mode="repetitive-table-<xsl:value-of select="$commentId"/>"<xsl:text disable-output-escaping="yes">&gt;</xsl:text>

    <xsl:call-template name="w:tbl"/>

    <xsl:text disable-output-escaping="yes">&lt;/xsl:template&gt;</xsl:text>    
</xsl:template>

<!-- ========================== -->
<!-- Represents a table column. -->
<!-- Parent element: w:tblGrid. -->
<!-- ========================== -->
<xsl:template match="w:gridCol" priority="1">
    <fo:table-column>
        <xsl:variable name="colNum">
            <xsl:number count="w:gridCol"/>
        </xsl:variable>
        <xsl:attribute name="column-number">
            <xsl:value-of select="$colNum"/>
        </xsl:attribute>
        <xsl:attribute name="column-width">
            <xsl:value-of select="@w:w div 20"/>
            <xsl:text>pt</xsl:text>
        </xsl:attribute>
        <!--juanmf@gmail.com when the number of cells is dinamyc, Apache FOP complains of fo:tablecolumn number missmatch adding -->
        <!--TODO: mi uso de $colNum PARECE ESTAR FALLANDO me genera 
            column-number="1"  number-columns-repeated="count(.//Dia) Bien. 
            column-number="2"  number-columns-repeated="count(.//Dia) Mal. Pero se ve que $colNum cambia de 1 a 2 y en ../../w:tr/w:tc[$colNum] siemrpe trae "Dia".-->
        <xsl:if test="../../w:tr/w:tc[position() = $colNum]/w:p/w:r/aml:annotation[contains(aml:content, 'repeatCell')]">
            <xsl:variable name="commentId" select="../../w:tr/w:tc[position() = $colNum]/w:p/w:r/aml:annotation[contains(aml:content, 'repeatCell')][1]/@aml:id" /> 
            <xsl:variable name="domRepetitiveNode" select="substring-after(../../w:tr/w:tc//aml:annotation[@w:type='Word.Comment' and @aml:id=$commentId]/aml:content, 'repeatCell ')" />
            <xsl:attribute name="number-columns-repeated">
                <!--XPath expression selecting count of repetitive nodes in XML consumed by generated report XSLT-->
                <!--<xsl:text disable-output-escaping="yes">&lt;xsl:value-of select="count(.//</xsl:text><xsl:value-of select="$domRepetitiveNode" /><xsl:text>)"></xsl:text>-->
                <xsl:text disable-output-escaping="yes">{count(.//</xsl:text>
                <xsl:value-of select="$domRepetitiveNode" />
                <xsl:text>)}</xsl:text>

            </xsl:attribute>
        </xsl:if>
    </fo:table-column>
</xsl:template>
<!-- ======================= -->
<!-- Represents a table row. -->
<!-- Parent element: w:tbl.  -->
<!-- ======================= -->
<xsl:template name="w:tr">
    <fo:table-row>
        <xsl:variable name="table-properties" select="ancestor::w:tbl/w:tblPr"/>
        <!-- xsl:if test="w:trPr/w:trHeight/@w:h-rule = 'exact'" -->
        <xsl:if test="w:trPr/w:trHeight/@w:h-rule = 'exact'">
            <xsl:attribute name="height">
                <xsl:value-of select="concat(w:trPr/w:trHeight/@w:val div 20, 'pt' )"/>
            </xsl:attribute>
        </xsl:if>
        <!-- Set default-style table-row properties -->
        <xsl:apply-templates select="$default-table-style" mode="table-rows"/>
        <!-- Set style-level table-row properties -->
        <xsl:apply-templates
                select="key('styles', $table-properties/w:tblStyle/@w:val)[@w:type='table']" mode="table-rows"/>
        <!-- Overriden table properties for the row -->
        <xsl:apply-templates select="w:tblPrEx/*"/>
        <!-- Set direct table-row properties -->
        <xsl:apply-templates select="w:trPr/*"/>
        <!-- Generate table cells -->
        <xsl:apply-templates select="w:tc"/>
    </fo:table-row>
</xsl:template>

<!--juanmf@gmail.com replace normal w:tc transformation with an xsl:apply-tempates for repetitive cells -->
<!--<xsl:template match="aml:annotation[contains(content, 'repeatCell')]/ancestor::w:tc[1]" priority="1">-->

<xsl:template match="w:tr[w:tc[w:p[w:r[aml:annotation[contains(aml:content, 'repeatRow')]]]]]" priority="1">
    <xsl:variable name="commentId" select="w:tc/w:p/w:r/aml:annotation[contains(aml:content, 'repeatRow')][1]/@aml:id" /> 
    <xsl:variable name="nodeSelector" select="substring-after(.//aml:annotation[@w:type='Word.Comment' and @aml:id=$commentId]/aml:content, 'repeatRow ')" />
    <xsl:text disable-output-escaping="yes">&lt;xsl:apply-templates select=".//</xsl:text>
    <xsl:value-of select="$nodeSelector"/>" mode="repetitive-row-<xsl:value-of select="$commentId"/>"<xsl:text disable-output-escaping="yes">/&gt;</xsl:text>
</xsl:template>

<!--juanmf@gmail.com after closing fo:root this should get called to render repetitive row templates-->
<xsl:template match="w:tr[w:tc[w:p[w:r[aml:annotation[contains(aml:content, 'repeatRow')]]]]]" priority="1" mode="repetitive-template">
    <xsl:variable name="commentId" select="w:tc/w:p/w:r/aml:annotation[contains(aml:content, 'repeatRow')][1]/@aml:id" /> 
    <xsl:variable name="nodeSelector" select="substring-after(.//aml:annotation[@w:type='Word.Comment' and @aml:id=$commentId]/aml:content, 'repeatRow ')" />
    <xsl:text disable-output-escaping="yes">&lt;xsl:template match="</xsl:text>
    <xsl:value-of select="$nodeSelector"/>" mode="repetitive-row-<xsl:value-of select="$commentId"/>"<xsl:text disable-output-escaping="yes">&gt;</xsl:text>

    <xsl:call-template name="w:tr"/>

    <xsl:text disable-output-escaping="yes">&lt;/xsl:template&gt;</xsl:text>    
</xsl:template>
<!-- ======================== -->
<!-- Represents a table cell. -->
<!-- Parent element: w:tr.    -->
<!-- ======================== -->
<xsl:template name="w:tc">
    <!-- should not generate fo:table-cell when the w:tc is spanned cell -->
    <xsl:if test="(not(w:tcPr/w:hmerge) or w:tcPr/w:hmerge/@w:val='restart') and (not(w:tcPr/w:vmerge) or w:tcPr/w:vmerge/@w:val='restart')">
        <fo:table-cell>
            <xsl:variable name="table-properties" select="ancestor::w:tbl[1]/w:tblPr"/>
            <xsl:variable name="table-properties-ex" select="ancestor::w:tr[1]/w:tblPrEx"/>
            <!-- Set default-style table-cell properties -->
            <!-- xsl:if test="w:tcPr/w:tcW/@w:w">
                  <xsl:attribute name="width"><xsl:value-of select="concat(w:tcPr/w:tcW/@w:w div 20, 'pt' )"/></xsl:attribute>
                </xsl:if -->
            <xsl:if test="../w:trPr/w:trHeight/@w:h-rule = 'exact'">
                <xsl:attribute name="height">
                    <xsl:value-of select="concat(../w:trPr/w:trHeight/@w:val div 20, 'pt' )"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="$default-table-style" mode="table-cells">
                <xsl:with-param name="cell" select="."/>
            </xsl:apply-templates>
            <!-- Set style-level table-cell properties -->
            <xsl:apply-templates
                    select="key('styles', $table-properties/w:tblStyle/@w:val)[@w:type='table']" mode="table-cells">
                <xsl:with-param name="cell" select="."/>
            </xsl:apply-templates>
            <!-- Apply direct table-cell properties defined on table level -->
            <xsl:apply-templates select="$table-properties/w:tblBorders/*">
                <xsl:with-param name="cell" select="."/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$table-properties-ex/w:tblBorders/*">
                <xsl:with-param name="cell" select="."/>
            </xsl:apply-templates>
            <xsl:apply-templates select="$table-properties/w:tblCellMar"/>
            <!-- Set direct table-cell properties -->
            <xsl:apply-templates select="w:tcPr/*">
                <xsl:with-param name="cell" select="."/>
            </xsl:apply-templates>

            <fo:block-container>

                <xsl:if test="w:tcPr/w:textFlow/@w:val = 'bt-lr' or w:tcPr/w:textFlow/@w:val = 'tb-rl' ">
                    <xsl:attribute name="width">
                        <xsl:value-of select="concat(../w:trPr/w:trHeight/@w:val div 20, 'pt' )"/>
                    </xsl:attribute>
                    <xsl:attribute name="reference-orientation">
                        <xsl:choose>
                            <xsl:when test="w:tcPr/w:textFlow/@w:val = 'bt-lr' ">90</xsl:when>
                            <xsl:when test="w:tcPr/w:textFlow/@w:val = 'tb-rl' ">-90</xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:if>

                <!-- The table cell content -->
                <xsl:apply-templates select="*[not(self::w:tcPr)]"/>

            </fo:block-container>

        </fo:table-cell>
    </xsl:if>
</xsl:template>

<!--juanmf@gmail.com replace normal w:tc transformation with an xsl:apply-tempates for repetitive cells -->
<!--<xsl:template match="aml:annotation[contains(content, 'repeatCell')]/ancestor::w:tc[1]" priority="1">-->

<xsl:template match="w:tc[w:p[w:r[aml:annotation[contains(aml:content, 'repeatCell')]]]]" priority="1">
    <xsl:variable name="commentId" select="w:p/w:r/aml:annotation[contains(aml:content, 'repeatCell')][1]/@aml:id" /> 
    <xsl:variable name="nodeSelector" select="substring-after(.//aml:annotation[@w:type='Word.Comment' and @aml:id=$commentId]/aml:content, 'repeatCell ')" />

    <xsl:text disable-output-escaping="yes">&lt;xsl:apply-templates select=".//</xsl:text>
    <xsl:value-of select="$nodeSelector"/>" mode="repetitive-cell-<xsl:value-of select="$commentId"/>"<xsl:text disable-output-escaping="yes">/&gt;</xsl:text>

</xsl:template>

<!--juanmf@gmail.com after closing fo:root this should get called to render repetitive cell templates-->
<xsl:template match="w:tc[w:p[w:r[aml:annotation[contains(aml:content, 'repeatCell')]]]]" priority="1" mode="repetitive-template">
    <xsl:variable name="commentId" select="w:p/w:r/aml:annotation[contains(aml:content, 'repeatCell')][1]/@aml:id" /> 
    <xsl:variable name="nodeSelector" select="substring-after(.//aml:annotation[@w:type='Word.Comment' and @aml:id=$commentId]/aml:content, 'repeatCell ')" />

    <xsl:text disable-output-escaping="yes">&lt;xsl:template match="</xsl:text>
    <xsl:value-of select="$nodeSelector"/>" mode="repetitive-cell-<xsl:value-of select="$commentId"/>"<xsl:text disable-output-escaping="yes">&gt;</xsl:text>

    <xsl:call-template name="w:tc"/>

    <xsl:text disable-output-escaping="yes">&lt;/xsl:template&gt;</xsl:text>    
</xsl:template>
<!-- ======== -->
<!-- Graphics -->
<!-- ======== -->
<!-- =========================================== -->
<!-- Represents a picture or other binary object -->
<!-- that appears at this point in the document. -->
<!-- Parent elements: w:r                        -->
<!-- =========================================== -->
<!-- juanmf@gmail.com: I'll use comments to replace embeded images in reports with data source xml nodes -->
<xsl:template match="w:pict[ancestor::w:r[1]/following-sibling::aml:annotation[@w:type='Word.Comment.End']]" priority="1">
    <xsl:param name="x-factor" select="1"/>
    <xsl:param name="y-factor" select="1"/>
    <xsl:variable name="commentId" select="ancestor::w:r[1]/following-sibling::aml:annotation[@w:type='Word.Comment.End']/@aml:id" />
    <xsl:variable name="nodeSelector" select="ancestor::w:r[1]/following-sibling::w:r/aml:annotation[@w:type='Word.Comment' and @aml:id=$commentId]/aml:content" />
    <xsl:variable name="varName" select="concat('chart_', $commentId)" />
    <xsl:text disable-output-escaping="yes">&lt;</xsl:text>xsl:variable name="<xsl:value-of select="$varName"/>" select=".//<xsl:value-of select="$nodeSelector"/>"<xsl:text disable-output-escaping="yes">/&gt;</xsl:text>

    <xsl:variable name="binary-data" select="w:binData | w:movie | w:background | w:applet | w:scriptAnchor | w:ocx | w:msAccessHTML"/>
    <xsl:apply-templates select="v:shape">
        <xsl:with-param name="binary-data" select="binary-data"/>
        <xsl:with-param name="x-factor" select="$x-factor"/>
        <xsl:with-param name="y-factor" select="$y-factor"/>
    </xsl:apply-templates>

</xsl:template>

    <!-- ================================================== -->
    <!-- Contains the binary data representing this object. -->
    <!-- Parent elements: w:pict, w:bgPict                  -->
    <!-- ================================================== -->
    <xsl:template match="w:binData[ancestor::w:r[1]/following-sibling::aml:annotation[@w:type='Word.Comment.End']]" priority="1">
        <xsl:variable name="commentId" select="ancestor::w:r[1]/following-sibling::aml:annotation[@w:type='Word.Comment.End']/@aml:id" />
        <xsl:variable name="varName" select="concat('chart_', $commentId)" />

        <xsl:variable name="media-type">
            <xsl:text>image/</xsl:text>
            <xsl:call-template name="RetrieveMediaSubtype">
                <xsl:with-param name="name" select="@w:name"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat('url(&quot;data:', $media-type, ';base64,{$', $varName, '}&quot;)')"/>
    </xsl:template>    
    
<!-- ================================================== -->
<!-- Auxiliary functions                                -->
<!-- ================================================== -->
<xsl:template name="replace-string">
    <xsl:param name="text"/>
    <xsl:param name="replace"/>
    <xsl:param name="with"/>
    <xsl:choose>
        <xsl:when test="contains($text,$replace)">
            <xsl:value-of select="substring-before($text,$replace)"/>
            <xsl:value-of select="$with"/>
            <xsl:call-template name="replace-string">
                <xsl:with-param name="text" select="substring-after($text,$replace)"/>
                <xsl:with-param name="replace" select="$replace"/>
                <xsl:with-param name="with" select="$with"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$text"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
	
<!-- ================================================== -->
<!-- Auxiliary.xsl templates replacement                -->
<!-- ================================================== -->
  <!-- ================================ -->
  <!-- Convert "Symbol" and "Wingdings" -->
  <!-- symbol codes to Unicode.         -->
  <!-- ================================ -->
  <xsl:template name="ConvertSymbol">
    <xsl:param name="font-family"/>
    <xsl:param name="symbol"/>
    <xsl:variable name="chars-table" select="msxsl:node-set($chars-table-rtf)" xmlns:msxsl="urn:schemas-microsoft-com:xslt"/>
	  
    <xsl:apply-templates select="$chars-table//my:recoding-table[@font=$font-family]/my:char[@value=$symbol or @altvalue=$symbol]"/>
    
  </xsl:template>
  <!-- ================================ -->
  <!-- Convert string with chars from fonts "Symbol" and "Wingdings" -->
  <!-- symbol codes to Unicode.         -->
  <!-- ================================ -->
  <xsl:template name="ConvertString">
    <xsl:param name="font-family"/> 
    <xsl:param name="string"/>
    
    <xsl:if test="string-length($string)">
      <!--<xsl:value-of select="document('')//my:recoding-table[@font=$font-family]/my:char[@code=substring($string, 1, 1)]/@entity"/>-->
      <!-- Attention! If you use @code or @entity attribute value (also for searching), you should use only first character of attribute value! -->
      <!-- In some cases value of attributes @code and @entity is doubled for compatibility reason. -->
      <!-- See http://www.w3.org/TR/xslt#attribute-value-templates 7.6.2 Attribute Value Templates -->
      <!-- It is an error if a right curly brace occurs in an attribute value template outside an expression without being followed by a second right curly brace. -->
	  <xsl:variable name="chars-table" select="msxsl:node-set($chars-table-rtf)" xmlns:msxsl="urn:schemas-microsoft-com:xslt"/>
	  
      <xsl:value-of select="substring($chars-table//my:recoding-table[@font=$font-family]/my:char[substring(@code, 1, 1)=substring($string, 1, 1)]/@entity, 1, 1)"/>
      <xsl:call-template name="ConvertString">
        <xsl:with-param name="font-family" select="$font-family"/>
        <xsl:with-param name="string" select="substring($string, 2)"/>
      </xsl:call-template>
    </xsl:if>
    
  </xsl:template>    
    <!-- ============================================= -->
  <!-- Convert symbol codes (expressed as a unicode) -->
  <!-- to Unicode character.                         -->
  <!-- ============================================= -->
  <xsl:template name="ConvertChars">
    <xsl:param name="font-family"/>
    <xsl:param name="char-string"/>
    
    <!--<xsl:variable name="recorded-char" select="document('')//my:recoding-table[@font=$font-family]/my:char[@code=$char-string]"/>-->
    <!-- Attention! If you use @code or @entity attribute value (also for searching), you should use only first character of attribute value! -->
    <!-- In some cases value of attributes @code and @entity is doubled for compatibility reason. -->
    <!-- See http://www.w3.org/TR/xslt#attribute-value-templates 7.6.2 Attribute Value Templates -->
    <!-- It is an error if a right curly brace occurs in an attribute value template outside an expression without being followed by a second right curly brace. -->
	<xsl:variable name="chars-table" select="msxsl:node-set($chars-table-rtf)" xmlns:msxsl="urn:schemas-microsoft-com:xslt"/>
    <xsl:variable name="recorded-char" select="$chars-table//my:recoding-table[@font=$font-family]/my:char[substring(@code, 1, 1)=$char-string]"/>
    
    <xsl:choose>
      <xsl:when test="$recorded-char">
        <xsl:attribute name="font-size">
          <xsl:value-of select="$default-font-size.symbol"/><xsl:text>pt</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="font-family"><xsl:text>ZapfDingbats, Arial</xsl:text></xsl:attribute>
        <xsl:apply-templates select="$recorded-char"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$char-string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:param name="chars-table-rtf">
	<!-- ======================= -->
	<!-- Custom recording tables -->
	<!-- ======================= -->
	<!-- =========== -->
	<!-- Symbol font -->
	<!-- =========== -->
	<!-- 03/06/2006: Provided a comprehensive recoding table for many more Symbol characters -->
	<!-- Attention! If you use @code or @entity attribute value (also for searching), you should use only first character of attribute value! -->
	<!-- In some cases value of attributes @code and @entity is doubled for compatibility reason. -->
	<!-- See http://www.w3.org/TR/xslt#attribute-value-templates 7.6.2 Attribute Value Templates -->
	<!-- It is an error if a right curly brace occurs in an attribute value template outside an expression without being followed by a second right curly brace. -->
	<my:recoding-table font="Symbol">
		<my:char code="&#x21;" value="21" altvalue="F021" entity="&#x0021;"/> <!--EXCLAMATION MARK-->
		<my:char code="&#x22;" value="22" altvalue="F022" entity="&#x2200;"/> <!--FOR ALL-->
		<my:char code="&#x23;" value="23" altvalue="F023" entity="&#x0023;"/> <!--NUMBER SIGN-->
		<my:char code="&#x24;" value="24" altvalue="F024" entity="&#x2203;"/> <!--THERE EXISTS-->
		<my:char code="&#x25;" value="25" altvalue="F025" entity="&#x0025;"/> <!--PERCENT SIGN-->
		<my:char code="&#x26;" value="26" altvalue="F026" entity="&#x0026;"/> <!--AMPERSAND-->
		<my:char code="&#x27;" value="27" altvalue="F027" entity="&#x220D;"/> <!--SMALL CONTAINS AS MEMBER-->
		<my:char code="&#x28;" value="28" altvalue="F028" entity="&#x0028;"/> <!--LEFT PARENTHESIS-->
		<my:char code="&#x29;" value="29" altvalue="F029" entity="&#x0029;"/> <!--RIGHT PARENTHESIS-->
		<my:char code="&#x2A;" value="2A" altvalue="F02A" entity="&#x2217;"/> <!--ASTERISK OPERATOR-->
		<my:char code="&#x2B;" value="2B" altvalue="F02B" entity="&#x002B;"/> <!--PLUS SIGN-->
		<my:char code="&#x2C;" value="2C" altvalue="F02C" entity="&#x002C;"/> <!--COMMA-->
		<my:char code="&#x2D;" value="2D" altvalue="F02D" entity="&#x2212;"/> <!--MINUS SIGN-->
		<my:char code="&#x2E;" value="2E" altvalue="F02E" entity="&#x002E;"/> <!--FULL STOP-->
		<my:char code="&#x2F;" value="2F" altvalue="F02F" entity="&#x002F;"/> <!--SOLIDUS-->
		<my:char code="&#x30;" value="30" altvalue="F030" entity="&#x0030;"/> <!--DIGIT ZERO-->
		<my:char code="&#x31;" value="31" altvalue="F031" entity="&#x0031;"/> <!--DIGIT ONE-->
		<my:char code="&#x32;" value="32" altvalue="F032" entity="&#x0032;"/> <!--DIGIT TWO-->
		<my:char code="&#x33;" value="33" altvalue="F033" entity="&#x0033;"/> <!--DIGIT THREE-->
		<my:char code="&#x34;" value="34" altvalue="F034" entity="&#x0034;"/> <!--DIGIT FOUR-->
		<my:char code="&#x35;" value="35" altvalue="F035" entity="&#x0035;"/> <!--DIGIT FIVE-->
		<my:char code="&#x36;" value="36" altvalue="F036" entity="&#x0036;"/> <!--DIGIT SIX-->
		<my:char code="&#x37;" value="37" altvalue="F037" entity="&#x0037;"/> <!--DIGIT SEVEN-->
		<my:char code="&#x38;" value="38" altvalue="F038" entity="&#x0038;"/> <!--DIGIT EIGHT-->
		<my:char code="&#x39;" value="39" altvalue="F039" entity="&#x0039;"/> <!--DIGIT NINE-->
		<my:char code="&#x3A;" value="3A" altvalue="F03A" entity="&#x003A;"/> <!--COLON-->
		<my:char code="&#x3B;" value="3B" altvalue="F03B" entity="&#x003B;"/> <!--SEMICOLON-->
		<my:char code="&#x3C;" value="3C" altvalue="F03C" entity="&#x003C;"/> <!--LESS-THAN SIGN-->
		<my:char code="&#x3D;" value="3D" altvalue="F03D" entity="&#x003D;"/> <!--EQUALS SIGN-->
		<my:char code="&#x3E;" value="3E" altvalue="F03E" entity="&#x003E;"/> <!--GREATER-THAN SIGN-->
		<my:char code="&#x3F;" value="3F" altvalue="F03F" entity="&#x003F;"/> <!--QUESTION MARK-->
		<my:char code="&#x40;" value="40" altvalue="F040" entity="&#x2245;"/> <!--APPROXIMATELY EQUAL TO-->
		<my:char code="&#x41;" value="41" altvalue="F041" entity="&#x0391;"/> <!--GREEK CAPITAL LETTER ALPHA-->
		<my:char code="&#x42;" value="42" altvalue="F042" entity="&#x0392;"/> <!--GREEK CAPITAL LETTER BETA-->
		<my:char code="&#x43;" value="43" altvalue="F043" entity="&#x03A7;"/> <!--GREEK CAPITAL LETTER CHI-->
		<my:char code="&#x44;" value="44" altvalue="F044" entity="&#x0394;"/> <!--GREEK CAPITAL LETTER DELTA-->
		<my:char code="&#x45;" value="45" altvalue="F045" entity="&#x0395;"/> <!--GREEK CAPITAL LETTER EPSILON-->
		<my:char code="&#x46;" value="46" altvalue="F046" entity="&#x03A6;"/> <!--GREEK CAPITAL LETTER PHI-->
		<my:char code="&#x47;" value="47" altvalue="F047" entity="&#x0393;"/> <!--GREEK CAPITAL LETTER GAMMA-->
		<my:char code="&#x48;" value="48" altvalue="F048" entity="&#x0397;"/> <!--GREEK CAPITAL LETTER ETA-->
		<my:char code="&#x49;" value="49" altvalue="F049" entity="&#x0399;"/> <!--GREEK CAPITAL LETTER IOTA-->
		<my:char code="&#x4A;" value="4A" altvalue="F04A" entity="&#x03D1;"/> <!--GREEK THETA SYMBOL-->
		<my:char code="&#x4B;" value="4B" altvalue="F04B" entity="&#x039A;"/> <!--GREEK CAPITAL LETTER KAPPA-->
		<my:char code="&#x4C;" value="4C" altvalue="F04C" entity="&#x039B;"/> <!--GREEK CAPITAL LETTER LAMDA-->
		<my:char code="&#x4D;" value="4D" altvalue="F04D" entity="&#x039C;"/> <!--GREEK CAPITAL LETTER MU-->
		<my:char code="&#x4E;" value="4E" altvalue="F04E" entity="&#x039D;"/> <!--GREEK CAPITAL LETTER NU-->
		<my:char code="&#x4F;" value="4F" altvalue="F04F" entity="&#x039F;"/> <!--GREEK CAPITAL LETTER OMICRON-->
		<my:char code="&#x50;" value="50" altvalue="F050" entity="&#x03A0;"/> <!--GREEK CAPITAL LETTER PI-->
		<my:char code="&#x51;" value="51" altvalue="F051" entity="&#x0398;"/> <!--GREEK CAPITAL LETTER THETA-->
		<my:char code="&#x52;" value="52" altvalue="F052" entity="&#x03A1;"/> <!--GREEK CAPITAL LETTER RHO-->
		<my:char code="&#x53;" value="53" altvalue="F053" entity="&#x03A3;"/> <!--GREEK CAPITAL LETTER SIGMA-->
		<my:char code="&#x54;" value="54" altvalue="F054" entity="&#x03A4;"/> <!--GREEK CAPITAL LETTER TAU-->
		<my:char code="&#x55;" value="55" altvalue="F055" entity="&#x03A5;"/> <!--GREEK CAPITAL LETTER UPSILON-->
		<my:char code="&#x56;" value="56" altvalue="F056" entity="&#x03C2;"/> <!--GREEK SMALL LETTER FINAL SIGMA-->
		<my:char code="&#x57;" value="57" altvalue="F057" entity="&#x03A9;"/> <!--GREEK CAPITAL LETTER OMEGA-->
		<my:char code="&#x58;" value="58" altvalue="F058" entity="&#x039E;"/> <!--GREEK CAPITAL LETTER XI-->
		<my:char code="&#x59;" value="59" altvalue="F059" entity="&#x03A8;"/> <!--GREEK CAPITAL LETTER PSI-->
		<my:char code="&#x5A;" value="5A" altvalue="F05A" entity="&#x0396;"/> <!--GREEK CAPITAL LETTER ZETA-->
		<my:char code="&#x5B;" value="5B" altvalue="F05B" entity="&#x005B;"/> <!--LEFT SQUARE BRACKET-->
		<my:char code="&#x5C;" value="5C" altvalue="F05C" entity="&#x2234;"/> <!--THEREFORE-->
		<my:char code="&#x5D;" value="5D" altvalue="F05D" entity="&#x005D;"/> <!--RIGHT SQUARE BRACKET-->
		<my:char code="&#x5E;" value="5E" altvalue="F05E" entity="&#x22A5;"/> <!--UP TACK-->
		<my:char code="&#x5F;" value="5F" altvalue="F05F" entity="&#x005F;"/> <!--LOW LINE-->
		<my:char code="&#x60;" value="60" altvalue="F060" entity="&#x203E;"/> <!--radical extender # corporate char-->
		<my:char code="&#x61;" value="61" altvalue="F061" entity="&#x03B1;"/> <!--GREEK SMALL LETTER ALPHA-->
		<my:char code="&#x62;" value="62" altvalue="F062" entity="&#x03B2;"/> <!--GREEK SMALL LETTER BETA-->
		<my:char code="&#x63;" value="63" altvalue="F063" entity="&#x03C7;"/> <!--GREEK SMALL LETTER CHI-->
		<my:char code="&#x64;" value="64" altvalue="F064" entity="&#x03B4;"/> <!--GREEK SMALL LETTER DELTA-->
		<my:char code="&#x65;" value="65" altvalue="F065" entity="&#x03B5;"/> <!--GREEK SMALL LETTER EPSILON-->
		<my:char code="&#x66;" value="66" altvalue="F066" entity="&#x03C6;"/> <!--GREEK SMALL LETTER PHI-->
		<my:char code="&#x67;" value="67" altvalue="F067" entity="&#x03B3;"/> <!--GREEK SMALL LETTER GAMMA-->
		<my:char code="&#x68;" value="68" altvalue="F068" entity="&#x03B7;"/> <!--GREEK SMALL LETTER ETA-->
		<my:char code="&#x69;" value="69" altvalue="F069" entity="&#x03B9;"/> <!--GREEK SMALL LETTER IOTA-->
		<my:char code="&#x6A;" value="6A" altvalue="F06A" entity="&#x03D6;"/> <!--GREEK PHI SYMBOL-->
		<my:char code="&#x6B;" value="6B" altvalue="F06B" entity="&#x03BA;"/> <!--GREEK SMALL LETTER KAPPA-->
		<my:char code="&#x6C;" value="6C" altvalue="F06C" entity="&#x03BB;"/> <!--GREEK SMALL LETTER LAMDA-->
		<my:char code="&#x6D;" value="6D" altvalue="F06D" entity="&#x03BC;"/> <!--GREEK SMALL LETTER MU-->
		<my:char code="&#x6E;" value="6E" altvalue="F06E" entity="&#x03BD;"/> <!--GREEK SMALL LETTER NU-->
		<my:char code="&#x6F;" value="6F" altvalue="F06F" entity="&#x03BF;"/> <!--GREEK SMALL LETTER OMICRON-->
		<my:char code="&#x70;" value="70" altvalue="F070" entity="&#x03C0;"/> <!--GREEK SMALL LETTER PI-->
		<my:char code="&#x71;" value="71" altvalue="F071" entity="&#x03B8;"/> <!--GREEK SMALL LETTER THETA-->
		<my:char code="&#x72;" value="72" altvalue="F072" entity="&#x03C1;"/> <!--GREEK SMALL LETTER RHO-->
		<my:char code="&#x73;" value="73" altvalue="F073" entity="&#x03C3;"/> <!--GREEK SMALL LETTER SIGMA-->
		<my:char code="&#x74;" value="74" altvalue="F074" entity="&#x03C4;"/> <!--GREEK SMALL LETTER TAU-->
		<my:char code="&#x75;" value="75" altvalue="F075" entity="&#x03C5;"/> <!--GREEK SMALL LETTER UPSILON-->
		<my:char code="&#x76;" value="76" altvalue="F076" entity="&#x03D6;"/> <!--GREEK PI SYMBOL-->
		<my:char code="&#x77;" value="77" altvalue="F077" entity="&#x03C9;"/> <!--GREEK SMALL LETTER OMEGA-->
		<my:char code="&#x78;" value="78" altvalue="F078" entity="&#x03BE;"/> <!--GREEK SMALL LETTER XI-->
		<my:char code="&#x79;" value="79" altvalue="F079" entity="&#x03C8;"/> <!--GREEK SMALL LETTER PSI-->
		<my:char code="&#x7A;" value="7A" altvalue="F07A" entity="&#x03B6;"/> <!--GREEK SMALL LETTER ZETA-->
		<!--<my:char code="&#x7B;" value="7B" altvalue="F07B" entity="&#x007B;"/>--> <!--LEFT CURLY BRACKET-->
		<my:char code="&#x7B;&#x7B;" value="7B" altvalue="F07B" entity="&#x007B;&#x007B;"/> <!--LEFT CURLY BRACKET-->
		<my:char code="&#x7C;" value="7C" altvalue="F07C" entity="&#x007C;"/> <!--VERTICAL LINE-->
		<!--<my:char code="&#x7D;" value="7D" altvalue="F07D" entity="&#x007D;"/>--> <!--RIGHT CURLY BRACKET-->
		<my:char code="&#x7D;&#x7D;" value="7D" altvalue="F07D" entity="&#x007D;&#x007D;"/> <!--RIGHT CURLY BRACKET-->
		<my:char code="&#x7E;" value="7E" altvalue="F07E" entity="&#x223C;"/> <!--TILDE OPERATOR-->
		<my:char code="&#xA0;" value="A0" altvalue="F0A0" entity="&#x20AC;"/> <!--EURO SIGN-->
		<my:char code="&#xA1;" value="A1" altvalue="F0A1" entity="&#x03D2;"/> <!--GREEK UPSILON WITH HOOK SYMBOL-->
		<my:char code="&#xA2;" value="A2" altvalue="F0A2" entity="&#x2032;"/> <!--PRIME	# minute-->
		<my:char code="&#xA3;" value="A3" altvalue="F0A3" entity="&#x2264;"/> <!--LESS-THAN OR EQUAL TO-->
		<my:char code="&#xA4;" value="A4" altvalue="F0A4" entity="&#x2044;"/> <!--FRACTION SLASH-->
		<my:char code="&#xA5;" value="A5" altvalue="F0A5" entity="&#x221E;"/> <!--INFINITY-->
		<my:char code="&#xA6;" value="A6" altvalue="F0A6" entity="&#x0192;"/> <!--LATIN SMALL LETTER F WITH HOOK-->
		<my:char code="&#xA7;" value="A7" altvalue="F0A7" entity="&#x2663;"/> <!--BLACK CLUB SUIT-->
		<my:char code="&#xA8;" value="A8" altvalue="F0A8" entity="&#x2666;"/> <!--BLACK DIAMOND SUIT-->
		<my:char code="&#xA9;" value="A9" altvalue="F0A9" entity="&#x2665;"/> <!--BLACK HEART SUIT-->
		<my:char code="&#xAA;" value="AA" altvalue="F0AA" entity="&#x2660;"/> <!--BLACK SPADE SUIT-->
		<my:char code="&#xAB;" value="AB" altvalue="F0AB" entity="&#x2194;"/> <!--LEFT RIGHT ARROW-->
		<my:char code="&#xAC;" value="AC" altvalue="F0AC" entity="&#x2190;"/> <!--LEFTWARDS ARROW-->
		<my:char code="&#xAD;" value="AD" altvalue="F0AD" entity="&#x2191;"/> <!--UPWARDS ARROW-->
		<my:char code="&#xAE;" value="AE" altvalue="F0AE" entity="&#x2192;"/> <!--RIGHTWARDS ARROW-->
		<my:char code="&#xAF;" value="AF" altvalue="F0AF" entity="&#x2193;"/> <!--DOWNWARDS ARROW-->
		<my:char code="&#xB0;" value="B0" altvalue="F0B0" entity="&#x00B0;"/> <!--DEGREE SIGN-->
		<my:char code="&#xB1;" value="B1" altvalue="F0B1" entity="&#x00B1;"/> <!--PLUS-MINUS SIGN-->
		<my:char code="&#xB2;" value="B2" altvalue="F0B2" entity="&#x2033;"/> <!--DOUBLE PRIME	# second-->
		<my:char code="&#xB3;" value="B3" altvalue="F0B3" entity="&#x2265;"/> <!--GREATER-THAN OR EQUAL TO-->
		<my:char code="&#xB4;" value="B4" altvalue="F0B4" entity="&#x00D7;"/> <!--MULTIPLICATION SIGN-->
		<my:char code="&#xB5;" value="B5" altvalue="F0B5" entity="&#x221D;"/> <!--PROPORTIONAL TO-->
		<my:char code="&#xB6;" value="B6" altvalue="F0B6" entity="&#x2202;"/> <!--PARTIAL DIFFERENTIAL-->
		<my:char code="&#xB7;" value="B7" altvalue="F0B7" entity="&#x2022;"/> <!--BULLET-->
		<my:char code="&#xB8;" value="B8" altvalue="F0B8" entity="&#x00F7;"/> <!--DIVISION SIGN-->
		<my:char code="&#xB9;" value="B9" altvalue="F0B9" entity="&#x2260;"/> <!--NOT EQUAL TO-->
		<my:char code="&#xBA;" value="BA" altvalue="F0BA" entity="&#x2261;"/> <!--IDENTICAL TO-->
		<my:char code="&#xBB;" value="BB" altvalue="F0BB" entity="&#x2248;"/> <!--ALMOST EQUAL TO-->
		<my:char code="&#xBC;" value="BC" altvalue="F0BC" entity="&#x2026;"/> <!--HORIZONTAL ELLIPSIS-->
		<my:char code="&#xBD;" value="BD" altvalue="F0BD" entity="&#x23D0;"/> <!--VERTICAL LINE EXTENSION (for arrows) # for Unicode 4.0 and later-->
		<my:char code="&#xBE;" value="BE" altvalue="F0BE" entity="&#x23AF;"/> <!--HORIZONTAL LINE EXTENSION (for arrows) # for Unicode 3.2 and later-->
		<my:char code="&#xBF;" value="BF" altvalue="F0BF" entity="&#x21B5;"/> <!--DOWNWARDS ARROW WITH CORNER LEFTWARDS-->
		<my:char code="&#xC0;" value="C0" altvalue="F0C0" entity="&#x2135;"/> <!--ALEF SYMBOL-->
		<my:char code="&#xC1;" value="C1" altvalue="F0C1" entity="&#x2111;"/> <!--BLACK-LETTER CAPITAL I-->
		<my:char code="&#xC2;" value="C2" altvalue="F0C2" entity="&#x211C;"/> <!--BLACK-LETTER CAPITAL R-->
		<my:char code="&#xC3;" value="C3" altvalue="F0C3" entity="&#x2118;"/> <!--SCRIPT CAPITAL P-->
		<my:char code="&#xC4;" value="C4" altvalue="F0C4" entity="&#x2297;"/> <!--CIRCLED TIMES-->
		<my:char code="&#xC5;" value="C5" altvalue="F0C5" entity="&#x2295;"/> <!--CIRCLED PLUS-->
		<my:char code="&#xC6;" value="C6" altvalue="F0C6" entity="&#x2205;"/> <!--EMPTY SET-->
		<my:char code="&#xC7;" value="C7" altvalue="F0C7" entity="&#x2229;"/> <!--INTERSECTION-->
		<my:char code="&#xC8;" value="C8" altvalue="F0C8" entity="&#x222A;"/> <!--UNION-->
		<my:char code="&#xC9;" value="C9" altvalue="F0C9" entity="&#x2283;"/> <!--SUPERSET OF-->
		<my:char code="&#xCA;" value="CA" altvalue="F0CA" entity="&#x2287;"/> <!--SUPERSET OF OR EQUAL TO-->
		<my:char code="&#xCB;" value="CB" altvalue="F0CB" entity="&#x2284;"/> <!--NOT A SUBSET OF-->
		<my:char code="&#xCC;" value="CC" altvalue="F0CC" entity="&#x2282;"/> <!--SUBSET OF-->
		<my:char code="&#xCD;" value="CD" altvalue="F0CD" entity="&#x2286;"/> <!--SUBSET OF OR EQUAL TO-->
		<my:char code="&#xCE;" value="CE" altvalue="F0CE" entity="&#x2208;"/> <!--ELEMENT OF-->
		<my:char code="&#xCF;" value="CF" altvalue="F0CF" entity="&#x2209;"/> <!--NOT AN ELEMENT OF-->
		<my:char code="&#xD0;" value="D0" altvalue="F0D0" entity="&#x2220;"/> <!--ANGLE-->
		<my:char code="&#xD1;" value="D1" altvalue="F0D1" entity="&#x2207;"/> <!--NABLA-->
		<my:char code="&#xD2;" value="D2" altvalue="F0D2" entity="&#x00AE;"/> <!--REGISTERED SIGN # serif-->
		<my:char code="&#xD3;" value="D3" altvalue="F0D3" entity="&#x00A9;"/> <!--COPYRIGHT SIGN # serif-->
		<my:char code="&#xD4;" value="D4" altvalue="F0D4" entity="&#x2122;"/> <!--TRADE MARK SIGN # serif-->
		<my:char code="&#xD5;" value="D5" altvalue="F0D5" entity="&#x220F;"/> <!--N-ARY PRODUCT-->
		<my:char code="&#xD6;" value="D6" altvalue="F0D6" entity="&#x221A;"/> <!--SQUARE ROOT-->
		<my:char code="&#xD7;" value="D7" altvalue="F0D7" entity="·"/> <!--DOT OPERATOR-->
		<my:char code="&#xD8;" value="D8" altvalue="F0D8" entity="&#x00AC;"/> <!--NOT SIGN-->
		<my:char code="&#xD9;" value="D9" altvalue="F0D9" entity="&#x2227;"/> <!--LOGICAL AND-->
		<my:char code="&#xDA;" value="DA" altvalue="F0DA" entity="&#x2228;"/> <!--LOGICAL OR-->
		<my:char code="&#xDB;" value="DB" altvalue="F0DB" entity="&#x21D4;"/> <!--LEFT RIGHT DOUBLE ARROW-->
		<my:char code="&#xDC;" value="DC" altvalue="F0DC" entity="&#x21D0;"/> <!--LEFTWARDS DOUBLE ARROW-->
		<my:char code="&#xDD;" value="DD" altvalue="F0DD" entity="&#x21D1;"/> <!--UPWARDS DOUBLE ARROW-->
		<my:char code="&#xDE;" value="DE" altvalue="F0DE" entity="&#x21D2;"/> <!--RIGHTWARDS DOUBLE ARROW-->
		<my:char code="&#xDF;" value="DF" altvalue="F0DF" entity="&#x21D3;"/> <!--DOWNWARDS DOUBLE ARROW-->
		<my:char code="&#xE0;" value="E0" altvalue="F0E0" entity="&#x22C4;"/> <!--DIAMOND OPERATOR-->
		<my:char code="&#xE1;" value="E1" altvalue="F0E1" entity="&#x3008;"/> <!--LEFT ANGLE BRACKET-->
		<my:char code="&#xE2;" value="E2" altvalue="F0E2" entity="&#x00AE;"/> <!--REGISTERED SIGN # sans serif-->
		<my:char code="&#xE3;" value="E3" altvalue="F0E3" entity="&#x00A9;"/> <!--COPYRIGHT SIGN # sans serif-->
		<my:char code="&#xE4;" value="E4" altvalue="F0E4" entity="&#x2122;"/> <!--TRADE MARK SIGN # sans serif-->
		<my:char code="&#xE5;" value="E5" altvalue="F0E5" entity="&#x2211;"/> <!--N-ARY SUMMATION-->
		<my:char code="&#xE6;" value="E6" altvalue="F0E6" entity="&#x239B;"/> <!--LEFT PARENTHESIS UPPER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xE7;" value="E7" altvalue="F0E7" entity="&#x239C;"/> <!--LEFT PARENTHESIS EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xE8;" value="E8" altvalue="F0E8" entity="&#x239D;"/> <!--LEFT PARENTHESIS LOWER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xE9;" value="E9" altvalue="F0E9" entity="&#x23A1;"/> <!--LEFT SQUARE BRACKET UPPER CORNER # for Unicode 3.2 and later-->
		<my:char code="&#xEA;" value="EA" altvalue="F0EA" entity="&#x23A2;"/> <!--LEFT SQUARE BRACKET EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xEB;" value="EB" altvalue="F0EB" entity="&#x23A3;"/> <!--LEFT SQUARE BRACKET LOWER CORNER # for Unicode 3.2 and later-->
		<my:char code="&#xEC;" value="EC" altvalue="F0EC" entity="&#x23A7;"/> <!--LEFT CURLY BRACKET UPPER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xED;" value="ED" altvalue="F0ED" entity="&#x23A8;"/> <!--LEFT CURLY BRACKET MIDDLE PIECE # for Unicode 3.2 and later-->
		<my:char code="&#xEE;" value="EE" altvalue="F0EE" entity="&#x23A9;"/> <!--LEFT CURLY BRACKET LOWER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xEF;" value="EF" altvalue="F0EF" entity="&#x23AA;"/> <!--CURLY BRACKET EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xF0;" value="F0" altvalue="F0F0" entity="&#xF8FF;"/> <!--Apple logo-->
		<my:char code="&#xF1;" value="F1" altvalue="F0F1" entity="&#x3009;"/> <!--RIGHT ANGLE BRACKET-->
		<my:char code="&#xF2;" value="F2" altvalue="F0F2" entity="&#x222B;"/> <!--INTEGRAL-->
		<my:char code="&#xF3;" value="F3" altvalue="F0F3" entity="&#x2320;"/> <!--TOP HALF INTEGRAL-->
		<my:char code="&#xF4;" value="F4" altvalue="F0F4" entity="&#x23AE;"/> <!--INTEGRAL EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xF5;" value="F5" altvalue="F0F5" entity="&#x2321;"/> <!--BOTTOM HALF INTEGRAL-->
		<my:char code="&#xF6;" value="F6" altvalue="F0F6" entity="&#x239E;"/> <!--RIGHT PARENTHESIS UPPER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xF7;" value="F7" altvalue="F0F7" entity="&#x239F;"/> <!--RIGHT PARENTHESIS EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xF8;" value="F8" altvalue="F0F8" entity="&#x23A0;"/> <!--RIGHT PARENTHESIS LOWER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xF9;" value="F9" altvalue="F0F9" entity="&#x23A4;"/> <!--RIGHT SQUARE BRACKET UPPER CORNER # for Unicode 3.2 and later-->
		<my:char code="&#xFA;" value="FA" altvalue="F0FA" entity="&#x23A5;"/> <!--RIGHT SQUARE BRACKET EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xFB;" value="FB" altvalue="F0FB" entity="&#x23A6;"/> <!--RIGHT SQUARE BRACKET LOWER CORNER # for Unicode 3.2 and later-->
		<my:char code="&#xFC;" value="FC" altvalue="F0FC" entity="&#x23AB;"/> <!--RIGHT CURLY BRACKET UPPER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xFD;" value="FD" altvalue="F0FD" entity="&#x23AC;"/> <!--RIGHT CURLY BRACKET MIDDLE PIECE # for Unicode 3.2 and later-->
		<my:char code="&#xFE;" value="FE" altvalue="F0FE" entity="&#x23AD;"/> <!--RIGHT CURLY BRACKET LOWER HOOK # for Unicode 3.2 and later-->
	</my:recoding-table>

	<!-- ============== -->
	<!-- Wingdings font -->
	<!-- ============== -->
	<!-- 03/06/2006: Provided a comprehensive recoding table for many more Wingdings characters -->
	<!-- Attention! If you use @code or @entity attribute value (also for searching), you should use only first character of attribute value! -->
	<!-- In some cases value of attributes @code and @entity is doubled for compatibility reason. -->
	<!-- See http://www.w3.org/TR/xslt#attribute-value-templates 7.6.2 Attribute Value Templates -->
	<!-- It is an error if a right curly brace occurs in an attribute value template outside an expression without being followed by a second right curly brace. -->
	<my:recoding-table font="Wingdings">
		<my:char code="&#x22;" value="22" altvalue="F022" entity="&#x2702;"/>
		<my:char code="&#x23;" value="23" altvalue="F023" entity="&#x2701;"/>
		<my:char code="&#x28;" value="28" altvalue="F028" entity="&#x260E;"/>
		<my:char code="&#x2A;" value="2A" altvalue="F02A" entity="&#x2709;"/>
		<my:char code="&#x3E;" value="3E" altvalue="F03E" entity="&#x2622;"/>
		<my:char code="&#x3F;" value="3F" altvalue="F03F" entity="&#x270D;"/>
		<my:char code="&#x41;" value="41" altvalue="F041" entity="&#x270C;"/>
		<my:char code="&#x46;" value="46" altvalue="F046" entity="&#x261E;"/>
		<my:char code="&#x4C;" value="4C" altvalue="F04C" entity="&#x2639;"/>
		<my:char code="&#x58;" value="58" altvalue="F058" entity="&#x2720;"/>
		<my:char code="&#x59;" value="59" altvalue="F059" entity="&#x2721;"/>
		<my:char code="&#x5A;" value="5A" altvalue="F05A" entity="&#x262A;"/>
		<my:char code="&#x5B;" value="5B" altvalue="F05B" entity="&#x262F;"/>
		<my:char code="&#x5D;" value="5D" altvalue="F05D" entity="&#x2638;"/>
		<my:char code="&#x52;" value="52" altvalue="F052" entity="&#x263C;"/>
		<my:char code="&#x5E;" value="5E" altvalue="F05E" entity="&#x2648;"/>
		<my:char code="&#x5F;" value="5F" altvalue="F05F" entity="&#x2649;"/>
		<my:char code="&#x60;" value="60" altvalue="F060" entity="&#x264A;"/>
		<my:char code="&#x61;" value="61" altvalue="F061" entity="&#x264B;"/>
		<my:char code="&#x62;" value="62" altvalue="F062" entity="&#x264C;"/>
		<my:char code="&#x63;" value="63" altvalue="F063" entity="&#x264D;"/>
		<my:char code="&#x64;" value="64" altvalue="F064" entity="&#x264E;"/>
		<my:char code="&#x65;" value="65" altvalue="F065" entity="&#x264F;"/>
		<my:char code="&#x66;" value="66" altvalue="F066" entity="&#x2650;"/>
		<my:char code="&#x67;" value="67" altvalue="F067" entity="&#x2651;"/>
		<my:char code="&#x68;" value="68" altvalue="F068" entity="&#x2652;"/>
		<my:char code="&#x69;" value="69" altvalue="F069" entity="&#x2653;"/>
		<my:char code="&#x6C;" value="6C" altvalue="F06C" entity="&#x25CF;"/>
		<my:char code="&#x6D;" value="6D" altvalue="F06D" entity="&#x274D;"/>
		<my:char code="&#x6E;" value="6E" altvalue="F06E" entity="&#x25A0;"/>
		<my:char code="&#x6F;" value="6F" altvalue="F06F" entity="&#x25A1;"/>
		<my:char code="&#x71;" value="71" altvalue="F071" entity="&#x2751;"/>
		<my:char code="&#x72;" value="72" altvalue="F072" entity="&#x2752;"/>
		<my:char code="&#x76;" value="76" altvalue="F076" entity="&#x2756;"/>
		<my:char code="&#x77;" value="77" altvalue="F077" entity="&#x25C6;"/>
		<!--<my:char code="&#x7B;" value="7B" altvalue="F07B" entity="&#x2740;"/>-->
		<my:char code="&#x7B;&#x7B;" value="7B" altvalue="F07B" entity="&#x2740;"/>
		<!--<my:char code="&#x7D;" value="7D" altvalue="F07D" entity="&#x275D;"/>-->
		<my:char code="&#x7D;&#x7D;" value="7D" altvalue="F07D" entity="&#x275D;"/>
		<my:char code="&#x7E;" value="7E" altvalue="F07E" entity="&#x275E;"/>
		<my:char code="&#x81;" value="81" altvalue="F081" entity="&#x2460;"/>
		<my:char code="&#x82;" value="82" altvalue="F082" entity="&#x2461;"/>
		<my:char code="&#x83;" value="83" altvalue="F083" entity="&#x2462;"/>
		<my:char code="&#x84;" value="84" altvalue="F084" entity="&#x2463;"/>
		<my:char code="&#x85;" value="85" altvalue="F085" entity="&#x2464;"/>
		<my:char code="&#x86;" value="86" altvalue="F086" entity="&#x2465;"/>
		<my:char code="&#x87;" value="87" altvalue="F087" entity="&#x2466;"/>
		<my:char code="&#x88;" value="88" altvalue="F088" entity="&#x2467;"/>
		<my:char code="&#x89;" value="89" altvalue="F089" entity="&#x2468;"/>
		<my:char code="&#x8A;" value="8A" altvalue="F08A" entity="&#x2469;"/>
		<my:char code="&#x8C;" value="8C" altvalue="F08C" entity="&#x2776;"/>
		<my:char code="&#x8D;" value="8D" altvalue="F08D" entity="&#x2777;"/>
		<my:char code="&#x8E;" value="8E" altvalue="F08E" entity="&#x2778;"/>
		<my:char code="&#x8F;" value="8F" altvalue="F08F" entity="&#x2779;"/>
		<my:char code="&#x90;" value="90" altvalue="F090" entity="&#x277A;"/>
		<my:char code="&#x91;" value="91" altvalue="F091" entity="&#x277B;"/>
		<my:char code="&#x92;" value="92" altvalue="F092" entity="&#x277C;"/>
		<my:char code="&#x93;" value="93" altvalue="F093" entity="&#x277D;"/>
		<my:char code="&#x94;" value="94" altvalue="F094" entity="&#x277E;"/>
		<my:char code="&#x95;" value="95" altvalue="F095" entity="&#x277F;"/>
		<my:char code="&#x9F;" value="9F" altvalue="F09F" entity="&#x2022;"/>
		<my:char code="&#xA1;" value="A1" altvalue="F0A1" entity="&#x25CC;"/>
		<my:char code="&#xA4;" value="A4" altvalue="F0A4" entity="&#x25C9;"/>
		<my:char code="&#xA6;" value="A6" altvalue="F0A6" entity="&#x274D;"/>
		<my:char code="&#xAA;" value="AA" altvalue="F0AA" entity="&#x2726;"/>
		<my:char code="&#xAB;" value="AB" altvalue="F0AB" entity="&#x2605;"/>
		<my:char code="&#xAC;" value="AC" altvalue="F0AC" entity="&#x2736;"/>
		<my:char code="&#xAD;" value="AD" altvalue="F0AD" entity="&#x2737;"/>
		<my:char code="&#xAE;" value="AE" altvalue="F0AE" entity="&#x2739;"/>
		<my:char code="&#xAF;" value="AF" altvalue="F0AF" entity="&#x2735;"/>
		<my:char code="&#xD5;" value="D5" altvalue="F0D5" entity="&#x232B;"/>
		<my:char code="&#xD6;" value="D6" altvalue="F0D6" entity="&#x2326;"/>
		<my:char code="&#xEF;" value="EF" altvalue="F0EF" entity="&#x21E6;"/>
		<my:char code="&#xF0;" value="F0" altvalue="F0F0" entity="&#x21E8;"/>
		<my:char code="&#xF1;" value="F1" altvalue="F0F1" entity="&#x21E7;"/>
		<my:char code="&#xF2;" value="F2" altvalue="F0F2" entity="&#x21E9;"/>
		<my:char code="&#xFB;" value="FB" altvalue="F0FB" entity="&#x2718;"/>
		<my:char code="&#xFC;" value="FC" altvalue="F0FC" entity="&#x2713;"/>
		<my:char code="&#xFD;" value="FD" altvalue="F0FD" entity="&#x2612;"/>
		<my:char code="&#xFE;" value="FE" altvalue="F0FE" entity="&#x2611;"/>      
	</my:recoding-table>
  </xsl:param>
</xsl:stylesheet>