<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:client="http://cxan.org/ns/client"
                pkg:import-uri="http://cxan.org/client/text-action.xproc"
                name="pipeline"
                version="1.0">

   <p:input port="parameters" kind="parameter" primary="true"/>

   <p:output port="result" primary="true"/>
   <p:serialization port="result" method="text"/>

   <p:option name="action" required="true"/>

   <p:import href="tools.xpl"/>
   <p:import href="actions/category.xproc"/>
   <p:import href="actions/resolve.xproc"/>
   <p:import href="actions/tag.xproc"/>
   <p:import href="actions/upload.xproc"/>

   <p:choose>
      <p:when test="$action eq 'category'">
         <client:category output="text"/>
      </p:when>
      <p:when test="$action eq 'resolve'">
         <client:resolve output="text"/>
      </p:when>
      <p:when test="$action eq 'tag'">
         <client:tag output="text"/>
      </p:when>
      <p:when test="$action eq 'upload'">
         <client:upload output="text"/>
      </p:when>
      <p:otherwise>
         <client:error code="client:ERR002">
            <p:with-option name="msg" select="concat('Unsupported action: ''', $action, '''')"/>
         </client:error>
      </p:otherwise>
   </p:choose>

   <p:xslt>
      <p:input port="stylesheet">
         <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            version="2.0">
               <xsl:template match="node()|@*">
                  <xsl:copy>
                     <xsl:apply-templates select="@*, node()"/>
                  </xsl:copy>
               </xsl:template>
               <xsl:template match="line[not(position() eq 1)]">
                  <xsl:copy>
                     <xsl:apply-templates select="@*"/>
                     <xsl:text>&#10;</xsl:text>
                     <xsl:apply-templates select="node()"/>
                  </xsl:copy>
               </xsl:template>
            </xsl:stylesheet>
         </p:inline>
      </p:input>
      <p:input port="parameters">
         <p:empty/>
      </p:input>
   </p:xslt>

</p:declare-step>
