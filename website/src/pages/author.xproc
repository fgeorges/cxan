<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            pkg:import-uri="http://cxan.org/website/pages/author.xproc"
            name="pipeline"
            version="1.0">

   <!--
       TODO: For now, displays the packages this guy is an author of.
       Display as well the packages he is a maintainer of.
   -->

   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <p:variable name="id" select="/web:request/web:path/web:match[@name eq 'author']"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <da:packages-by-author>
      <p:with-option name="author" select="$id"/>
   </da:packages-by-author>

   <p:xslt>
      <p:input port="stylesheet">
         <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            xmlns:xs="http://www.w3.org/2001/XMLSchema"
                            version="2.0">
               <xsl:param name="id" required="yes" as="xs:string"/>
               <xsl:template match="/no-author">
                  <page menu="author">
                     <title>Author</title>
                     <para>
                        <xsl:text>There is no author with the ID '</xsl:text>
                        <code>
                           <xsl:value-of select="$id"/>
                        </code>
                        <xsl:text>'.</xsl:text>
                     </para>
                  </page>
               </xsl:template>
               <xsl:template match="/author">
                  <page menu="author">
                     <title>
                        <xsl:value-of select="name/display"/>
                     </title>
                     <xsl:apply-templates select="packages"/>
                  </page>
               </xsl:template>
               <xsl:template match="packages[exists(pkg)]">
                  <table>
                     <column>ID</column>
                     <column>Description</column>
                     <column>Role</column>
                     <xsl:for-each select="pkg">
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
                           <xsl:choose>
                              <xsl:when test="exists(desc)">
                                 <xsl:value-of select="desc"/>
                              </xsl:when>
                              <xsl:when test="exists(name)">
                                 <xsl:text>Package name: </xsl:text>
                                 <link uri="../pkg?name={ encode-for-uri(name) }">
                                    <xsl:value-of select="name"/>
                                 </link>
                                 <xsl:text>.</xsl:text>
                              </xsl:when>
                           </xsl:choose>
                        </cell>
                        <cell>
                           <xsl:choose>
                              <xsl:when test="@role eq 'author'">Author</xsl:when>
                              <xsl:when test="@role eq 'maintainer'">Maintainer</xsl:when>
                           </xsl:choose>
                        </cell>
                     </row>
                     </xsl:for-each>
                  </table>
               </xsl:template>
               <xsl:template match="packages[empty(pkg)]">
                  <para>
                     <xsl:text>The author </xsl:text>
                     <xsl:value-of select="name/display"/>
                     <xsl:text> (with the ID '</xsl:text>
                     <code>
                        <xsl:value-of select="$id"/>
                     </code>
                     <xsl:text>') has no package associated in the system.</xsl:text>
                  </para>
               </xsl:template>
            </xsl:stylesheet>
         </p:inline>
      </p:input>
      <p:with-param name="id" select="$id"/>
   </p:xslt>

</p:pipeline>
