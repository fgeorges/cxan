<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            pkg:import-uri="http://cxan.org/website/pages/tag-list.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <p:variable name="accept" select="/web:request/web:header[@name eq 'accept']/@value"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <da:list-tags/>

   <!--app:format-result>
      <!- - to pass the Accept: haeder - ->
      <p:input port="request">
         <p:pipe step="pipeline" port="request"/>
      </p:input>
      <p:input port="stylesheet">
         <p:inline>
            ...
         </p:inline>
      </p:input>
   </app:format-result-->

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
                     <xsl:template match="/exist:result">
                        <page menu="tag">
                           <title>Tags</title>
                           <xsl:apply-templates select="tags"/>
                        </page>
                     </xsl:template>
                     <xsl:template match="tags[empty(tag)]">
                        <para>There is no tag at all in the DB?!?  Please report this.</para>
                     </xsl:template>
                     <xsl:template match="tags[exists(tag)]">
                        <list>
                           <xsl:apply-templates select="tag"/>
                        </list>
                     </xsl:template>
                     <xsl:template match="tag">
                        <item>
                           <link uri="tag/{ encode-for-uri(.) }">
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
      </p:otherwise>
   </p:choose>

</p:pipeline>
