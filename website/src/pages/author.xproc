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
               <xsl:template match="/packages-by-author[exists(author)]">
                  <page menu="author">
                     <title>
                        <xsl:value-of select="author/name/display"/>
                     </title>
                     <list>
                        <xsl:for-each select="pkg">
                           <item>
                              <link uri="../pkg/{ encode-for-uri(@id) }">
                                 <xsl:value-of select="@id"/>
                              </link>
                           </item>
                        </xsl:for-each>
                     </list>
                  </page>
               </xsl:template>
               <xsl:template match="/packages-by-author[exists(author)][empty(pkg)]" priority="2">
                  <page menu="author">
                     <title>
                        <xsl:value-of select="author/name/display"/>
                     </title>
                     <para>
                        <xsl:text>The author </xsl:text>
                        <xsl:value-of select="author/name/display"/>
                        <xsl:text> (with the ID '</xsl:text>
                        <code>
                           <xsl:value-of select="$id"/>
                        </code>
                        <xsl:text>') has no package associated in the system.</xsl:text>
                     </para>
                  </page>
               </xsl:template>
               <xsl:template match="/packages-by-author[empty(author)]">
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
            </xsl:stylesheet>
         </p:inline>
      </p:input>
      <p:with-param name="id" select="$id"/>
   </p:xslt>

</p:pipeline>
