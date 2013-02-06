<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            pkg:import-uri="http://cxan.org/website/pages/categories.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <p:variable name="accept" select="/web:request/web:header[@name eq 'accept']/@value"/>

   <!-- the category id -->
   <p:variable name="id"     select="/web:request/web:path/web:match[@name eq 'category']"/>
   <p:variable name="id-str" select="replace($id, '''', '''''')"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <p:identity>
      <p:input port="source">
         <p:inline>
            <c:data>
               declare namespace cxan = "http://cxan.org/ns/package";
               declare function local:copy($cat as element(cat)) {
                 &lt;cat> {
                   $cat/@*
                   ,
                   let $pp := collection('/db/cxan/packages/')/cxan:package[cxan:category/@id eq $cat/@id]
                   for $p in distinct-values($pp/@id)
                   order by $p
                   return
                     &lt;pkg id="{ $p }"/>
                   ,
                   for $c in $cat/cat return local:copy($c)
                 }
                 &lt;/cat>
               };
               let $c := doc('/db/cxan/categories.xml')/categories//cat[@id eq '<app:id/>']
               return
                 if ( $c ) then local:copy($c) else ()
            </c:data>
         </p:inline>
      </p:input>
   </p:identity>

   <!-- paste the category id within the query -->
   <p:string-replace match="app:id">
      <p:with-option name="replace" select="concat('''', $id-str, '''')"/>
   </p:string-replace>

   <app:query-exist/>

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
                     <xsl:template match="/exist:result">
                        <page menu="cat">
                           <title>
                              <xsl:value-of select="( cat/@name, $id )[1]"/>
                           </title>
                           <xsl:if test="exists(cat/cat)">
                              <list>
                                 <xsl:apply-templates select="cat/cat" mode="menu"/>
                              </list>
                              <para/>
                           </xsl:if>
                           <xsl:choose>
                              <xsl:when test="empty(cat)">
                                 <para>The category does not exist.</para>
                              </xsl:when>
                              <xsl:when test="empty(cat//pkg)">
                                 <para>There is no package in this category.</para>
                              </xsl:when>
                              <xsl:otherwise>
                                 <table>
                                    <column>package</column>
                                    <column>category</column>
                                    <xsl:apply-templates select="pkg">
                                       <xsl:sort select="@id"/>
                                    </xsl:apply-templates>
                                    <xsl:apply-templates select="cat"/>
                                 </table>
                              </xsl:otherwise>
                           </xsl:choose>
                        </page>
                     </xsl:template>
                     <xsl:template match="pkg">
                        <row>
                           <cell>
                              <link uri="../pkg/{ @id }">
                                 <xsl:value-of select="@id"/>
                              </link>
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
