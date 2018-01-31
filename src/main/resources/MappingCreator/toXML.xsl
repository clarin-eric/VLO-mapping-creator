<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" xmlns:csv="https://vlo.clarin.eu/ns/csv" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs csv">

    <xsl:output method="xml" encoding="UTF-8"/>
    
    <xsl:import href="csv.xsl"/>

    <xsl:param name="csv"/>
    
    <xsl:param name="defaults" select="()"/>
    
    <xsl:variable name="RE" select="'~'"/>
    <xsl:variable name="NOT" select="'!'"/>
    
    <xsl:template match="text()"/>

    <xsl:template name="main">
        <xsl:variable name="rows">
            <xsl:choose>
                <xsl:when test="unparsed-text-available($csv)">
                    <xsl:variable name="tab" select="unparsed-text($csv)"/>
                    <xsl:variable name="lines" select="tokenize($tab, '(\r)?\n')" as="xs:string+"/>
                    <xsl:variable name="elemNames" select="csv:getTokens($lines[1])" as="xs:string+"/>
                    <xsl:message >DBG: CSV headers[<xsl:value-of select="string-join($elemNames,',')"/>]</xsl:message>
                    <xsl:for-each select="$lines[position() &gt; 1][normalize-space(.) != '']">
                        <xsl:variable name="line" select="position()"/>
                        <r l="{$line}">
                            <xsl:variable name="lineItems" select="csv:getTokens(.)" as="xs:string+"/>
                            <xsl:if test="count($lineItems)!=count($elemNames)">
                                <xsl:message terminate="yes">ERR: CSV[<xsl:value-of select="$csv"/>] line[<xsl:value-of select="$line"/>] has [<xsl:value-of select="count($lineItems)"/>] cells, but the header indicates that [<xsl:value-of select="count($elemNames)"/>] cells are expected!</xsl:message>
                            </xsl:if>
                            <xsl:for-each select="$elemNames">
                                <xsl:variable name="col" select="position()"/>
                                <c n="{.}">
                                    <xsl:value-of select="$lineItems[$col]"/>
                                </c>
                            </xsl:for-each>
                        </r>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">ERR: couldn't load CSV[<xsl:value-of select="$csv"/>]!</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="count($rows/r) = 0">
            <xsl:message terminate="yes">ERR: no data loaded from CSV[<xsl:value-of select="$csv"/>]!</xsl:message>
        </xsl:if>
        <xsl:message>DBG: loaded CSV[<xsl:value-of select="$csv"/>]</xsl:message>
        <value-mappings>
            <origin-facet name="{($rows/r)[1]/(c)[1]/@n}">
                <value-map>
                    <xsl:for-each select="($rows/r)[1]/c">
                        <xsl:if test="position() gt 1">
                            <!-- lookup default target-facet for current()/@n -->
                            <xsl:if test="exists($defaults)">
                                <xsl:copy-of select="$defaults//target-facet[@name=current()/@n]"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:for-each-group select="$rows/r" group-by="(c)[1]">
                        <xsl:if test="exists(current-group()[count(c[normalize-space(.)!='']) gt 1])">
                            <target-value-set>
                                <xsl:for-each select="current-group()">
                                    <xsl:for-each select="c">
                                        <xsl:if test="position() gt 1">
                                            <xsl:variable name="n" select="@n"/>
                                            <xsl:choose>
                                                <xsl:when test="normalize-space(.)=$NOT">
                                                    <target-value facet="{$n}" removeSourceValue="true"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:for-each select="tokenize(.,';')">
                                                        <target-value facet="{$n}">
                                                            <xsl:value-of select="."/>
                                                        </target-value>
                                                    </xsl:for-each>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:for-each>
                                <source-value>
                                    <xsl:choose>
                                        <xsl:when test="matches(current-grouping-key(),concat('^',$RE,'.*$'))">
                                            <xsl:attribute name="isRegex" select="'true'"/>
                                            <xsl:value-of select="replace(current-grouping-key(),concat('^',$RE),'')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="current-grouping-key()"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </source-value>
                            </target-value-set>
                        </xsl:if>
                    </xsl:for-each-group>
                </value-map>
            </origin-facet>
        </value-mappings>
    </xsl:template>
    
    <!--<value-map>
        <target-facet name="subject" removeSourceValue="true" overrideExistingValues="false"/>
        <target-value-set>
            <target-value facet="subject" overrideExistingValues="true">blabla</target-value>
            <target-value facet="name">cfmvalue</target-value>
            <target-value facet="temporalCoverage">cfmvalue</target-value>
            <source-value isRegex="false">CollectionName</source-value>
        </target-value-set>
    </value-map>-->

</xsl:stylesheet>
