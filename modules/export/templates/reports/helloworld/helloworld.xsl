<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE formated_object SYSTEM "//XSL">
<xsl:stylesheet version="2.0" xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xbrl="http://www.xbrl.org/core/2000-07-31/instance"
 xmlns:jpcoci="http://www.xbrl-jp.org/jp/comm/ci/2001-10-09">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <fo:root  xmlns:fo="http://www.w3.org/1999/XSL/Format">
            <fo:layout-master-set>
                <fo:simple-page-master master-name="my-page">
                    <fo:region-body margin="1in"/>
                </fo:simple-page-master>
            </fo:layout-master-set>

            <fo:page-sequence master-reference="my-page">
                <fo:flow name="xsl-region-body">
                    <fo:block>
                        <fo:inline>
                             Hello, world!
                        </fo:inline>
                    </fo:block>
                    <child_view name="juan"/>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>
</xsl:stylesheet>
<!--
<?xml version="1.0" encoding="UTF-8" ?>

This is a sample stylesheet for transforming XBRL document for statements of account.

<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xbrl="http://www.xbrl.org/core/2000-07-31/instance"
 xmlns:jpcoci="http://www.xbrl-jp.org/jp/comm/ci/2001-10-09">

<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />

Parameter for the language. Set en for English, set ja for Japanese.
<xsl:param name="langset">en</xsl:param>

Parameter for adjusting number of row. Set an integer of O or more.
<xsl:param name="ajustL1">0</xsl:param>  Parameter for adjusting Assets
<xsl:param name="ajustR1">0</xsl:param>  Parameter for adjusting liabilities
<xsl:param name="ajustR2">0</xsl:param>  Parameter for adjusting Stockholders' Equity.


<xsl:variable name="tani" select="//xbrl:item[contains(@type,':documentInformation.unitOfAmount') and (@lang=$langset or ($langset='ja' and not(@lang)))]" />




<xsl:attribute-set name="table.data">

	<xsl:attribute name="font-family">"Sans-serif"</xsl:attribute>

	<xsl:attribute name="table-layout">fixed</xsl:attribute>
	<xsl:attribute name="space-before">10pt</xsl:attribute>
	<xsl:attribute name="space-after">10pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="table.data.caption">

	<xsl:attribute name="font-family">"Sans-serif"</xsl:attribute>

	<xsl:attribute name="text-align">center</xsl:attribute>
	<xsl:attribute name="space-before">3pt</xsl:attribute>
	<xsl:attribute name="space-after">3pt</xsl:attribute>
	<xsl:attribute name="space-after.precedence">2</xsl:attribute>
	<xsl:attribute name="font-weight">bold</xsl:attribute>
	<xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="table.data.th">
	<xsl:attribute name="background-color">#DDDDDD</xsl:attribute>
	<xsl:attribute name="border-style">solid</xsl:attribute>
	<xsl:attribute name="border-width">1pt</xsl:attribute>
	<xsl:attribute name="padding-start">0.3em</xsl:attribute>
	<xsl:attribute name="padding-end">0.2em</xsl:attribute>
	<xsl:attribute name="padding-before">2pt</xsl:attribute>
	<xsl:attribute name="padding-after">2pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="table.data.td">
	<xsl:attribute name="border-style">none</xsl:attribute>
	<xsl:attribute name="border-width">0.1pt</xsl:attribute>
	<xsl:attribute name="padding-start">0.3em</xsl:attribute>
	<xsl:attribute name="padding-end">0.2em</xsl:attribute>
	<xsl:attribute name="padding-before">2pt</xsl:attribute>
	<xsl:attribute name="padding-after">2pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="dt">
	<xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="dd.list">
	<xsl:attribute name="space-before">0.3em</xsl:attribute>
	<xsl:attribute name="space-after">0.5em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="dd.block" use-attribute-sets="dd.list">
	<xsl:attribute name="start-indent">inherit + 4em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="row-height">
	<xsl:attribute name="block-progression-dimension">5.1mm</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="row-height-for-header">
	<xsl:attribute name="block-progression-dimension">3.5mm</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="block-line-height">
	<xsl:attribute name="line-height">5.1mm</xsl:attribute>
</xsl:attribute-set>


