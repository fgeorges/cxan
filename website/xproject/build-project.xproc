<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:proj="http://expath.org/ns/project"
                name="pipeline"
                version="1.0">

   <!-- the project.xml -->
   <p:input port="source" primary="true"/>

   <!-- the parameters -->
   <p:input port="parameters" primary="true" kind="parameter"/>

   <p:import href="http://expath.org/ns/project/build.xproc"/>

   <!-- transform page.xsl -->
   <p:xslt name="page-xsl">
      <p:with-param name="proj:version" select="/proj:project/@version"/>
      <p:input port="parameters">
         <p:pipe step="pipeline" port="parameters"/>
      </p:input>
      <p:input port="source">
         <p:document href="../src/page.xsl"/>
      </p:input>
      <p:input port="stylesheet">
         <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            xmlns:xs="http://www.w3.org/2001/XMLSchema"
                            version="2.0">
               <xsl:param name="proj:version"  as="xs:string"/>
               <xsl:param name="proj:revision" as="xs:string"/>
               <!-- Copy everything... -->
               <xsl:template match="node()">
                  <xsl:copy>
                     <xsl:copy-of select="@*"/>
                     <xsl:apply-templates select="node()"/>
                  </xsl:copy>
               </xsl:template>
               <!-- ...but resolve the $version and $revision global variables. -->
               <xsl:template match="xsl:stylesheet/xsl:variable[@name = ('version', 'revision')]">
                  <xsl:copy>
                     <xsl:copy-of select="@* except @select"/>
                     <xsl:attribute name="select" select="
                         replace(
                           replace(@select, '@@REVISION@@', $proj:revision),
                           '@@VERSION@@', $proj:version)"/>
                  </xsl:copy>
               </xsl:template>
            </xsl:stylesheet>
         </p:inline>
      </p:input>
   </p:xslt>

   <!-- call the standard step with the modified page.xsl -->
   <proj:build ignore-dirs=".~,.svn,templates"
               ignore-components="xquery-parser.xql">
      <p:input port="source">
         <p:pipe step="pipeline" port="source"/>
      </p:input>
      <p:input port="files">
         <p:pipe step="page-xsl" port="result"/>
      </p:input>
   </proj:build>

</p:declare-step>
