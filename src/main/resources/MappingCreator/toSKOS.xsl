<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="base" select="'http://my.example.com'"/>
    
    <xsl:template match="text()"/>
    
    <xsl:template match="origin-facet">
        <xsl:variable name="cs" select="concat($base,'/cs/',@name)"/>
        <rdf:RDF>
            <rdf:Description rdf:about="{$cs}">
                <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#ConceptScheme"/>
                <dcterms:title xml:lang="en">
                    <xsl:value-of select="@name"/>
                </dcterms:title>
                <dcterms:description xml:lang="en">...</dcterms:description>
            </rdf:Description>
            <xsl:for-each select="distinct-values(value-map/target-value-set/target-value/normalize-space())">
                <xsl:variable name="tv" select="."/>
                <rdf:Description rdf:about="{$base}/c/{replace($tv,'[^A-Za-z0-9]','_')}">
                    <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
                    <skos:inScheme rdf:resource="{$cs}"/>
                    <skos:prefLabel xml:lang="en">
                        <xsl:value-of select="$tv"/>
                    </skos:prefLabel>
                </rdf:Description>
            </xsl:for-each>
        </rdf:RDF>
    </xsl:template>
    
</xsl:stylesheet>