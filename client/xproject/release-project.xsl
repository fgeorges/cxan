<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:proj="http://expath.org/ns/project"
                xmlns:zip="http://expath.org/ns/zip"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="http://expath.org/ns/project/release.xsl"/>

   <!-- The overload point. -->
   <xsl:template match="zip:file" mode="proj:modify-release">
      <xsl:apply-templates select="." mode="version"/>
   </xsl:template>

   <!-- Copy everything... -->
   <xsl:template match="node()" mode="version">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="node()" mode="version"/>
      </xsl:copy>
   </xsl:template>

   <!-- ...and add the bin dir right before the src dir, with the cxan script modified by
        resolving the $version and $revision global variables. -->
   <xsl:template match="zip:file/zip:dir/zip:dir[@name eq 'src']" mode="version">
      <xsl:message>
         <xsl:text>Using version = </xsl:text>
         <xsl:value-of select="$proj:version"/>
         <xsl:text> and revision = </xsl:text>
         <xsl:value-of select="$proj:revision"/>
      </xsl:message>
      <zip:dir name="bin">
         <zip:entry name="cxan" method="text">
            <xsl:value-of select="
                replace(
                  replace(
                    unparsed-text(resolve-uri('bin/cxan', $proj:project)),
                    '@@REVISION@@',
                    $proj:revision),
                  '@@VERSION@@',
                  $proj:version)"/>
         </zip:entry>
      </zip:dir>
      <xsl:copy-of select="."/>
   </xsl:template>

</xsl:stylesheet>
