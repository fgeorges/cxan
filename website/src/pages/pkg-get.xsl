<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:ser="http://fgeorges.org/xslt/serial"
                xmlns:web="http://expath.org/ns/webapp"
                exclude-result-prefixes="xs c pkg ser web"
                version="2.0">

   <xsl:import href="http://fgeorges.org/ns/xslt/serial.xsl"/>
   <xsl:import href="http://fgeorges.org/ns/xslt/serial-html.xsl"/>

   <pkg:import-uri>##none</pkg:import-uri>

   <xsl:variable name="config" as="element(c:param-set)" select="
       doc(web:config-param('config-params'))/*"/>

   <xsl:variable name="home" as="xs:string" select="
       $config/c:param[@name eq 'home-uri']/@value"/>

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
      <page menu="pkg">

         <title>
            <span class="repo">
               <xsl:value-of select="@repo"/>
               <xsl:text> / </xsl:text>
            </span>
            <span class="abbrev">
               <xsl:value-of select="@abbrev"/>
            </span>
         </title>

         <subtitle>
            <xsl:value-of select="abstract"/>
         </subtitle>
         <para>
            <xsl:variable name="latest" select="version[1]/file[@role eq 'pkg']"/>
            <xsl:if test="exists(home)">
               <button type="home" href="{ home }" info="Go to the homepage."/>
               <xsl:text> </xsl:text>
            </xsl:if>
            <button type="download"
                    href="../../file/{ @id }/{ $latest/@name }"
                    info="Download the latest XAR package, version { $latest/../@num }."/>
            <xsl:text> </xsl:text>
            <xsl:if test="exists(code)">
               <button type="code" href="{ code }" info="Go to the code repository."/>
               <xsl:text> </xsl:text>
            </xsl:if>
         </para>

         <xsl:if test="exists(desc)">
            <subtitle>Description</subtitle>
            <xsl:apply-templates select="desc"/>
         </xsl:if>

         <subtitle>Details</subtitle>
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
            <!-- Do not sort the versions, they have to be sorted in Git. -->
            <subtitle>
               <xsl:text>Version </xsl:text>
               <xsl:value-of select="@num"/>
            </subtitle>
            <xsl:apply-templates select="desc"/>
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

         <subtitle>Badge</subtitle>
         <link href="../{ @id }"><image alt="CXAN" src="../../badge/{ @id }"/></link>
         <para/>
         <para>HTML:</para>
         <xsl:variable name="code" as="element()">
            <a href="{ $home }pkg/{ @id }">
               <img alt="CXAN" src="{ $home }badge/{ @id }"/>
            </a>
         </xsl:variable>
         <code>
            <xsl:sequence select="ser:serialize-to-html($code)"/>
         </code>
         <para>Markdown:</para>
         <code>
            <xsl:text>[![CXAN](</xsl:text>
            <xsl:value-of select="$home"/>
            <xsl:text>badge/</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>)](</xsl:text>
            <xsl:value-of select="$home"/>
            <xsl:text>pkg/</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>)</xsl:text>
         </code>

      </page>
   </xsl:template>

   <xsl:template match="desc[@format eq 'text']">
      <code>
         <xsl:copy-of select="."/>
      </code>
   </xsl:template>

   <xsl:template match="desc">
      <xsl:message terminate="yes">
         <xsl:text>Description element with unsupported format: "</xsl:text>
         <xsl:value-of select="@format"/>
         <xsl:text>"</xsl:text>
      </xsl:message>
   </xsl:template>

</xsl:stylesheet>
