<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                version="1.0"
                exclude-inline-prefixes="c"
                name="pipeline">

   <!--
      Gather information about authors and packages they wrote, and store it in denormalized
      files in the directory in the option "authors-dir".  Each file is named after its
      author ID.
   -->

   <p:option name="authors-dir" required="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>The directory for the repositories to investigate.</p>
         <p>It must be an absolute URI, must starts with "file:/" and must ends with a slash. So for
            a human being to invoke this pipeline, the best solution is to use a wrapper shell
            script.</p>
      </p:documentation>
   </p:option>

   <p:input port="packages"/>
   <p:input port="authors"/>
   <p:output port="result"/>

   <p:serialization port="result" indent="true"/>

   <p:for-each>
      <p:iteration-source select="/authors/author">
         <p:pipe step="pipeline" port="authors"/>
      </p:iteration-source>
      <p:variable name="id"   select="/author/@id"/>
      <p:variable name="href" select="resolve-uri(concat($id, '.xml'), $authors-dir)"/>
      <!-- TODO: How to pass the current iteration doc to p:xslt, in addition to packages doc? -->
      <p:identity name="loop"/>
      <p:xslt>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
         <p:with-param name="id" select="$id"/>
         <p:input port="source">
            <p:pipe step="loop"     port="result"/>
            <p:pipe step="pipeline" port="packages"/>
         </p:input>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               exclude-result-prefixes="xs"
                               version="2.0">
                  <xsl:strip-space elements="*"/>
                  <xsl:param name="id" as="xs:string"/>
                  <xsl:variable name="pkg" as="element(pkg)+" select="collection()[2]/*/*/pkg"/>
                  <xsl:template match="/author">
                     <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                        <packages>
                           <xsl:for-each select="$pkg[author/@id = $id]">
                              <pkg id="{ @id }"/>
                           </xsl:for-each>
                        </packages>
                     </xsl:copy>
                  </xsl:template>
                  <xsl:template match="node()">
                     <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:apply-templates/>
                     </xsl:copy>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
      <!--
         TODO: Store each author denormalized document in a file authors/myname.xml...
      -->
      <p:store indent="true">
         <p:with-option name="href" select="$href"/>
      </p:store>
      <p:identity>
         <p:input port="source">
            <p:inline><file/></p:inline>
         </p:input>
      </p:identity>
      <p:add-attribute match="/file" attribute-name="href">
         <p:with-option name="attribute-value" select="$href"/>
      </p:add-attribute>
   </p:for-each>

   <p:wrap-sequence wrapper="result"/>

</p:declare-step>
