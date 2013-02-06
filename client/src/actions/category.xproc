<p:library  xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:client="http://cxan.org/ns/client"
            xmlns:pkg="http://expath.org/ns/pkg"
            pkg:import-uri="#none"
            version="1.0">

   <!--
       XML output (when no category):
       <categories>
          <cat id="applications" name="Applications"/>
          <cat id="tools" name="Tools"/>
          <cat id="web-api" name="Web API"/>
          <cat id="processor" name="Processor-specific">
             <cat id="saxon" name="Saxon extensions"/>
             <cat id="exist" name="eXist extensions"/>
          </cat>
       </categories>
       
       Text output (when no category):
       <stdout>
          <line>applications: Applications</line>
          <line>tools: Tools</line>
          <line>web-api: Web API</line>
          <line>processor: Processor-specific</line>
          <line>   saxon: Saxon extensions</line>
          <line>   exist: eXist extensions</line>
       </stdout>
       
       XML output (with specific category):
       <cat id="processor" name="Processor-specific">
          <cat id="saxon" name="Saxon extensions">
             <pkg id="http-client-saxon"/>
             <pkg id="zip-saxon"/>
          </cat>
          <cat id="exist" name="eXist extensions">
             <pkg id="http-client-exist"/>
          </cat>
       </cat>
       
       Text output (with specific category):
       <stdout>
          <line>http-client-saxon (saxon)</line>
          <line>zip-saxon (saxon)</line>
          <line>http-client-exist (exist)</line>
       </stdout>
       
       With a specific category, display the name of a package category in
       parenthesis if it is in a sub-category only (not when it is in the very
       same category we display).
   -->

   <p:import href="../tools.xpl"/>

   <p:declare-step type="client:category-stdout-categories">
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:xslt>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:template match="/categories">
                     <stdout>
                        <xsl:apply-templates select="cat"/>
                     </stdout>
                  </xsl:template>
                  <xsl:template match="cat">
                     <xsl:param name="level" select="0"/>
                     <line>
                        <!-- TODO: Embed lines instead?  (and then handle the indent
                             itself in the formatting step...) -->
                        <xsl:call-template name="indent">
                           <xsl:with-param name="level" select="$level"/>
                        </xsl:call-template>
                        <xsl:value-of select="@id"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="@name"/>
                     </line>
                     <xsl:apply-templates select="cat">
                        <xsl:with-param name="level" select="$level + 1"/>
                     </xsl:apply-templates>
                  </xsl:template>
                  <xsl:template name="indent">
                     <xsl:param name="level" required="yes"/>
                     <xsl:if test="$level gt 0">
                        <xsl:text>   </xsl:text>
                        <xsl:call-template name="indent">
                           <xsl:with-param name="level" select="$level - 1"/>
                        </xsl:call-template>
                     </xsl:if>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <p:declare-step type="client:category-stdout-category">
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:xslt>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:template match="/cat">
                     <stdout>
                        <xsl:apply-templates select=".//pkg"/>
                     </stdout>
                  </xsl:template>
                  <xsl:template match="pkg">
                     <line>
                        <xsl:value-of select="@id"/>
                        <xsl:if test="not(.. is /cat)">
                           <xsl:text> (</xsl:text>
                           <xsl:value-of select="../@id"/>
                           <xsl:text>)</xsl:text>
                        </xsl:if>
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

   <p:declare-step type="client:category" name="pipeline">
      <!-- The input params.  Can only have a param 'category' (optional) which
           is a category ID. -->
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
         <p:variable name="category" select="/wrapper/c:param-set/c:param[@name eq 'category']/@value"/>
         <p:choose>
            <p:when test="not($category)">
               <client:http-get href="/cat"/>
               <p:choose>
                  <p:when test="$output eq 'xml'">
                     <p:identity/>
                  </p:when>
                  <p:otherwise>
                     <client:category-stdout-categories/>
                  </p:otherwise>
               </p:choose>
            </p:when>
            <p:otherwise>
               <client:http-get>
                  <p:with-option name="href" select="concat('/cat/', $category)"/>
               </client:http-get>
               <p:choose>
                  <p:when test="$output eq 'xml'">
                     <p:identity/>
                  </p:when>
                  <p:otherwise>
                  <client:category-stdout-category/>
                  </p:otherwise>
               </p:choose>
            </p:otherwise>
         </p:choose>
      </p:group>
   </p:declare-step>

</p:library>
