<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            pkg:import-uri="http://cxan.org/website/pages/author.xproc"
            name="pipeline"
            version="1.0">

   <!--
       TODO: For now, displays the packages this guy is an author of.
       Display as well the packages he is a maintainer of.
   -->

   <p:import href="../tools.xpl"/>

   <p:variable name="id"     select="/web:request/web:path/web:match[@name eq 'author']"/>
   <p:variable name="id-str" select="replace($id, '''', '''''')"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <p:identity>
      <p:input port="source">
         <p:inline>
            <c:data>
               declare namespace cxan = "http://cxan.org/ns/package";
               let $id := '<app:id/>'
               let $pp := collection('/db/cxan/packages/')/cxan:package[cxan:author/@id = $id]
               return (
                 &lt;author>{ ( $pp/cxan:author[@id = $id] )[1]/string(.) }&lt;/author>,
                 for $p in distinct-values($pp/@id)
                 order by $p
                 return
                   &lt;pkg id="{ $p }"/>
               )
            </c:data>
         </p:inline>
      </p:input>
   </p:identity>

   <!-- paste the author id within the query -->
   <p:string-replace match="app:id">
      <!-- the *value* of this option is an XPath expression, in this case a
           literal string, that is, the quoted string "'the-id'" -->
      <p:with-option name="replace" select="concat('''', $id-str, '''')"/>
   </p:string-replace>

   <app:query-exist/>

   <p:xslt>
      <p:input port="stylesheet">
         <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            xmlns:xs="http://www.w3.org/2001/XMLSchema"
                            version="2.0">
               <xsl:param name="id" required="yes" as="xs:string"/>
               <xsl:template match="/exist:result[author/node()]">
                  <page menu="author">
                     <title>
                        <xsl:value-of select="author"/>
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
               <xsl:template match="/exist:result[empty(author/node())]">
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
