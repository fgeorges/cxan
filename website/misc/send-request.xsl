<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:http="http://expath.org/ns/http-client"
                exclude-result-prefixes="#all"
                version="2.0">

   <xsl:import href="http://expath.org/ns/http-client.xsl"/>

   <xsl:output indent="yes"/>

   <xsl:param name="pkg"    as="xs:string?"/>
   <xsl:param name="server" as="xs:string" select="'local'"/>

   <xsl:variable name="server-local" select="'http://localhost:8090/servlex/cxan'"/>
   <xsl:variable name="server-beta"  select="'http://cxan.org'"/>

   <xsl:variable name="server-prefix" select="
       if ( $server eq 'local' ) then
         $server-local
       else if ( $server eq 'beta' ) then
         $server-beta
       else
         error((), concat('Unsupported server: ', $server, '.'))"/>

   <xsl:template match="/packages">
      <updates>
         <xsl:choose>
            <xsl:when test="exists($pkg)">
               <xsl:variable name="p" as="element(pkg)" select="pkg[@id eq $pkg]"/>
               <xsl:apply-templates select="$p"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates select="pkg"/>
            </xsl:otherwise>
         </xsl:choose>
      </updates>
   </xsl:template>

   <xsl:template match="pkg">
      <xsl:message select="'Update:', string(@id), '...'"/>
      <xsl:variable name="req" as="element()">
         <http:request href="{ $server-prefix }/{ relative-href }" method="put">
            <http:header name="Content-Disposition"
                         value='attachment; filename="{ filename }"'/>
            <http:body media-type="application/octet" src="{ xar }"/>
         </http:request>
      </xsl:variable>
      <update>
         <xsl:sequence select="http:send-request($req)"/>
      </update>
   </xsl:template>

</xsl:stylesheet>
