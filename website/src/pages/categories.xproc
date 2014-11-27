<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            pkg:import-uri="http://cxan.org/website/pages/categories.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <p:variable name="accept" select="/web:request/web:header[@name eq 'accept']/@value"/>

   <!-- the category id -->
   <p:variable name="id" select="/web:request/web:path/web:match[@name eq 'category']"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <da:packages-by-category>
      <p:with-option name="category" select="$id"/>
   </da:packages-by-category>

   <p:choose>
      <p:when test="$accept eq 'application/xml'">
         <app:wrap-xml-result/>
      </p:when>
      <p:otherwise>
         <p:xslt>
            <p:with-param name="id" select="$id"/>
            <p:input port="stylesheet">
               <p:inline>
                  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                  xmlns:xs="http://www.w3.org/2001/XMLSchema"
                                  version="2.0">
                     <!-- the cat id passed from the outside (even if no match found) -->
                     <xsl:param name="id" as="xs:string"/>
                     <xsl:template match="/">
                        <page menu="cat">
                           <title>
                              <xsl:value-of select="( @name, $id )[1]"/>
                           </title>
                           <xsl:if test="exists(cat)">
                              <list>
                                 <xsl:apply-templates select="cat" mode="menu"/>
                              </list>
                              <para/>
                           </xsl:if>
                           <xsl:choose>
                              <xsl:when test="empty(.//pkg)">
                                 <para>There is no package in this category.</para>
                              </xsl:when>
                              <xsl:otherwise>
                                 <table>
                                    <column>ID</column>
                                    <column>Description</column>
                                    <column>Category</column>
                                    <xsl:next-match/>
                                 </table>
                              </xsl:otherwise>
                           </xsl:choose>
                        </page>
                     </xsl:template>
                     <xsl:template match="pkg">
                        <row>
                           <cell>
                              <link uri="../pkg/{ @repo }">
                                 <xsl:value-of select="@repo"/>
                              </link>
                              <xsl:text>/</xsl:text>
                              <link uri="../pkg/{ @repo }/{ @abbrev }">
                                 <bold>
                                    <xsl:value-of select="@abbrev"/>
                                 </bold>
                              </link>
                           </cell>
                           <cell>
                              <xsl:value-of select="desc"/>
                           </cell>
                           <cell>
                              <xsl:value-of select="../@name"/>
                           </cell>
                        </row>
                     </xsl:template>
                     <xsl:template match="cat">
                        <xsl:apply-templates select="pkg">
                           <xsl:sort select="@id"/>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="cat"/>
                     </xsl:template>
                     <xsl:template match="cat" mode="menu">
                        <item>
                           <link uri="../cat/{ @id }">
                              <xsl:value-of select="@name"/>
                           </link>
                           <xsl:if test="exists(cat)">
                              <list>
                                 <xsl:apply-templates select="cat" mode="menu"/>
                              </list>
                           </xsl:if>
                        </item>
                     </xsl:template>
                  </xsl:stylesheet>
               </p:inline>
            </p:input>
         </p:xslt>
      </p:otherwise>
   </p:choose>

 </p:pipeline>
