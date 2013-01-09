<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:aml="http://schemas.microsoft.com/aml/2001/core"
                xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
                xmlns:v="urn:schemas-microsoft-com:vml"
                version="2.0">


    <!--<xsl:include href="./Word2FO/stylesheets/Word2FO.xsl"/>-->
    <xsl:include href=".\Word2FO\stylesheets\Word2FO.xsl"/>

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
<xsl:text disable-output-escaping="yes">&lt;</xsl:text>xsl:value-of select="<xsl:value-of select="concat($prefix, $processedNodeSelector)"/>"<xsl:text disable-output-escaping="yes">/></xsl:text>
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
</xsl:stylesheet>

             