<xsl:template match="/">
	<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
		<fo:layout-master-set>	Page layout setting
			<fo:simple-page-master page-height="297mm" page-width="210mm" margin="20mm 20mm 20mm 20mm" master-name="PageMaster">
				<fo:region-body margin="0mm 0mm 0mm 0mm"/>
			</fo:simple-page-master>
		</fo:layout-master-set>
		<fo:page-sequence initial-page-number="1" master-reference="PageMaster">
			<fo:flow flow-name="xsl-region-body">
				<fo:block xsl:use-attribute-sets="block-line-height">
					<xsl:call-template name="hdr" />	Edit header
					<fo:block>?</fo:block>
					<xsl:call-template name="bs" />		 a balance sheet
					<xsl:call-template name="pl" />		 Edit a statement for profits and losses
					<fo:block>?</fo:block>
					<xsl:call-template name="notes" />	 Edit notes
				</fo:block>
			</fo:flow>
		</fo:page-sequence>
	</fo:root>
</xsl:template>



Edit header
<xsl:template name="hdr">
	<fo:table-and-caption>
		<fo:table-caption xsl:use-attribute-sets="table.data.caption" font-size="17pt">
			<fo:block start-indent="0em">
				<xsl:value-of select="//xbrl:item[contains(@type,':documentInformation.reportName') and (@lang=$langset or ($langset='ja' and not(@lang)))]" />
			</fo:block>
		</fo:table-caption>
		<fo:table xsl:use-attribute-sets="table.data">

			<fo:table-column column-number="1" column-width="85mm"/>
			<fo:table-column column-number="2" column-width="85mm"/>

			<fo:table-body>

				<fo:table-row line-height="3.5mm">
					<fo:table-cell xsl:use-attribute-sets="table.data.td">	  Date
						<fo:block text-align="left">
							<xsl:call-template name="date-edit">
								<xsl:with-param name="seireki" select="//xbrl:item[contains(@type,':documentInformation.dateOfPublicNotice')]" />
							</xsl:call-template>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell xsl:use-attribute-sets="table.data.td" text-align="right">		 Adress
						<fo:block>
							<xsl:value-of select="//xbrl:item[contains(@type,':documentInformation.addressOfRegisteredHeadquarters') and (@lang=$langset or ($langset='ja' and not(@lang)))]" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>

				<fo:table-row line-height="3.5mm">
					<fo:table-cell xsl:use-attribute-sets="table.data.td" />						 Empty
					<fo:table-cell xsl:use-attribute-sets="table.data.td" text-align="right">		 Entity name
						<fo:block>
							<xsl:value-of select="//xbrl:item[contains(@type,':documentInformation.entityName') and (@lang=$langset or ($langset='ja' and not(@lang)))]" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>

				<fo:table-row line-height="3.5mm">
					<fo:table-cell xsl:use-attribute-sets="table.data.td" />						 Empty
					<fo:table-cell xsl:use-attribute-sets="table.data.td" text-align="right">		 Title of representative director
						<fo:block>
							<xsl:value-of select="//xbrl:item[contains(@type,':documentInformation.titleOfRepresentativeDirector') and (@lang=$langset or ($langset='ja' and not(@lang)))]" />
							<xsl:text disable-output-escaping="yes">  </xsl:text>
							<xsl:value-of select="//xbrl:item[contains(@type,':documentInformation.nameOfRepresentativeDirector') and (@lang=$langset or ($langset='ja' and not(@lang)))]" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</fo:table-and-caption>
</xsl:template>


 Edit a balance sheet
