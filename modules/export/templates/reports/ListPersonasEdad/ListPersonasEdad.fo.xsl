<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

    <xsl:template match="/*">           
        <fo:root font-family="Calibri" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml">
            <fo:layout-master-set xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint" xmlns:aml="http://schemas.microsoft.com/aml/2001/core" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882">
                <fo:simple-page-master master-name="section1-first-page" page-width="8.5in" page-height="11in" margin-top="36pt" margin-bottom="36pt" margin-right="72pt" margin-left="72pt">
                    <fo:region-body margin-top="36pt" margin-bottom="36pt"/>
                    <fo:region-before region-name="first-page-header" extent="11in"/>
                    <fo:region-after region-name="first-page-footer" extent="11in" display-align="after"/>
                </fo:simple-page-master>
                <fo:simple-page-master master-name="section1-odd-page" page-width="8.5in" page-height="11in" margin-top="36pt" margin-bottom="36pt" margin-right="72pt" margin-left="72pt">
                    <fo:region-body margin-top="36pt" margin-bottom="36pt"/>
                    <fo:region-before region-name="odd-page-header" extent="11in"/>
                    <fo:region-after region-name="odd-page-footer" extent="11in" display-align="after"/>
                </fo:simple-page-master>
                <fo:simple-page-master master-name="section1-even-page" page-width="8.5in" page-height="11in" margin-top="36pt" margin-bottom="36pt" margin-right="72pt" margin-left="72pt">
                    <fo:region-body margin-top="36pt" margin-bottom="36pt"/>
                    <fo:region-before region-name="even-page-header" extent="11in"/>
                    <fo:region-after region-name="even-page-footer" extent="11in" display-align="after"/>
                </fo:simple-page-master>
                <fo:page-sequence-master master-name="section1-page-sequence-master">
                    <fo:repeatable-page-master-alternatives>
                        <fo:conditional-page-master-reference odd-or-even="odd" master-reference="section1-odd-page" />
                        <fo:conditional-page-master-reference odd-or-even="even" master-reference="section1-even-page" />
                    </fo:repeatable-page-master-alternatives>
                </fo:page-sequence-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="section1-page-sequence-master" id="IDAFYKGB" format="1" xmlns:rx="http://www.renderx.com/XSL/Extensions" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint" xmlns:aml="http://schemas.microsoft.com/aml/2001/core" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882">
                <fo:static-content flow-name="first-page-header">
                    <fo:retrieve-marker retrieve-class-name="first-page-header" retrieve-position="first-including-carryover" retrieve-boundary="page" />
                </fo:static-content>
                <fo:static-content flow-name="first-page-footer">
                    <fo:retrieve-marker retrieve-class-name="first-page-footer" retrieve-position="first-including-carryover" retrieve-boundary="page" />
                </fo:static-content>
                <fo:static-content flow-name="odd-page-header">
                    <fo:retrieve-marker retrieve-class-name="odd-page-header" retrieve-position="first-including-carryover" retrieve-boundary="page" />
                </fo:static-content>
                <fo:static-content flow-name="odd-page-footer">
                    <fo:retrieve-marker retrieve-class-name="odd-page-footer" retrieve-position="first-including-carryover" retrieve-boundary="page" />
                </fo:static-content>
                <fo:static-content flow-name="even-page-header">
                    <fo:retrieve-marker retrieve-class-name="odd-page-header" retrieve-position="first-including-carryover" retrieve-boundary="page" />
                </fo:static-content>
                <fo:static-content flow-name="even-page-footer">
                    <fo:retrieve-marker retrieve-class-name="odd-page-footer" retrieve-position="first-including-carryover" retrieve-boundary="page" />
                </fo:static-content>
                <fo:static-content flow-name="xsl-footnote-separator">
                    <fo:block>
                        <fo:leader leader-pattern="rule" leader-length="144pt" rule-thickness="1pt" rule-style="solid" color="gray" />
                    </fo:block>
                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block widows="2" orphans="2" font-size="10pt" line-height="1.147" white-space-collapse="false">
                        <fo:marker marker-class-name="first-page-header" xmlns:st1="urn:schemas-microsoft-com:office:smarttags" xmlns:svg="http://www.w3.org/2000/svg" />
                        <fo:marker marker-class-name="first-page-footer" xmlns:st1="urn:schemas-microsoft-com:office:smarttags" xmlns:svg="http://www.w3.org/2000/svg" />
                        <fo:marker marker-class-name="odd-page-header" xmlns:st1="urn:schemas-microsoft-com:office:smarttags" xmlns:svg="http://www.w3.org/2000/svg" />
                        <fo:marker marker-class-name="odd-page-footer" xmlns:st1="urn:schemas-microsoft-com:office:smarttags" xmlns:svg="http://www.w3.org/2000/svg" />
                        <fo:marker marker-class-name="even-page-header" xmlns:st1="urn:schemas-microsoft-com:office:smarttags" xmlns:svg="http://www.w3.org/2000/svg" />
                        <fo:marker marker-class-name="even-page-footer" xmlns:st1="urn:schemas-microsoft-com:office:smarttags" xmlns:svg="http://www.w3.org/2000/svg" />
                        <fo:table font-family="Calibri" language="EN-US" start-indent="4.65pt" xmlns:st1="urn:schemas-microsoft-com:office:smarttags" xmlns:svg="http://www.w3.org/2000/svg">
                            <fo:table-column column-number="1" column-width="72.75pt" />
                            <fo:table-column column-number="2" column-width="198pt" />
                            <fo:table-column column-number="3" column-width="189pt" />
                            <xsl:call-template name="table-header"/>
                            <fo:table-body start-indent="0pt" end-indent="0pt">
                                <xsl:apply-templates select="result/Persona_Collection/Persona" />
                            </fo:table-body>
                        </fo:table>
                        <fo:block space-after="10pt" space-after.conditionality="retain" line-height="1.3190500000000002" font-family="Calibri" font-size="11pt" language="EN-US" xmlns:st1="urn:schemas-microsoft-com:office:smarttags" xmlns:svg="http://www.w3.org/2000/svg">
                            <fo:leader />
                        </fo:block>
                        <fo:block space-after="10pt" space-after.conditionality="retain" line-height="1.3190500000000002" font-family="Calibri" font-size="11pt" language="EN-US" xmlns:st1="urn:schemas-microsoft-com:office:smarttags" xmlns:svg="http://www.w3.org/2000/svg">
                            <fo:inline>
                                <xsl:variable name="chart" select="result/chart[1]" />
                                <fo:external-graphic content-width="342.75pt" content-height="166.5pt" src="url(&quot;data:image/png;base64,{$chart}&#xA;&quot;)" />
                            </fo:inline>
                        </fo:block>
                    </fo:block>
                    <fo:block id="IDACYKGB" />
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>


    <xsl:template name="table-header">
        <fo:table-header>
            <fo:table-row height="15pt">
                <fo:table-cell padding-top="0pt" padding-left="5.4pt" padding-bottom="0pt" padding-right="5.4pt" border-top-style="solid" border-top-color="black" border-top-width="1pt" border-left-style="solid" border-left-color="black" border-left-width="1pt" border-bottom-style="solid" border-bottom-color="black" border-bottom-width="1pt" border-right-style="solid" border-right-color="black" border-right-width="1pt" background-color="#538DD5" color="#000000" display-align="after">
                    <fo:block-container>
                        <fo:block space-after="0pt" space-after.conditionality="retain" line-height="1.147" font-family="Calibri" font-size="11pt" language="EN-US">
                            <fo:inline color="#000000">
                                <fo:leader leader-length="0pt" />DNI</fo:inline>
                        </fo:block>
                    </fo:block-container>
                </fo:table-cell>
                <fo:table-cell padding-top="0pt" padding-left="5.4pt" padding-bottom="0pt" padding-right="5.4pt" border-top-style="solid" border-top-color="black" border-top-width="1pt" border-left-style="none" border-bottom-style="solid" border-bottom-color="black" border-bottom-width="1pt" border-right-style="solid" border-right-color="black" border-right-width="1pt" background-color="#538DD5" color="#000000" display-align="after">
                    <fo:block-container>
                        <fo:block space-after="0pt" space-after.conditionality="retain" line-height="1.147" font-family="Calibri" font-size="11pt" language="EN-US">
                            <fo:inline color="#000000">
                                <fo:leader leader-length="0pt" />Nombre</fo:inline>
                        </fo:block>
                    </fo:block-container>
                </fo:table-cell>
                <fo:table-cell padding-top="0pt" padding-left="5.4pt" padding-bottom="0pt" padding-right="5.4pt" border-top-style="solid" border-top-color="black" border-top-width="1pt" border-left-style="none" border-bottom-style="solid" border-bottom-color="black" border-bottom-width="1pt" border-right-style="solid" border-right-color="black" border-right-width="1pt" background-color="#538DD5" color="#000000" display-align="after">
                    <fo:block-container>
                        <fo:block space-after="0pt" space-after.conditionality="retain" line-height="1.147" font-family="Calibri" font-size="11pt" language="EN-US">
                            <fo:inline color="#000000">
                                <fo:leader leader-length="0pt" />Fecha</fo:inline>
                            <fo:inline color="#000000">
                                <fo:leader leader-length="0pt" />
                            </fo:inline>
                            <fo:inline color="#000000">
                                <fo:leader leader-length="0pt" />Nacimiento</fo:inline>
                        </fo:block>
                    </fo:block-container>
                </fo:table-cell>
            </fo:table-row>
        </fo:table-header>
    </xsl:template>

    <xsl:template match="Persona"> 
        <fo:table-row height="15pt">
            <fo:table-cell padding-top="0pt" padding-left="5.4pt" padding-bottom="0pt" padding-right="5.4pt" border-top-style="none" border-left-style="solid" border-left-color="black" border-left-width="1pt" border-bottom-style="solid" border-bottom-color="black" border-bottom-width="1pt" border-right-style="solid" border-right-color="black" border-right-width="1pt" background-color="white" color="black" display-align="after">
                <fo:block-container>
                    <fo:block space-after="0pt" space-after.conditionality="retain" line-height="1.147" font-family="Calibri" font-size="11pt" language="EN-US">
                        <fo:inline color="#000000">
                            <fo:leader leader-length="0pt" /><xsl:value-of select="nro_documento"/></fo:inline>
                    </fo:block>
                </fo:block-container>
            </fo:table-cell>
            <fo:table-cell padding-top="0pt" padding-left="5.4pt" padding-bottom="0pt" padding-right="5.4pt" border-top-style="none" border-left-style="none" border-bottom-style="solid" border-bottom-color="black" border-bottom-width="1pt" border-right-style="solid" border-right-color="black" border-right-width="1pt" background-color="white" color="black" display-align="after">
                <fo:block-container>
                    <fo:block space-after="0pt" space-after.conditionality="retain" line-height="1.147" font-family="Calibri" font-size="11pt" language="EN-US">
                        <fo:inline color="#000000">
                            <fo:leader leader-length="0pt" /><xsl:value-of select="nombre"/></fo:inline>
                    </fo:block>
                </fo:block-container>
            </fo:table-cell>
            <fo:table-cell padding-top="0pt" padding-left="5.4pt" padding-bottom="0pt" padding-right="5.4pt" border-top-style="none" border-left-style="none" border-bottom-style="solid" border-bottom-color="black" border-bottom-width="1pt" border-right-style="solid" border-right-color="black" border-right-width="1pt" background-color="white" color="black" display-align="after">
                <fo:block-container>
                    <fo:block space-after="0pt" space-after.conditionality="retain" line-height="1.147" font-family="Calibri" font-size="11pt" language="EN-US">
                        <fo:inline color="#000000">
                            <fo:leader leader-length="0pt" /><xsl:value-of select="YEAR"/></fo:inline>
                    </fo:block>
                </fo:block-container>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

</xsl:stylesheet>