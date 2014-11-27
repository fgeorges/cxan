<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:web="http://expath.org/ns/webapp"
                version="2.0">

   <pkg:import-uri>##none</pkg:import-uri>

   <xsl:param name="base-uri" required="yes" as="xs:string"/>

   <xsl:template match="/repositories[empty(repo)]">
      <page menu="pkg">
         <title>Repositories</title>
         <para>There is no repository at all in the system?!?  Please report this.</para>
      </page>
   </xsl:template>

   <xsl:template match="/repositories[exists(repo)]">
      <page menu="pkg">
         <title>Repositories</title>
         <para>Here is the list of all repositories in CXAN.</para>
         <table>
            <column>ID</column>
            <column>Description</column>
            <xsl:apply-templates select="repo"/>
         </table>
      </page>
   </xsl:template>

   <xsl:template match="repo">
      <row>
         <cell>
            <link uri="pkg/{ id }">
               <xsl:value-of select="id"/>
            </link>
         </cell>
         <cell>
            <xsl:value-of select="desc"/>
         </cell>
      </row>
   </xsl:template>

</xsl:stylesheet>