<xsl:template name="bs">
	<fo:table-and-caption>
		<fo:table-caption xsl:use-attribute-sets="table.data.caption" font-size="13pt">
			<fo:block start-indent="0em">		Edit a balance sheet
				<xsl:value-of select="//xbrl:label[@lang=$langset and contains(@href,':statements.balanceSheet')]" />
			</fo:block>

			<fo:block start-indent="0em">
				<xsl:if test="$langset='ja'">
					<fo:block start-indent="0em">		 Date
						(
						<xsl:call-template name="date-edit">
							<xsl:with-param name="seireki" select="//xbrl:item[contains(@type,':accountingPeriod.endOfPeriod')]" />
						</xsl:call-template>
						??)
					</fo:block>
				</xsl:if>
				<xsl:if test="$langset!='ja'">
					<fo:block start-indent="0em">
						<xsl:text disable-output-escaping="yes">As of </xsl:text>
						<xsl:call-template name="date-edit">
							<xsl:with-param name="seireki" select="//xbrl:item[contains(@type,':accountingPeriod.endOfPeriod')]" />
						</xsl:call-template>
					</fo:block>
				</xsl:if>
			</fo:block>
			<fo:block text-align="right" font-size="10pt" font-weight="normal">		 unit
				<xsl:if test="$langset='en'">(unit?</xsl:if>
				<xsl:if test="$langset!='en'">(Unit?</xsl:if>
				<xsl:value-of select="$tani" />
					)
			</fo:block>
		</fo:table-caption>

		<xsl:variable name="ptAS">		 Position of assets
			<xsl:for-each select="//xbrl:label[@lang=$langset]">
				<xsl:if test="contains(@href,':balanceSheet.assets')">
					<xsl:value-of select="position()" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="ptAS2">		 Position of total assets
			<xsl:for-each select="//xbrl:label[@lang=$langset]">
				<xsl:if test="contains(@href,':balanceSheet.totalAssets')">
					<xsl:value-of select="position()" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="ptLB">		Position of liabilities
			<xsl:for-each select="//xbrl:label[@lang=$langset]">
				<xsl:if test="contains(@href,':balanceSheet.liabilities')">
					<xsl:value-of select="position()" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="ptEQ">		 Position of Stockholders' Equity
			<xsl:for-each select="//xbrl:label[@lang=$langset]">
				<xsl:if test="contains(@href,':balanceSheet.stockholdersEquity')">
					<xsl:value-of select="position()" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="ptEQ2">		 Position of total liabilities and stockholders' equity liabilities
			<xsl:for-each select="//xbrl:label[@lang=$langset]">
				<xsl:if test="contains(@href,':balanceSheet.totalLiabilitiesAndStockholdersEquity')">
					<xsl:value-of select="position()" />
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>



		<fo:table xsl:use-attribute-sets="table.data">
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell border-style="solid" border-width="0.1pt">
						<fo:table-and-caption>
							 <fo:table-caption />
							<fo:table xsl:use-attribute-sets="table.data">

								<fo:table-column column-number="1" column-width="60mm"/>
								<fo:table-column column-number="2" column-width="0.1pt"/>
								<fo:table-column column-number="3" column-width="25mm"/>

								<fo:table-body border-style="solid" border-width="0.1pt">

									<fo:table-row xsl:use-attribute-sets="row-height">

										<fo:table-cell border-style="solid" border-width="0.1pt">
											<fo:block text-align="center">
												<xsl:if test="$langset='ja'">??????</xsl:if>
												<xsl:if test="$langset!='ja'">Account</xsl:if>
											</fo:block>
										</fo:table-cell>

										<xsl:call-template name="empty-cell"/>

										<fo:table-cell border-style="solid" border-width="0.1pt">
											<fo:block text-align="center">
												<xsl:if test="$langset='ja'">????</xsl:if>
												<xsl:if test="$langset!='ja'">Amount</xsl:if>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>
									<fo:table-row xsl:use-attribute-sets="row-height">

										<fo:table-cell border-style="solid" border-width="0.1pt">		 Assets part
											<fo:block text-align="center">
												<xsl:value-of select="//xbrl:label[@lang=$langset and contains(@href,':balanceSheet.assets')]" />
											</fo:block>
										</fo:table-cell>

										<xsl:call-template name="empty-cell"/>

										<fo:table-cell border-style="solid" border-width="0.1pt" padding-end="0.5em">		 Total Assets
											<fo:block text-align="right">
												<xsl:call-template name="kingaku">
													<xsl:with-param name="kingaku" select="//xbrl:item[contains(@type,':balanceSheet.assets')]" />
												</xsl:call-template>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>

									<xsl:for-each select="//xbrl:label[@lang=$langset]">
										<xsl:if test="position() &gt; $ptAS and position() &lt; $ptAS2">


											<xsl:choose>
												 Current Liabilities, Noncurrent Liabilities
												<xsl:when test='contains("assets.currentAssets,assets.fixedAssets,assets.deferredAssets",substring-before(substring-after(@href,":"),"&apos;"))'>
													<fo:table-row xsl:use-attribute-sets="row-height" font-weight="bold">

														<fo:table-cell padding-start="0.5em">
															<fo:block>
																<xsl:value-of select="." />
															</fo:block>
														</fo:table-cell>

														<xsl:call-template name="empty-cell"/>


														<fo:table-cell padding-end="0.5em">
															<fo:block text-align="right">
																<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
																<xsl:call-template name="kingaku">
																	<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
																</xsl:call-template>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</xsl:when>

												 Property, Plant and Equipment, Net, Long Term Investments
												<xsl:when test='contains("fixedAssets.propertyPlantAndEquipmentNet,fixedAssets.intangibleAssetsNet,fixedAssets.longTermInvestments",substring-before(substring-after(@href,":"),"&apos;"))'>
													<fo:table-row xsl:use-attribute-sets="row-height" font-weight="bold">

														<fo:table-cell padding-start="0.5em">
															<fo:block text-indent="0.5em">
																<xsl:value-of select="." />
															</fo:block>
														</fo:table-cell>

														<xsl:call-template name="empty-cell"/>

														<fo:table-cell padding-end="0.5em">
															<fo:block text-align="right">
																<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
																<xsl:call-template name="kingaku">
																	<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
																</xsl:call-template>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</xsl:when>

												 otherwise
												<xsl:otherwise>
													<fo:table-row xsl:use-attribute-sets="row-height">

														<fo:table-cell>
															<fo:block text-indent="1.5em">
																<xsl:value-of select="." />
															</fo:block>
														</fo:table-cell>

														<xsl:call-template name="empty-cell"/>

														<fo:table-cell padding-end="0.5em">
															<fo:block text-align="right">
																<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
																<xsl:call-template name="kingaku">
																	<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
																</xsl:call-template>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
									</xsl:for-each>


									 When debt items has more lows than credit items, creates empty record in credit area.
									<xsl:if test="$ptEQ2 - $ptLB > $ptAS2 - $ptAS">
										<xsl:for-each select="//xbrl:label[@lang=$langset]">
											<xsl:if test="($ptEQ2 - $ptLB)-($ptAS2 - $ptAS) >= position()">
												<fo:table-row xsl:use-attribute-sets="row-height">

													<fo:table-cell>
														<fo:block>?</fo:block>
													</fo:table-cell>

													<xsl:call-template name="empty-cell"/>

													<fo:table-cell>
														<fo:block>?</fo:block>
													</fo:table-cell>

												</fo:table-row>
											</xsl:if>
										</xsl:for-each>
									</xsl:if>

									<xsl:call-template name="ajustLine">
										<xsl:with-param name="ajustCnt" select="number($ajustL1)" />
									</xsl:call-template>

								</fo:table-body>
							</fo:table>
						</fo:table-and-caption>
					</fo:table-cell>


					<fo:table-cell border-style="solid" border-width="0.1pt">
						<fo:table-and-caption>
							 <fo:table-caption />
							<fo:table xsl:use-attribute-sets="table.data">

								<fo:table-column column-number="1" column-width="60mm"/>
								<fo:table-column column-number="2" column-width="0.1pt"/>
								<fo:table-column column-number="3" column-width="25mm"/>

								<fo:table-body border-style="solid" border-width="0.1pt">

									<fo:table-row xsl:use-attribute-sets="row-height">

										<fo:table-cell border-style="solid" border-width="0.1pt">
											<fo:block text-align="center">
												<xsl:if test="$langset='ja'">??????</xsl:if>
												<xsl:if test="$langset!='ja'">Account</xsl:if>
											</fo:block>
										</fo:table-cell>

										<xsl:call-template name="empty-cell"/>

										<fo:table-cell border-style="solid" border-width="0.1pt">
											<fo:block text-align="center">
												<xsl:if test="$langset='ja'">????</xsl:if>
												<xsl:if test="$langset!='ja'">Amount</xsl:if>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>

									<fo:table-row xsl:use-attribute-sets="row-height">
										<fo:table-cell border-style="solid" border-width="0.1pt">		(Liabilities)
											<fo:block text-align="center">
												<xsl:value-of select="//xbrl:label[@lang=$langset and contains(@href,':balanceSheet.liabilities')]" />
											</fo:block>
										</fo:table-cell>

										<xsl:call-template name="empty-cell"/>

										<fo:table-cell border-style="solid" border-width="0.1pt" padding-end="0.5em">
											<fo:block text-align="right">
												<xsl:call-template name="kingaku">
													<xsl:with-param name="kingaku" select="//xbrl:item[contains(@type,':balanceSheet.liabilities')]" />
												</xsl:call-template>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>

									<xsl:for-each select="//xbrl:label[@lang=$langset]">
										<xsl:if test="position() &gt; $ptLB and position() &lt; $ptEQ">
											<xsl:choose>
												Current Liabilities, Noncurrent Liabilities
												<xsl:when test='contains("liabilities.currentLiabilities,liabilities.noncurrentLiabilities",substring-before(substring-after(@href,":"),"&apos;"))'>
													<fo:table-row xsl:use-attribute-sets="row-height" font-weight="bold">
														<fo:table-cell padding-start="0.5em">
															<fo:block>
																<xsl:value-of select="." />
															</fo:block>
														</fo:table-cell>

														<xsl:call-template name="empty-cell"/>

														<fo:table-cell padding-end="0.5em">
															<fo:block text-align="right">
																<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
																<xsl:call-template name="kingaku">
																	<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
																</xsl:call-template>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</xsl:when>

												 otherwise
												<xsl:otherwise>
													<fo:table-row xsl:use-attribute-sets="row-height">
														<fo:table-cell>
															<fo:block text-indent="1.5em">
																<xsl:value-of select="." />
															</fo:block>
														</fo:table-cell>

														<xsl:call-template name="empty-cell"/>

														<fo:table-cell padding-end="0.5em">
															<fo:block text-align="right">
																<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
																<xsl:call-template name="kingaku">
																	<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
																</xsl:call-template>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
									</xsl:for-each>

									 When credit items are more than debt items, outputs empty record to the debt table.
									<xsl:if test="$ptAS2 - $ptAS > $ptEQ2 - $ptLB">
										<xsl:for-each select="//xbrl:label[@lang=$langset]">
											<xsl:if test="($ptAS2 - $ptAS) - ($ptEQ2 - $ptLB) >= position()">
												<fo:table-row xsl:use-attribute-sets="row-height">
													<fo:table-cell>
														<fo:block>?</fo:block>
													</fo:table-cell>

													<xsl:call-template name="empty-cell"/>

													<fo:table-cell>
														<fo:block>?</fo:block>
													</fo:table-cell>

												</fo:table-row>
											</xsl:if>
										</xsl:for-each>
									</xsl:if>

									<xsl:call-template name="ajustLine">
										<xsl:with-param name="ajustCnt" select="number($ajustR1)" />
									</xsl:call-template>

									<fo:table-row xsl:use-attribute-sets="row-height">
										<fo:table-cell border-style="solid" border-width="0.1pt">		(Stockholders' Equity)
											<fo:block text-align="center">
												<xsl:value-of select="//xbrl:label[@lang=$langset and contains(@href,':balanceSheet.stockholdersEquity')]"/>
											</fo:block>
										</fo:table-cell>

										<xsl:call-template name="empty-cell"/>

										<fo:table-cell border-style="solid" border-width="0.1pt" padding-end="0.5em">
											<fo:block text-align="right">
												<xsl:call-template name="kingaku">
													<xsl:with-param name="kingaku" select="//xbrl:item[contains(@type,':balanceSheet.stockholdersEquity')]"/>
												</xsl:call-template>
											</fo:block>
										</fo:table-cell>
									</fo:table-row>

									<xsl:for-each select="//xbrl:label[@lang=$langset]">
										<xsl:if test="position() &gt; $ptEQ and position() &lt; $ptEQ2">
											<xsl:choose>

												Capital Stock, Statutory Reserve, Earned Surplus
												<xsl:when test='contains("stockholdersEquity.capitalStock,stockholdersEquity.statutoryReserve,stockholdersEquity.earnedSurplus",substring-before(substring-after(@href,":"),"&apos;"))'>
													<fo:table-row xsl:use-attribute-sets="row-height" font-weight="bold">
														<fo:table-cell padding-start="0.5em">
															<fo:block>
																<xsl:value-of select="." />
															</fo:block>
														</fo:table-cell>

														<xsl:call-template name="empty-cell"/>

														<fo:table-cell padding-end="0.5em">
															<fo:block text-align="right">
																<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
																<xsl:call-template name="kingaku">
																	<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
																</xsl:call-template>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</xsl:when>

												 otherwise
												<xsl:otherwise>
													<fo:table-row xsl:use-attribute-sets="row-height">
														<fo:table-cell>
															<fo:block text-indent="1.5em">
																<xsl:value-of select="." />
															</fo:block>
														</fo:table-cell>

														<xsl:call-template name="empty-cell"/>

														<fo:table-cell padding-end="0.5em">
															<fo:block text-align="right">
																<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
																<xsl:call-template name="kingaku">
																	<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
																</xsl:call-template>
															</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
									</xsl:for-each>

									<xsl:call-template name="ajustLine">
										<xsl:with-param name="ajustCnt" select="number($ajustR2)" />
									</xsl:call-template>

								</fo:table-body>
							</fo:table>
						</fo:table-and-caption>
					</fo:table-cell>
				</fo:table-row>


				<fo:table-row xsl:use-attribute-sets="row-height" font-weight="bold">

					<fo:table-cell number-columns-spanned="2">
						<fo:table-and-caption>
							<fo:table xsl:use-attribute-sets="table.data">

								<fo:table-column column-number="1" column-width="60mm"/>
								<fo:table-column column-number="2" column-width="0.1pt"/>
								<fo:table-column column-number="3" column-width="25mm"/>
								<fo:table-column column-number="4" column-width="60mm"/>
								<fo:table-column column-number="5" column-width="0.1pt"/>
								<fo:table-column column-number="6" column-width="25mm"/>

								<fo:table-body border-style="solid" border-width="0.1pt">
									<fo:table-row>
										<fo:table-cell border-style="solid" border-width="0.1pt">		 Total Assets
											<fo:block text-align="center">
												<xsl:value-of select="//xbrl:label[@lang=$langset and contains(@href,':balanceSheet.totalAssets')]"/>
											</fo:block>
										</fo:table-cell>
										<xsl:call-template name="empty-cell"/>
										<fo:table-cell border-style="solid" border-width="0.1pt" padding-end="0.5em">
											<fo:block text-align="right">
												<xsl:call-template name="kingaku">
													<xsl:with-param name="kingaku" select="//xbrl:item[contains(@type,':balanceSheet.totalAssets')]"/>
												</xsl:call-template>
											</fo:block>
										</fo:table-cell>
										<fo:table-cell border-style="solid" border-width="0.1pt">		 Total Liabilities and Stockholders' Equity
											<fo:block text-align="center">
												<xsl:value-of select="//xbrl:label[@lang=$langset and contains(@href,':balanceSheet.totalLiabilitiesAndStockholdersEquity')]"/>
											</fo:block>
										</fo:table-cell>

										<xsl:call-template name="empty-cell"/>

										<fo:table-cell border-style="solid" border-width="0.1pt" padding-end="0.5em">
											<fo:block text-align="right">
												<xsl:call-template name="kingaku">
													<xsl:with-param name="kingaku" select="//xbrl:item[contains(@type,':balanceSheet.totalLiabilitiesAndStockholdersEquity')]"/>
												</xsl:call-template>
											</fo:block>
										</fo:table-cell>

									</fo:table-row>
								</fo:table-body>
							</fo:table>

						</fo:table-and-caption>

					</fo:table-cell>
				</fo:table-row>


			</fo:table-body>
		</fo:table>
	</fo:table-and-caption>

</xsl:template>

 Edit Income Statement
<xsl:template name="pl">

  <fo:block text-align="center">


	<fo:table-and-caption>
		<fo:table xsl:use-attribute-sets="table.data">
			<fo:table-column column-number="1" column-width="20mm"/>
			<fo:table-column column-number="3" column-width="20mm"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell />
						<fo:table-cell>
							<fo:table-and-caption>
								<fo:table-caption xsl:use-attribute-sets="table.data.caption" font-size="13pt">
									<fo:block>		Income Statement
										<xsl:value-of select="//xbrl:label[@lang=$langset and contains(@href,':statements.incomeStatement')]" />
									</fo:block>

									<xsl:if test="$langset='ja'">
										<fo:block>		Date
											<xsl:text disable-output-escaping="yes">(? </xsl:text>
											<xsl:call-template name="date-edit">
												<xsl:with-param name="seireki" select="//xbrl:item[contains(@type,':accountingPeriod.beginningOfPeriod')]" />
											</xsl:call-template>
											<xsl:text disable-output-escaping="yes"> ?</xsl:text>
											<xsl:call-template name="date-edit">
												<xsl:with-param name="seireki" select="//xbrl:item[contains(@type,':accountingPeriod.endOfPeriod')]" />
											</xsl:call-template>
											)
										</fo:block>
									</xsl:if>

									<xsl:if test="$langset!='en'">
										<fo:block>
											<xsl:text disable-output-escaping="yes">For the year of </xsl:text>
											<xsl:value-of select="substring-before(//xbrl:item[contains(@type,':accountingPeriod.endOfPeriod')],'-')" />
											<xsl:text disable-output-escaping="yes"> , ended ;</xsl:text>
											<xsl:call-template name="date-edit">
												<xsl:with-param name="seireki" select="//xbrl:item[contains(@type,':accountingPeriod.endOfPeriod')]" />
											</xsl:call-template>
										</fo:block>
									</xsl:if>

									<fo:block text-align="right" font-size="10pt" font-weight="normal" end-indent="5mm">		 Unit
										<xsl:if test="$langset='ja'">(???</xsl:if>
										<xsl:if test="$langset!='ja'">(Unit?</xsl:if>
										<xsl:value-of select="$tani" />
										)
									</fo:block>
								</fo:table-caption>

								<xsl:variable name="ptPL">
									<xsl:for-each select="//xbrl:label[@lang=$langset]">
										<xsl:if test="contains(@href,'statements.incomeStatement')">
											<xsl:value-of select="position()" />
										</xsl:if>
									</xsl:for-each>
								</xsl:variable>

								<xsl:variable name="ptPL2">
									<xsl:for-each select="//xbrl:label[@lang=$langset]">
										<xsl:if test="contains(@href,'incomeStatement.unappropriatedRetainedEarningsEndOfYear')">
											<xsl:value-of select="position()" />
										</xsl:if>
									</xsl:for-each>

								</xsl:variable>

								<fo:table>
									<fo:table-column column-number="1" column-width="95mm"/>
									<fo:table-column column-number="2" column-width="0.1pt"/>
									<fo:table-column column-number="3" column-width="25mm"/>
									<fo:table-body border-style="solid" border-width="0.1pt">
										<fo:table-row>
											<fo:table-cell border-style="solid" border-width="0.1pt">
												<fo:block text-align="center">
													<xsl:if test="$langset='ja'">??????</xsl:if>
													<xsl:if test="$langset!='ja'">Account</xsl:if>
												</fo:block>
											</fo:table-cell>

											<xsl:call-template name="empty-cell"/>

											<fo:table-cell border-style="solid" border-width="0.1pt">
												<fo:block text-align="center">
													<xsl:if test="$langset='ja'">????</xsl:if>
													<xsl:if test="$langset!='ja'">Amount</xsl:if>
												</fo:block>
											</fo:table-cell>
										</fo:table-row>

										<xsl:for-each select="//xbrl:label[@lang=$langset]">
											<xsl:if test="position() &gt; $ptPL and position() &lt;= $ptPL2">
												<xsl:choose>
													<xsl:when test='contains("incomeStatement.operatingRevenue,incomeStatement.operatingProfit,incomeStatement.ordinaryProfit,incomeStatement.incomeBeforeIncomeTaxes,incomeStatement.netIncome,incomeStatement.unappropriatedRetainedEarningsEndOfYear",substring-before(substring-after(@href,":"),"&apos;"))'>
														<fo:table-row xsl:use-attribute-sets="row-height" font-weight="bold">
															<fo:table-cell padding-start="0.5em">
																<fo:block text-align="left">
																	<xsl:value-of select="." />
																</fo:block>
															</fo:table-cell>

															<xsl:call-template name="empty-cell"/>

															<fo:table-cell padding-end="0.5em">
																<fo:block text-align="right">
																	<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
																	<xsl:call-template name="kingaku">
																		<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
																	</xsl:call-template>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>
													</xsl:when>


													<xsl:otherwise>
														<fo:table-row xsl:use-attribute-sets="row-height">
															<fo:table-cell>
																<fo:block  text-align="left" text-indent="1.5em">
																	<xsl:value-of select="." />
																</fo:block>
															</fo:table-cell>

															<xsl:call-template name="empty-cell"/>

															<fo:table-cell padding-end="0.5em">
																<fo:block text-align="right">
																	<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
																	<xsl:call-template name="kingaku">
																		<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
																	</xsl:call-template>
																</fo:block>
															</fo:table-cell>
														</fo:table-row>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:if>
										</xsl:for-each>

									</fo:table-body>

								</fo:table>

							</fo:table-and-caption>
						</fo:table-cell>
						<fo:table-cell />
					</fo:table-row>
				</fo:table-body>
		</fo:table>
	</fo:table-and-caption>
  </fo:block>

</xsl:template>


 Edit notes
<xsl:template name="notes">

	<fo:table-and-caption>
		<fo:table>
			<fo:table-column column-number="1" column-width="10mm"/>
			<fo:table-column column-number="2" column-width="10mm"/>
			<fo:table-body>
				<xsl:for-each select="//xbrl:label[@lang=$langset and contains(@href,'notesToFinancialStatements.')]">
					<fo:table-row>
						<fo:table-cell>
							<fo:block>
								<xsl:if test="position()=1">
									<xsl:if test="$langset='ja'">(?)</xsl:if>
									<xsl:if test="$langset !='ja'">Notes:</xsl:if>
								</xsl:if>
								<xsl:if test="position()!=1" />
							</fo:block>
						</fo:table-cell>

						<fo:table-cell>
							<fo:block>
								<xsl:value-of select="position()" />
								.
							</fo:block>
						</fo:table-cell>

						<fo:table-cell>
							<fo:block>
								<xsl:value-of select="." />
								<xsl:variable name="ptLabel" select='substring-before(substring-after(@href,"&apos;"),"&apos;")' />
								<xsl:text disable-output-escaping="yes">??</xsl:text>
								<xsl:choose>
									<xsl:when test="contains($ptLabel,'.netIncomePerShare')">
										<xsl:if test="$langset='ja'">
											<xsl:choose>
												<xsl:when test="contains(//xbrl:item[@type=$ptLabel],'.')">
													<xsl:value-of select="substring-before(//xbrl:item[@type=$ptLabel],'.')" />
													?
													<xsl:value-of select="substring-after(//xbrl:item[@type=$ptLabel],'.')" />
													?
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="//xbrl:item[@type=$ptLabel]" />
													?
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
										<xsl:if test="$langset!='ja'">
											<xsl:value-of select="//xbrl:item[@type=$ptLabel]" />
											Yen
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="kingaku">
											<xsl:with-param name="kingaku" select="//xbrl:item[@type=$ptLabel]" />
										</xsl:call-template>
										<xsl:value-of select="$tani" />
									</xsl:otherwise>
								</xsl:choose>
							</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</fo:table-and-caption>
</xsl:template>



Edit Date
<xsl:template name="date-edit">
	<xsl:param name="seireki" />
	<xsl:variable name="seireki2" select="number(translate($seireki,'-',''))" />
	<xsl:choose>
		<xsl:when test="$langset !='ja'">
			<xsl:variable name="yyyy" select="substring-before($seireki,'-')" />
			<xsl:variable name="mm" select="substring-before(substring-after($seireki,'-'),'-')" />
			<xsl:variable name="dd" select="substring-after(substring-after($seireki,'-'),'-')" />
			<xsl:choose>
				<xsl:when test="$mm='01'">January</xsl:when>
				<xsl:when test="$mm='02'">February</xsl:when>
				<xsl:when test="$mm='03'">March</xsl:when>
				<xsl:when test="$mm='04'">April</xsl:when>
				<xsl:when test="$mm='05'">May</xsl:when>
				<xsl:when test="$mm='06'">June</xsl:when>
				<xsl:when test="$mm='07'">July</xsl:when>
				<xsl:when test="$mm='08'">August</xsl:when>
				<xsl:when test="$mm='09'">September</xsl:when>
				<xsl:when test="$mm='10'">October</xsl:when>
				<xsl:when test="$mm='11'">November</xsl:when>
				<xsl:when test="$mm='12'">December</xsl:when>
			</xsl:choose>
			<xsl:text disable-output-escaping="yes"> </xsl:text>
			<xsl:value-of select="format-number($dd,'##')" /> ,
			<xsl:text disable-output-escaping="yes"> </xsl:text>
			<xsl:value-of select="$yyyy" />
		</xsl:when>
		<xsl:when test="$seireki2 >=19890108">
			<xsl:text>??</xsl:text>
			<xsl:value-of select="string(number(substring($seireki,1,4))-1988)" />
		</xsl:when>
		<xsl:when test="$seireki2 >=19261225">
			<xsl:text>??</xsl:text>
			<xsl:value-of select="string(number(substring($seireki,1,4))-1925)" />
		</xsl:when>
		<xsl:when test="$seireki2 >=19120730">
			<xsl:text>??</xsl:text>
			<xsl:value-of select="string(number(substring($seireki,1,4))-1911)" />
		</xsl:when>
		<xsl:when test="$seireki2 >=18680908">
			<xsl:text>??</xsl:text>
			<xsl:value-of select="string(number(substring($seireki,1,4))-1867)" />
		</xsl:when>
		<xsl:otherwise>
			??
			<xsl:value-of select="string(number(substring($seireki,1,4)))" />
		</xsl:otherwise>
	</xsl:choose>
	<xsl:if test="$langset='ja'">
		?
		<xsl:value-of select="string(number(substring($seireki,6,2)))" />
		?
		<xsl:value-of select="string(number(substring($seireki,9,2)))" />
		?
	</xsl:if>
</xsl:template>

Edit Comma
<xsl:template name="kingaku">
	<xsl:param name="kingaku" />
	<xsl:choose>
		<xsl:when test="$kingaku &lt; 0 and $langset='jp'">
			?
			<xsl:value-of select="format-number($kingaku * -1,'###,###')" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="format-number($kingaku,'###,###')" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="empty-cell">
	<fo:table-cell border-style="solid" border-width="0.1pt">
	</fo:table-cell>
</xsl:template>


<xsl:template name="ajustLine">
	<xsl:param name="ajustCnt" />

	<xsl:if test="$ajustCnt &gt; 0">
		<fo:table-row xsl:use-attribute-sets="row-height">

			<fo:table-cell>
				<fo:block> </fo:block>
			</fo:table-cell>

			<xsl:call-template name="empty-cell"/>

			<fo:table-cell>
				<fo:block> </fo:block>
			</fo:table-cell>

		</fo:table-row>

		<xsl:call-template name="ajustLine">
			<xsl:with-param name="ajustCnt" select="$ajustCnt - 1" />
		</xsl:call-template>

	</xsl:if>

</xsl:template>


</xsl:stylesheet>-->
