<p:library  xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:client="http://cxan.org/ns/client"
            xmlns:pkg="http://expath.org/ns/pkg"
            pkg:import-uri="#none"
            version="1.0">

   <!--
       XML output:
       <packages name="http://expath.org/lib/http-client">
          <pkg>http-client-exist</pkg>
          <pkg>http-client-saxon</pkg>
       </packages>
       
       Text output:
       http-client-exist
       http-client-saxon
   -->

   <p:import href="../tools.xpl"/>

   <p:declare-step type="client:resolve-stdout-packages">
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:xslt>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:template match="/packages">
                     <stdout>
                        <xsl:apply-templates select="*"/>
                     </stdout>
                  </xsl:template>
                  <xsl:template match="pkg">
                     <line>
                        <xsl:value-of select="."/>
                     </line>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <p:declare-step type="client:resolve" name="pipeline">
      <!-- The input params.  Can only have a param 'name' (required) which is a
           package name URI. -->
      <p:input  port="parameters" kind="parameter" primary="true"/>
      <p:output port="result" primary="true"/>
      <!-- Must be either 'text' or 'xml'. -->
      <p:option name="output" required="true"/>
      <p:wrap-sequence wrapper="wrapper">
         <p:input port="source">
            <p:pipe step="pipeline" port="parameters"/>
         </p:input>
      </p:wrap-sequence>
      <p:group>
         <p:variable name="name" select="/wrapper/c:param-set/c:param[@name eq 'name']/@value"/>
         <client:http-get>
            <p:with-option name="href" select="concat('/pkg?name=', encode-for-uri($name))"/>
         </client:http-get>
         <p:choose>
            <p:when test="$output eq 'xml'">
               <p:identity/>
            </p:when>
            <p:otherwise>
               <client:resolve-stdout-packages/>
            </p:otherwise>
         </p:choose>
      </p:group>
   </p:declare-step>

</p:library>
