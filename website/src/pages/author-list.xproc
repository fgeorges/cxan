<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            pkg:import-uri="http://cxan.org/website/pages/author-list.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <da:list-authors/>

   <p:xslt>
      <p:input port="stylesheet">
         <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            version="2.0">
               <xsl:template match="/">
                  <page menu="author">
                     <title>Authors</title>
                     <xsl:apply-templates select="*"/>
                  </page>
               </xsl:template>
               <xsl:template match="authors[empty(author)]">
                  <para>There is no author at all in the DB?!?  Please report this.</para>
               </xsl:template>
               <xsl:template match="authors[exists(author)]">
                  <list>
                     <xsl:apply-templates select="author"/>
                  </list>
               </xsl:template>
               <xsl:template match="author">
                  <item>
                     <link uri="author/{ encode-for-uri(@id) }">
                        <xsl:value-of select="name/display"/>
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
