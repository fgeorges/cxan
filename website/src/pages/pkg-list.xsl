<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:web="http://expath.org/ns/webapp"
                xmlns:ser="http://fgeorges.org/xslt/serial"
                exclude-result-prefixes="xs c pkg web ser"
                version="2.0">

   <!--
      TODO: Lot of duplicated code with `pkg-get.xsl`.
      Use a common library...
   -->

   <xsl:import href="http://fgeorges.org/ns/xslt/serial.xsl"/>
   <xsl:import href="http://fgeorges.org/ns/xslt/serial-html.xsl"/>

   <pkg:import-uri>##none</pkg:import-uri>

   <xsl:param name="base-uri"  as="xs:string"  required="yes"/>
   <xsl:param name="repo-list" as="xs:boolean" select="false()"/>
   <xsl:param name="repo-id"   as="xs:string?"/>

   <xsl:variable name="config" as="element(c:param-set)" select="
       doc(web:config-param('config-params'))/*"/>

   <xsl:variable name="home" as="xs:string" select="
       $config/c:param[@name eq 'home-uri']/@value"/>

   <xsl:template match="/packages[empty(pkg)]">
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
               <para>There is no package at all in the system?!?  Please report this.</para>
            </xsl:otherwise>
         </xsl:choose>
      </page>
   </xsl:template>

   <xsl:template match="/packages[exists(pkg)]">
      <page menu="pkg">

         <title>Packages</title>
         <xsl:choose>
            <xsl:when test="exists($repo-id)">
               <para>
                  <xsl:text>Here is the list of packages in the repo </xsl:text>
                  <code>
                     <xsl:value-of select="$repo-id"/>
                  </code>
                  <xsl:text>.</xsl:text>
               </para>
            </xsl:when>
            <xsl:otherwise>
               <para>Here is the list of all packages in CXAN.</para>
            </xsl:otherwise>
         </xsl:choose>
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

         <subtitle>Badge</subtitle>
         <link href="{ $repo-id }"><image alt="CXAN" src="../badge/{ $repo-id }"/></link>
         <para/>
         <para>HTML:</para>
         <xsl:variable name="code" as="element()">
            <a href="{ $home }pkg/{ $repo-id }">
               <img alt="CXAN" src="{ $home }badge/{ $repo-id }"/>
            </a>
         </xsl:variable>
         <code>
            <xsl:sequence select="ser:serialize-to-html($code)"/>
         </code>
         <para>Markdown:</para>
         <code>
            <xsl:text>[![CXAN](</xsl:text>
            <xsl:value-of select="$home"/>
            <xsl:text>badge/</xsl:text>
            <xsl:value-of select="$repo-id"/>
            <xsl:text>)](</xsl:text>
            <xsl:value-of select="$home"/>
            <xsl:text>pkg/</xsl:text>
            <xsl:value-of select="$repo-id"/>
            <xsl:text>)</xsl:text>
         </code>

      </page>
   </xsl:template>

   <xsl:template match="pkg">
      <row>
         <cell>
            <link uri="{ 'pkg/'[$repo-list] }{ repo }">
               <xsl:value-of select="repo"/>
            </link>
            <xsl:text> / </xsl:text>
            <link uri="{ 'pkg/'[$repo-list] }{ repo }/{ abbrev }">
               <bold>
                  <xsl:value-of select="abbrev"/>
               </bold>
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
                  <link uri="{ if ( $repo-list ) then 'pkg' else '.' }?name={ encode-for-uri(name) }">
                     <xsl:value-of select="name"/>
                  </link>
                  <xsl:text>.</xsl:text>
               </cell>
            </xsl:when>
         </xsl:choose>
      </row>
   </xsl:template>

</xsl:stylesheet>
