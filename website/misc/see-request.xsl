<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:http="http://expath.org/ns/http-client"
                exclude-result-prefixes="#all"
                version="2.0">

   <!--
       Little dev tool to send a request to a specific endpoint on the CXAN
       website (either on localhost or cxan.org).
   -->

   <xsl:import href="http://expath.org/ns/http-client.xsl"/>

   <xsl:output indent="yes"/>

   <xsl:param name="pkg"    as="xs:string?"/>
   <xsl:param name="server" as="xs:string" select="'local'"/>

   <xsl:variable name="server-local"  select="'http://localhost:8090/servlex/cxan'"/>
   <xsl:variable name="server-tomcat" select="'http://cxan.org:8066/servlex/cxan'"/>
   <xsl:variable name="server-cxan"   select="'http://cxan.org'"/>

   <xsl:variable name="server-prefix" select="
       if ( $server eq 'local' ) then
         $server-local
       else if ( $server eq 'tomcat' ) then
         $server-tomcat
       else if ( $server eq 'cxan' ) then
         $server-cxan
       else
         error((), concat('Unsupported server: ', $server, '.'))"/>

   <xsl:template name="main">
      <xsl:variable name="req" as="element()">
         <http:request href="{ $server-prefix }/pkg?name=http%3A%2F%2Fwww.functx.com" method="get">
            <http:header name="Accept" value="application/xml"/>
         </http:request>
      </xsl:variable>
      <xsl:sequence select="$req, http:send-request($req)"/>
   </xsl:template>

</xsl:stylesheet>
