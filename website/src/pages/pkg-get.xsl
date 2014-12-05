<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pkg="http://expath.org/ns/pkg"
                version="2.0">

   <pkg:import-uri>##none</pkg:import-uri>

   <xsl:template match="/no-such-package">
      <page menu="pkg" http-code="404" http-message="Not Found">
         <title>Not found</title>
         <para>
            <xsl:text>Package not found, with ID = </xsl:text>
            <link uri="../{ repo }">
               <xsl:value-of select="repo"/>
            </link>
            <xsl:text> / </xsl:text>
            <bold>
               <link uri="../{ repo }/{ abbrev }">
                  <xsl:value-of select="abbrev"/>
               </link>
            </bold>
            <xsl:text>.</xsl:text>
         </para>
      </page>
   </xsl:template>

   <xsl:template match="/pkg">
      <!-- the version elements, sorted descendently -->
      <xsl:variable name="versions" as="element(version)+">
         <xsl:perform-sort select="version">
            <xsl:sort select="@id" order="descending"/>
         </xsl:perform-sort>
      </xsl:variable>
      <page menu="pkg">
         <title>
            <xsl:value-of select="@id"/>
         </title>
         <xsl:if test="exists(abstract)">
            <para>
               <xsl:value-of select="abstract"/>
            </para>
         </xsl:if>
         <named-info>
            <row>
               <name>ID</name>
               <info>
                  <xsl:value-of select="@id"/>
               </info>
            </row>
            <row>
               <name>Name</name>
               <info>
                  <xsl:value-of select="name"/>
               </info>
            </row>
            <row>
               <name>Repository</name>
               <info>
                  <link uri="../{ @repo }">
                     <xsl:value-of select="@repo"/>
                  </link>
               </info>
            </row>
            <xsl:if test="exists(title)">
               <row>
                  <name>Title</name>
                  <info>
                     <xsl:value-of select="title"/>
                  </info>
               </row>
            </xsl:if>
            <xsl:if test="exists(home)">
               <row>
                  <name>Home</name>
                  <info>
                     <link uri="{ home }">
                        <xsl:value-of select="home"/>
                     </link>
                  </info>
               </row>
            </xsl:if>
            <xsl:if test="exists(author)">
               <row>
                  <name>Author</name>
                  <info>
                     <xsl:for-each select="author">
                        <xsl:choose>
                           <xsl:when test="exists(@id)">
                              <link uri="../../author/{ @id }">
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
            <xsl:if test="exists(maintainer)">
               <row>
                  <name>Package maintainer</name>
                  <info>
                     <xsl:for-each select="maintainer">
                        <xsl:choose>
                           <xsl:when test="exists(@id)">
                              <link uri="../../author/{ @id }">
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
            <xsl:if test="exists(category)">
               <row>
                  <name>Categories</name>
                  <info>
                     <xsl:for-each select="category">
                        <link uri="../../cat/{ @id }">
                           <xsl:value-of select="."/>
                        </link>
                        <xsl:if test="position() ne last()">
                           <xsl:text>, </xsl:text>
                        </xsl:if>
                     </xsl:for-each>
                  </info>
               </row>
            </xsl:if>
            <xsl:if test="exists(tag)">
               <row>
                  <name>Tags</name>
                  <info>
                     <xsl:for-each select="tag">
                        <link uri="../../tag/{ . }">
                           <xsl:value-of select="."/>
                        </link>
                        <xsl:if test="position() ne last()">
                           <xsl:text>, </xsl:text>
                        </xsl:if>
                     </xsl:for-each>
                  </info>
               </row>
            </xsl:if>
         </named-info>
         <xsl:for-each select="version">
            <!-- TODO: Sort not as a string, but as a SemVer instead. -->
            <xsl:sort select="@id" order="descending"/>
            <xsl:variable name="ver" select="@num"/>
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
                     <name>
                        <xsl:choose>
                           <xsl:when test="@role eq 'pkg'">Package</xsl:when>
                           <xsl:when test="@role eq 'archive'">Archive</xsl:when>
                           <xsl:otherwise>File</xsl:otherwise>
                        </xsl:choose>
                     </name>
                     <info>
                        <link uri="../../file/{ ../../@id }/{ @name }">
                           <xsl:value-of select="@name"/>
                        </link>
                     </info>
                  </row>
               </xsl:for-each>
               <xsl:for-each select="dependency">
                  <!-- TODO: Handle different kind of dependencies (on processors,
                       with specific versions, etc.) -->
                  <row>
                     <name>Dependency</name>
                     <info>
                        <xsl:choose>
                           <xsl:when test="exists(@package)">
                              <link uri="../../pkg?name={ encode-for-uri(@package) }">
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
