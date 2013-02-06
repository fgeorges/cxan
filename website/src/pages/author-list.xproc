<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            pkg:import-uri="http://cxan.org/website/pages/author-list.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <!-- TODO: Add windowing. -->
   <app:query-exist>
      <p:log href="/tmp/tags.log" port="result"/>
      <p:input port="source">
         <p:inline>
            <c:data>
               declare namespace cxan = "http://cxan.org/ns/package";
               let $authors := collection('/db/cxan/packages/')/cxan:package/cxan:author
               for $a  in distinct-values($authors)
               for $id in distinct-values($authors[. eq $a]/@id)
               order by $a, $id
               return
                 &lt;author id="{ $id }">{ $a }&lt;/author>
            </c:data>
         </p:inline>
      </p:input>
   </app:query-exist>

   <p:xslt>
      <p:input port="stylesheet">
         <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            version="2.0">
               <xsl:template match="/">
                  <page menu="author">
                     <title>Authors</title>
                     <xsl:apply-templates select="exist:result"/>
                  </page>
               </xsl:template>
               <xsl:template match="exist:result[empty(author)]">
                  <para>There is no author at all in the DB?!?  Please report this.</para>
               </xsl:template>
               <xsl:template match="exist:result[exists(author)]">
                  <list>
                     <xsl:apply-templates select="*"/>
                  </list>
               </xsl:template>
               <xsl:template match="author">
                  <item>
                     <link uri="author/{ encode-for-uri(@id) }">
                        <xsl:value-of select="."/>
                     </link>
                  </item>
               </xsl:template>
            </xsl:stylesheet>
         </p:inline>
      </p:input>
      <p:input port="parameters">
         <p:empty/>
      </p:input>
   </p:xslt>

</p:pipeline>
