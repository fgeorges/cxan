<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:cxan="http://cxan.org/ns/package"
                xmlns:exist="http://exist.sourceforge.net/NS/exist"
                version="2.0">

   <pkg:import-uri>##none</pkg:import-uri>

   <xsl:template match="/">
<!-- DEBUG: ... -->
<xsl:message>
   PKG-GET.XSL: <xsl:copy-of select="."/>
</xsl:message>
      <!--
          TODO: The query can return nothing, if the ID provided does
          not exist.  Check that and return a 404 in that case.  Check
          also for multiple packages, in case of inconsistancy.
      -->
      <xsl:variable name="pkg" select="exist:result/package/pkg"/>
      <!-- the version elements, sorted descendently -->
      <xsl:variable name="versions" as="element(version)+">
         <xsl:perform-sort select="$pkg/version">
            <xsl:sort select="@id" order="descending"/>
         </xsl:perform-sort>
      </xsl:variable>
      <xsl:variable name="descriptors" select="exist:result/package/pkg:package"/>
      <xsl:variable name="cxan-desc"   select="exist:result/package/cxan:package"/>
      <xsl:variable name="title"       select="
          ( $cxan-desc/cxan:title, $descriptors/pkg:title )[1]"/>
      <xsl:variable name="home"        select="
          ( $cxan-desc/cxan:home, $descriptors/pkg:home )[1]"/>
      <page menu="pkg">
         <title>
            <xsl:value-of select="$pkg/@id"/>
         </title>
         <xsl:if test="exists($cxan-desc/cxan:abstract)">
            <para>
               <xsl:value-of select="$cxan-desc/cxan:abstract"/>
            </para>
         </xsl:if>
         <named-info>
            <row>
               <name>ID</name>
               <info>
                  <xsl:value-of select="$pkg/@id"/>
               </info>
            </row>
            <row>
               <name>Name</name>
               <info>
                  <xsl:value-of select="$pkg/name"/>
               </info>
            </row>
            <row>
               <name>Title</name>
               <info>
                  <xsl:value-of select="$title"/>
               </info>
            </row>
            <row>
               <name>Home</name>
               <info>
                  <link uri="{ $home }">
                     <xsl:value-of select="$home"/>
                  </link>
               </info>
            </row>
            <row>
               <name>Author</name>
               <info>
                  <xsl:for-each select="$cxan-desc/cxan:author">
                     <xsl:choose>
                        <xsl:when test="exists(@id)">
                           <link uri="../author/{ @id }">
                              <xsl:value-of select="."/>
                           </link>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:value-of select="."/>
                        </xsl:otherwise>
                     </xsl:choose>
                     <xsl:if test="position() ne last()">
                        <xsl:text>, </xsl:text>
                     </xsl:if>
                  </xsl:for-each>
               </info>
            </row>
            <xsl:if test="exists($cxan-desc/cxan:maintainer)">
               <row>
                  <name>Package maintainer</name>
                  <info>
                     <xsl:for-each select="$cxan-desc/cxan:maintainer">
                        <xsl:choose>
                           <xsl:when test="exists(@id)">
                              <link uri="../author/{ @id }">
                                 <xsl:value-of select="."/>
                              </link>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of select="."/>
                           </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position() ne last()">
                           <xsl:text>, </xsl:text>
                        </xsl:if>
                     </xsl:for-each>
                  </info>
               </row>
            </xsl:if>
            <row>
               <name>Categories</name>
               <info>
                  <xsl:for-each select="$cxan-desc/cxan:category">
                     <link uri="../cat/{ @id }">
                        <xsl:value-of select="."/>
                     </link>
                     <xsl:if test="position() ne last()">
                        <xsl:text>, </xsl:text>
                     </xsl:if>
                  </xsl:for-each>
               </info>
            </row>
            <row>
               <name>Tags</name>
               <info>
                  <xsl:for-each select="$cxan-desc/cxan:tag">
                     <link uri="../tag/{ . }">
                        <xsl:value-of select="."/>
                     </link>
                     <xsl:if test="position() ne last()">
                        <xsl:text>, </xsl:text>
                     </xsl:if>
                  </xsl:for-each>
               </info>
            </row>
         </named-info>
         <xsl:for-each select="$pkg/version">
            <!-- TODO: Sort not as a string, but as a SemVer instead. -->
            <xsl:sort select="@id" order="descending"/>
            <xsl:variable name="ver"  select="@id"/>
            <xsl:variable name="desc" select="$descriptors[@version eq $ver]"/>
            <subtitle>
               <xsl:value-of select="$ver"/>
            </subtitle>
            <named-info>
               <!--
                   TODO: Give files a name ('package' for the XAR/XAW, 'release'
                   for the ZIP, etc.)
               -->
               <xsl:for-each select="file">
                  <row>
                     <name>File</name>
                     <info>
                        <link uri="../file/{ . }">
                           <!-- must always contain '/', but just to be on the safe side... -->
                           <xsl:value-of select="
                               if ( contains(., '/') ) then
                                 substring-after(., '/')
                               else
                                 ."/>
                        </link>
                     </info>
                  </row>
               </xsl:for-each>
               <xsl:for-each select="$desc/pkg:dependency">
                  <!-- TODO: Handle different kind of dependencies (on processors,
                       with specific versions, etc.) -->
                  <row>
                     <name>Dependency</name>
                     <info>
                        <xsl:choose>
                           <xsl:when test="exists(@package)">
                              <link uri="../pkg?name={ encode-for-uri(@package) }">
                                 <xsl:value-of select="@package"/>
                              </link>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of select="@processor"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </info>
                  </row>
               </xsl:for-each>
            </named-info>
         </xsl:for-each>
      </page>
   </xsl:template>

</xsl:stylesheet>
