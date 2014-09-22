<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pxp="http://exproc.org/proposed/steps"
                xmlns:my="investigate.xsl#impl"
                version="1.0">

   <!--
      "investigate.xproc", because it gathers information from the repository
      and store it in a denormalized file at the root of it: packages.xml.
   -->

   <p:option name="repo-dir" required="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>The directory for the repository to investigate.</p>
         <p>It must be an absolute URI. So for a human being to invoke this pipeline,
            the best solution is to use a wrapper shell script.</p>
      </p:documentation>
   </p:option>

   <p:output port="result"/>

   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

   <!-- return the package directories -->
   <p:directory-list>
      <p:with-option name="path" select="$repo-dir"/>
   </p:directory-list>

   <!-- TODO: Generate an error if there is any file at this level! -->
   <!--p:delete match="c:file"/-->

   <!-- return the version directories -->
   <p:viewport match="/c:directory/c:directory">
      <!--p:template>
         <p:input port="template">
            <p:inline>
               <root>
                  <base>{ $base }</base>
                  <name>{ $name }</name>
                  <uri>{ $uri }</uri>
               </root>
            </p:inline>
         </p:input>
         <p:with-param name="base" select="base-uri(.)"/>
         <p:with-param name="name" select="/c:directory/@name"/>
         <p:with-param name="uri"  select="resolve-uri(/c:directory/@name, base-uri(.))"/>
         <p:log port="result" href="/tmp/yoyoyo"/>
      </p:template>
      <p:sink/-->
      <p:directory-list>
         <p:with-option name="path" select="resolve-uri(/c:directory/@name, base-uri(.))"/>
      </p:directory-list>
   </p:viewport>

   <!-- ignoring files at the package level -->
   <p:delete match="c:file"/>

   <!-- return the version directories content -->
   <p:viewport match="/c:directory/c:directory/c:directory">
      <p:directory-list>
         <p:with-option name="path" select="resolve-uri(/c:directory/@name, base-uri(.))"/>
      </p:directory-list>
   </p:viewport>

   <!--
      TODO: Would probably way easier to resolve each "file" @name to an absolute @href...
      Once for all...
   -->

   <!-- TODO: Put the stylesheet outside the pipeline. -->
   <p:xslt name="xslt">
      <p:input port="stylesheet">
         <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            xmlns:xs="http://www.w3.org/2001/XMLSchema"
                            version="2.0">
               <xsl:function name="my:parse-semver" as="item()+">
                  <xsl:param name="in" as="xs:string"/>
                  <xsl:sequence select="xs:integer(substring-before($in, '.'))"/>
                  <xsl:sequence select="my:after-major(substring-after($in, '.'))"/>
               </xsl:function>
               <xsl:function name="my:after-major" as="item()+">
                  <xsl:param name="in" as="xs:string"/>
                  <xsl:choose>
                     <!-- support 1.2.3... -->
                     <xsl:when test="contains($in, '.')">
                        <xsl:sequence select="xs:integer(substring-before($in, '.'))"/>
                        <xsl:sequence select="my:after-minor(substring-after($in, '.'))"/>
                     </xsl:when>
                     <!-- support 1.2 -->
                     <xsl:otherwise>
                        <xsl:sequence select="xs:integer($in)"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:function>
               <xsl:function name="my:after-minor" as="item()+">
                  <xsl:param name="in" as="xs:string"/>
                  <xsl:choose>
                     <!-- support 1.2.3-pre+build -->
                     <xsl:when test="contains($in, '-') and contains($in, '+')">
                        <xsl:sequence select="xs:integer(substring-before($in, '-'))"/>
                        <xsl:sequence select="substring-before(substring-after($in, '-'), '+')"/>
                        <xsl:sequence select="substring-after($in, '+')"/>
                     </xsl:when>
                     <!-- support 1.2.3-pre -->
                     <xsl:when test="contains($in, '-')">
                        <xsl:sequence select="xs:integer(substring-before($in, '-'))"/>
                        <xsl:sequence select="substring-after($in, '-')"/>
                        <xsl:sequence select="''"/>
                     </xsl:when>
                     <!-- support 1.2.3+build -->
                     <xsl:when test="contains($in, '+')">
                        <xsl:sequence select="xs:integer(substring-before($in, '+'))"/>
                        <xsl:sequence select="''"/>
                        <xsl:sequence select="substring-after($in, '+')"/>
                     </xsl:when>
                     <!-- support 1.2.3pre -->
                     <xsl:when test="translate($in, '0123456789', '')">
                        <xsl:variable name="num" select="replace($in, '^([0-9]+).+$', '$1')"/>
                        <xsl:sequence select="xs:integer($num)"/>
                        <xsl:sequence select="substring($in, string-length($num))"/>
                        <xsl:sequence select="''"/>
                     </xsl:when>
                     <!-- support 1.2.3 -->
                     <xsl:otherwise>
                        <xsl:sequence select="xs:integer($in)"/>
                        <xsl:sequence select="''"/>
                        <xsl:sequence select="''"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:function>
               <xsl:template match="/c:directory">
                  <repo>
                     <xsl:copy-of select="@xml:base"/>
                     <xsl:for-each select="c:directory">
                        <pkg id="{ @name }">
                           <xsl:for-each select="c:directory">
                              <!-- TODO: Parse 6 times each semver number. Simplify! -->
                              <xsl:sort select="my:parse-semver(@name)[1]"/>
                              <xsl:sort select="my:parse-semver(@name)[2]"/>
                              <xsl:sort select="my:parse-semver(@name)[3]"/>
                              <xsl:sort select="my:parse-semver(@name)[4]"/>
                              <xsl:sort select="my:parse-semver(@name)[5]"/>
                              <xsl:sort select="my:parse-semver(@name)[6]"/>
                              <version num="{ @name }">
                                 <xsl:if test="exists(c:directory)">
                                    <xsl:message terminate="yes">
                                       <xsl:text>Directories not allowed in version-level directories:</xsl:text>
                                       <xsl:for-each select="c:directory">
                                          <xsl:text>&#10;  </xsl:text>
                                          <xsl:value-of select="../../../@name"/>
                                          <xsl:text>/</xsl:text>
                                          <xsl:value-of select="../../@name"/>
                                          <xsl:text>/</xsl:text>
                                          <xsl:value-of select="../@name"/>
                                          <xsl:text>/</xsl:text>
                                          <xsl:value-of select="@name"/>
                                       </xsl:for-each>
                                    </xsl:message>
                                 </xsl:if>
                                 <xsl:for-each select="c:file">
                                    <file name="{ @name }">
                                       <!-- add role="pkg" on *.xar and *.xaw files -->
                                       <!--  TODO: Validate there is exactly 1 for each version.-->
                                       <xsl:if test="ends-with(@name, '.xar') or ends-with(@name, '.xaw')">
                                          <xsl:attribute name="role" select="'pkg'"/>
                                       </xsl:if>
                                    </file>
                                 </xsl:for-each>
                              </version>
                           </xsl:for-each>
                        </pkg>
                     </xsl:for-each>
                  </repo>
               </xsl:template>
            </xsl:stylesheet>
         </p:inline>
      </p:input>
      <p:input port="parameters">
         <p:empty/>
      </p:input>
   </p:xslt>

   <!--
      For each "pkg", get cxan.xml, and copy all elements as first children of
      "pkg" (right before "version" elements).  The file "cxan.xml" is optional.
   -->

   <p:viewport match="/repo/pkg" name="pkg-1">
      <p:variable name="path" select="concat(/pkg/@id, '/', /pkg/version[last()]/@num, '/', /pkg/version[last()]/file[@role eq 'pkg']/@name)"/>
      <p:try>
         <p:group>
            <pxp:unzip file="cxan.xml">
               <p:with-option name="href" select="resolve-uri($path, base-uri(.))"/>
            </pxp:unzip>
            <p:namespace-rename from="http://cxan.org/ns/package" to="" name="cxan"/>
            <!-- TODO: Double-check that {cxan}/cp:package/@id matches {pkg}/pkg/@id. -->
            <p:insert position="first-child" match="/pkg">
               <p:input port="source">
                  <p:pipe port="current" step="pkg-1"/>
               </p:input>
               <p:input port="insertion" select="/*/*">
                  <p:pipe port="result" step="cxan"/>
               </p:input>
            </p:insert>
         </p:group>
         <p:catch name="catch">
            <!-- TODO: Check we catch only the pxp:unzip's "does not exist" error. -->
            <p:identity>
               <p:input port="source">
                  <p:pipe port="current" step="pkg-1"/>
               </p:input>
            </p:identity>
         </p:catch>
      </p:try>
   </p:viewport>

   <!--
      For each "pkg", get expath-pkg.xml, and add "name" as first child of "pkg"
      (right before elements from cxan.xml).  And for each of its "pkg/version",
      add the "dependency" elements.

      TODO: Double-check that the names are the same in all expath-pkg.xml files?
   -->

   <p:viewport match="/repo/pkg" name="pkg-2">
      <p:variable name="pkg-id" select="/pkg/@id"/>
      <p:variable name="path"   select="concat($pkg-id, '/', /pkg/version[last()]/@num, '/', /pkg/version[last()]/file[@role eq 'pkg']/@name)"/>
      <pxp:unzip file="expath-pkg.xml">
         <p:with-option name="href" select="resolve-uri($path, base-uri(.))"/>
      </pxp:unzip>
      <!-- create the "name" element -->
      <p:template name="name">
         <p:input port="template">
            <p:inline>
               <name>{ $name }</name>
            </p:inline>
         </p:input>
         <p:with-param name="name" select="/*/@name"/>
      </p:template>
      <!-- insert the "name" element -->
      <p:insert position="first-child" match="/pkg">
         <p:input port="source">
            <p:pipe port="current" step="pkg-2"/>
         </p:input>
         <p:input port="insertion">
            <p:pipe port="result" step="name"/>
         </p:input>
      </p:insert>
      <p:viewport match="/pkg/version" name="pkg-3">
         <p:variable name="path" select="concat($pkg-id, '/', /version/@num, '/', /version/file[@role eq 'pkg']/@name)"/>
         <pxp:unzip file="expath-pkg.xml">
            <p:with-option name="href" select="resolve-uri($path, base-uri(.))"/>
         </pxp:unzip>
         <p:namespace-rename from="http://expath.org/ns/pkg" to="" name="desc"/>
         <!-- insert the "dependency" elements -->
         <p:insert position="first-child" match="/version">
            <p:input port="source">
               <p:pipe port="current" step="pkg-3"/>
            </p:input>
            <p:input port="insertion" select="/*/dependency">
               <p:pipe port="result" step="desc"/>
            </p:input>
         </p:insert>
      </p:viewport>
   </p:viewport>

</p:declare-step>
