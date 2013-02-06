<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            pkg:import-uri="http://cxan.org/website/pages/tags.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <!--
       A specific tag (maybe several tags, connected by a logical AND).
       
       TODO: The page must see all package ID for which there is at least one cxan.xml
       with those tags, plus all other tags in those cxan.xml files (that is, all other
       tags that can be used with the current tags, to have a non-empty intersection).
   -->

   <p:variable name="tags"     select="/web:request/web:path/web:match[@name eq 'tags']"/>
   <p:variable name="tags-str" select="replace($tags, '''', '''''')"/>
   <p:variable name="accept"   select="/web:request/web:header[@name eq 'accept']/@value"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <p:identity>
      <p:input port="source">
         <p:inline>
            <c:data>
               declare namespace cxan = "http://cxan.org/ns/package";
               declare function local:match($p as element(cxan:package), $tags as xs:string+) {
                 every $t in $tags satisfies $p[cxan:tag = $t]
               };
               let $tags-str := '<app:tags/>'
               let $tags     := tokenize($tags-str, '/')
               let $pp       := collection('/db/cxan/packages/')/cxan:package[local:match(., $tags)]
               return
                 &lt;tags> {
                   for $t in $tags
                   order by $t
                   return
                     &lt;tag id="{ $t }"/>,
                   for $t in distinct-values($pp/cxan:tag)[not(. = $tags)]
                   order by $t
                   return
                     &lt;subtag id="{ $t }"/>,
                   for $p in distinct-values($pp/@id)
                   order by $p
                   return
                     &lt;pkg id="{ $p }"/>
                 }
                 &lt;/tags>
            </c:data>
         </p:inline>
      </p:input>
   </p:identity>

   <!-- paste the tags string within the query -->
   <p:string-replace match="app:tags">
      <!-- the *value* of this option is an XPath expression, in this case a
           literal string, that is, the quoted string "'the-id'" -->
      <p:with-option name="replace" select="concat('''', $tags-str, '''')"/>
   </p:string-replace>

   <app:query-exist>
      <p:log href="/tmp/tags-1.log" port="result"/>
   </app:query-exist>

   <p:choose>
      <p:when test="$accept eq 'application/xml'">
         <app:wrap-xml-result/>
      </p:when>
      <p:otherwise>
         <p:xslt>
            <p:input port="stylesheet">
               <p:inline>
                  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                  xmlns:xs="http://www.w3.org/2001/XMLSchema"
                                  version="2.0">
                     <xsl:param name="tags" as="xs:string" required="yes"/>
                     <xsl:template match="/exist:result/tags">
                        <page menu="tag">
                           <xsl:choose>
                              <xsl:when test="count(tag) eq 1">
                                 <title>
                                    <xsl:value-of select="tag/@id"/>
                                 </title>
                              </xsl:when>
                              <xsl:otherwise>
                                 <title>Tags</title>
                                 <para>
                                    <xsl:text>Tags: </xsl:text>
                                    <!-- TODO: For each tag, add a little button (-) to link to the
                                         same URI, but with a particular tag removed... -->
                                    <xsl:value-of select="tag/@id" separator=", "/>
                                    <xsl:text>.</xsl:text>
                                 </para>
                              </xsl:otherwise>
                           </xsl:choose>
                           <xsl:if test="exists(subtag)">
                              <para>
                                 <xsl:text>This (those) tag(s) can be used in conjunction</xsl:text>
                                 <xsl:text> with the following one(s): </xsl:text>
                                 <xsl:for-each select="subtag">
                                    <link uri="/tag/{ $tags }/{ @id }" absolute="true">
                                       <xsl:value-of select="@id"/>
                                    </link>
                                    <xsl:if test="position() ne last()">
                                       <xsl:text>, </xsl:text>
                                    </xsl:if>
                                 </xsl:for-each>
                                 <xsl:text></xsl:text>
                              </para>
                           </xsl:if>
                           <xsl:if test="empty(pkg)">
                              <para>There is no package with this (those) tag(s).</para>
                           </xsl:if>
                           <list>
                              <xsl:for-each select="pkg">
                                 <item>
                                    <link uri="/pkg/{ encode-for-uri(@id) }" absolute="true">
                                       <xsl:value-of select="@id"/>
                                    </link>
                                 </item>
                              </xsl:for-each>
                           </list>
                        </page>
                     </xsl:template>
                  </xsl:stylesheet>
               </p:inline>
            </p:input>
            <p:with-param name="tags" select="$tags"/>
         </p:xslt>
      </p:otherwise>
   </p:choose>

 </p:pipeline>
