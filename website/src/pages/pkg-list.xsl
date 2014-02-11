<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:web="http://expath.org/ns/webapp"
                xmlns:exist="http://exist.sourceforge.net/NS/exist"
                version="2.0">

   <pkg:import-uri>##none</pkg:import-uri>

   <xsl:param name="base-uri" required="yes" as="xs:string"/>

   <xsl:template match="/exist:result/packages[count(pkg) eq 1]">
      <xsl:variable name="page" select="concat('pkg/', pkg/id)"/>
      <xsl:variable name="uri"  select="resolve-uri($page, $base-uri)"/>
      <web:response status="302" message="Found">
         <web:header name="Location" value="{ $uri }"/>
         <web:body content-type="text/html">
            <html xmlns="http://www.w3.org/1999/xhtml">
               <head>
                  <title>Redirect</title>
               </head>
               <body>
                  <p>
                     <xsl:text>You are going to be redirected to </xsl:text>
                     <a href="{ $uri }">
                        <xsl:value-of select="$uri"/>
                     </a>
                     <xsl:text>.</xsl:text>
                  </p>
               </body>
            </html>
         </web:body>
      </web:response>
   </xsl:template>

   <xsl:template match="/exist:result/packages[empty(pkg)]">
      <page menu="pkg">
         <title>Packages</title>
         <xsl:choose>
            <xsl:when test="exists(name)">
               <para>
                  <xsl:text>There is no package with the name: "</xsl:text>
                  <code>
                     <xsl:value-of select="name"/>
                  </code>
                  <xsl:text>".</xsl:text>
               </para>
            </xsl:when>
            <xsl:otherwise>
               <para>There is no package at all in the DB?!?  Please report this.</para>
            </xsl:otherwise>
         </xsl:choose>
      </page>
   </xsl:template>

   <xsl:template match="/exist:result/packages[count(pkg) gt 1]">
      <page menu="pkg">
         <title>Packages</title>
         <para>Here is the list of all packages in CXAN.</para>
         <xsl:if test="exists(name)">
            <named-info>
               <row>
                  <name>Package name</name>
                  <info>
                     <xsl:value-of select="name"/>
                  </info>
               </row>
            </named-info>
         </xsl:if>
         <table>
            <column>ID</column>
            <column>Description</column>
            <xsl:apply-templates select="pkg"/>
         </table>
      </page>
   </xsl:template>

   <xsl:template match="pkg">
      <row>
         <cell>
            <link uri="pkg/{ id }">
               <xsl:value-of select="id"/>
            </link>
         </cell>
         <xsl:choose>
            <xsl:when test="exists(desc)">
               <cell>
                  <xsl:value-of select="desc"/>
               </cell>
            </xsl:when>
            <xsl:when test="exists(name)">
               <cell>
                  <xsl:text>Package name: </xsl:text>
                  <link uri="pkg?name={ encode-for-uri(name) }">
                     <xsl:value-of select="name"/>
                  </link>
                  <xsl:text>.</xsl:text>
               </cell>
            </xsl:when>
         </xsl:choose>
      </row>
   </xsl:template>

</xsl:stylesheet>
