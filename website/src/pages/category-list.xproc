<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            pkg:import-uri="http://cxan.org/website/pages/category-list.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <p:variable name="accept" select="/web:request/web:header[@name eq 'accept']/@value"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <da:list-categories/>

   <p:choose>
      <p:when test="$accept eq 'application/xml'">
         <app:wrap-xml-result/>
      </p:when>
      <p:otherwise>
         <p:xslt>
            <p:input port="stylesheet">
               <p:inline>
                  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                  version="2.0">
                     <xsl:template match="/">
                        <page menu="cat">
                           <title>Categories</title>
                           <xsl:apply-templates select="exist:result"/>
                        </page>
                     </xsl:template>
                     <xsl:template match="exist:result[empty(categories)]">
                        <para>There is no category at all in the DB?!?  Please report this.</para>
                     </xsl:template>
                     <xsl:template match="exist:result[exists(categories)]">
                        <list>
                           <xsl:apply-templates select="categories/cat"/>
                        </list>
                     </xsl:template>
                     <xsl:template match="cat">
                        <item>
                           <link uri="cat/{ @id }">
                              <xsl:value-of select="@name"/>
                           </link>
                           <xsl:if test="exists(cat)">
                              <list>
                                 <xsl:apply-templates select="cat"/>
                              </list>
                           </xsl:if>
                        </item>
                     </xsl:template>
                  </xsl:stylesheet>
               </p:inline>
            </p:input>
            <p:input port="parameters">
               <p:empty/>
            </p:input>
         </p:xslt>
      </p:otherwise>
   </p:choose>

</p:pipeline>
