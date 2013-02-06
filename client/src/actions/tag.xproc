<p:library  xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:client="http://cxan.org/ns/client"
            xmlns:pkg="http://expath.org/ns/pkg"
            pkg:import-uri="#none"
            version="1.0">

   <!--
       XML output (when no tag):
       <tags>
          <tag>application</tag>
          <tag>cxan</tag>
          <tag>exist</tag>
          ...
       </tags>
       
       Text output (when no tag):
       application
       cxan
       exist
       ...
       
       XML output (with specific tags):
       <tags>
          <tag id="library"/>
          <subtag id="exist"/>
          <subtag id="google"/>
          <subtag id="http"/>
          <subtag id="saxon"/>
          <subtag id="web-api"/>
          <subtag id="zip"/>
          <pkg id="google-apis"/>
          <pkg id="http-client-exist"/>
          <pkg id="http-client-saxon"/>
          <pkg id="zip-saxon"/>
       </tags>
       
       Text output (with specific tags):
       tags: library
       subtags: exist, google, http, saxon, web-api, zip

       google-apis
       http-client-exist
       http-client-saxon
       zip-saxon
   -->

   <p:import href="../tools.xpl"/>

   <p:declare-step type="client:tag-stdout-tags">
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:xslt>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:template match="/tags">
                     <stdout>
                        <xsl:apply-templates select="*"/>
                     </stdout>
                  </xsl:template>
                  <xsl:template match="tag">
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

   <p:declare-step type="client:tag-stdout-tag">
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:xslt>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:template match="/tags">
                     <stdout>
                        <line>
                           <xsl:text>tags: </xsl:text>
                           <xsl:value-of select="tag/@id" separator=", "/>
                        </line>
                        <xsl:apply-templates select="*"/>
                     </stdout>
                  </xsl:template>
                  <xsl:template match="subtag[1]">
                     <line>
                        <xsl:text>subtags: </xsl:text>
                        <xsl:value-of select="../subtag/@id" separator=", "/>
                     </line>
                     <line/>
                  </xsl:template>
                  <xsl:template match="subtag"/>
                  <xsl:template match="pkg">
                     <line>
                        <xsl:value-of select="@id"/>
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

   <p:declare-step type="client:tag" name="pipeline">
      <!-- The input params.  Can only have a param 'tags' (optional), which is a space-
           separated list of tags. -->
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
         <p:variable name="tags"     select="/wrapper/c:param-set/c:param[@name eq 'tags']/@value"/>
         <p:variable name="tag-path" select="translate(normalize-space($tags), ' ', '/')"/>
         <p:choose>
            <p:when test="not($tag-path)">
               <client:http-get href="/tag"/>
               <p:choose>
                  <p:when test="$output eq 'xml'">
                     <p:identity/>
                  </p:when>
                  <p:otherwise>
                     <client:tag-stdout-tags/>
                  </p:otherwise>
               </p:choose>
            </p:when>
            <p:otherwise>
               <client:http-get>
                  <p:with-option name="href" select="concat('/tag/', $tag-path)"/>
               </client:http-get>
               <p:choose>
                  <p:when test="$output eq 'xml'">
                     <p:identity/>
                  </p:when>
                  <p:otherwise>
                     <client:tag-stdout-tag/>
                  </p:otherwise>
               </p:choose>
            </p:otherwise>
         </p:choose>
      </p:group>
   </p:declare-step>

</p:library>
