<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:csv="https://vlo.clarin.eu/ns/csv" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">

    <xsl:output method="text" encoding="UTF-8"/>
    
    <xsl:import href="csv.xsl"/>

    <xsl:param name="csv"/>
    
    <xsl:variable name="SKIP" select="'TF-'"/>

    <xsl:template match="/rdf:RDF">
        <xsl:variable name="new">
            <xsl:choose>
                <xsl:when test="unparsed-text-available($csv)">
                    <xsl:variable name="tab" select="unparsed-text($csv)"/>
                    <xsl:variable name="lines" select="tokenize($tab, '(\r)?\n')" as="xs:string+"/>
                    <xsl:variable name="elemNames" select="csv:getTokens($lines[1])" as="xs:string+"/>
                    <xsl:message >DBG: CSV headers[<xsl:value-of select="string-join($elemNames,',')"/>]</xsl:message>
                    <xsl:for-each select="$lines[position() &gt; 1][normalize-space(.) != '']">
                        <l>
                            <xsl:variable name="lineItems" select="csv:getTokens(.)" as="xs:string+"/>
                            <xsl:for-each select="$elemNames">
                                <xsl:variable name="pos" select="position()"/>
                                <xsl:if test="not(matches(.,concat('^',$SKIP,'.*$'),'i'))">
                                    <f n="{.}">
                                        <xsl:value-of select="$lineItems[$pos]"/>
                                    </f>
                                </xsl:if>
                            </xsl:for-each>
                        </l>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">ERR: couldn't load CSV[<xsl:value-of select="$csv"/>]!</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message>DBG: loaded CSV[<xsl:value-of select="$csv"/>]</xsl:message>
        <xsl:variable name="facet" select="rdf:Description[rdf:type/@rdf:resource = 'http://www.w3.org/2004/02/skos/core#ConceptScheme']/dcterms:title"/>
        <xsl:message>DBG: facet SKOS[<xsl:value-of select="$facet"/>]</xsl:message>
        <xsl:variable name="old">
            <xsl:for-each select="//(skos:altLabel|skos:hiddenLabel)">
                <xsl:variable name="alt" select="."/>
                <xsl:choose>
                    <xsl:when test="empty($new/l/(f)[1][.=$alt])">
                        <l>
                            <f n="{$facet}">
                                <xsl:value-of select="$alt"/>
                            </f>
                            <f n="{$facet}">
                                <xsl:value-of select="$alt/../skos:prefLabel"/>
                            </f>
                        </l>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>DBG: altLabel[<xsl:value-of select="$alt"/>] is already in the CSV!</xsl:message>
                        <xsl:message>DBG: <xsl:apply-templates select="$new/l/f[1][.=$alt]/.."/></xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <!-- header -->
        <xsl:for-each select="($new/l)[1]/f">
            <xsl:text>"</xsl:text>
            <xsl:value-of select="replace(@n,'&quot;','&quot;&quot;')"/>
            <xsl:text>"</xsl:text>
            <xsl:choose>
                <xsl:when test="position() = last()">
                    <xsl:value-of select="$NL"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>,</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:apply-templates select="$new"/>
        <xsl:apply-templates select="$old"/>
    </xsl:template>

    <xsl:template match="l">
        <xsl:apply-templates/>
        <xsl:value-of select="$NL"/>
    </xsl:template>

    <xsl:template match="f">
        <xsl:if test="preceding-sibling::f">
            <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="replace(.,'&quot;','&quot;&quot;')"/>
        <xsl:text>"</xsl:text>
    </xsl:template>

</xsl:stylesheet>
