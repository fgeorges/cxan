<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:my="check-sanity.xproc#impl"
                version="1.0"
                exclude-inline-prefixes="my"
                name="pipeline">

   <!--
      Sanity checks for one repository:

      - repo dir exists
      - contains /packages.xml
      - /packages.xml is valid against repo.xsd
      - there is a file with role=pkg for each version
      - all authors in /packages.xml exist in authors.xml
      - all categories in /packages.xml exist in categories.xml
      - there is a dir /{id}/ for each pkg
      - there is a dir /{id}/{num}/ for each version
      - there is a file /{id}/{num}/{name} for each file
      
      If one of the first 3 rules is not valid, no further check is done.  All
      other rules are checked together, regardless of some being invalid.
      
      Example of the result XML report:
      
      <sanity pass="true">
         <rule name="repo-dir" pass="true">
            <title>Repo dir exist</title>
            <msg>The directory /.../myrepo/ exists.</msg>
         </rule>
         <rule name="descriptor" pass="true">
            <title>Contains packages.xml</title>
            <msg>The repository /.../myrepo/ contains /.../myrepo/packages.xml.</msg>
         </rule>
         <rule name="valid" pass="true">
            <title>packages.xml is valid</title>
            <msg>The file /.../myrepo/packages.xml is valid against /.../repo.xsd.</msg>
         </rule>
         <rule name="version-pkg" pass="false">
            <title>One package per version</title>
            <msg>The file /.../myrepo/packages.xml does not have exactly one package file
               per package version.  Package "fxsl", version "1.0" has no package file.
               Package "foobar", version 2.4.0 has 2 package files.</msg>
            <pkg id="fxsl" version="1.0" count="0"/>
            <pkg id="foobar" version="2.4.0" count="2">
               <file name="foobar-2.4.0.xar" role="pkg"/>
               <file name="foobar-2.4.0.zip" role="pkg"/>
            </pkg>
         </rule>
         ...
      </sanity>
   -->

   <p:option name="repo-dir" required="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>The directory for the repository to check.</p>
         <p>It must be an absolute URI, must starts with "file:/" and must ends with a slash. So for
            a human being to invoke this pipeline, the best solution is to use a wrapper shell
            script.</p>
      </p:documentation>
   </p:option>

   <p:input port="authors"/>
   <p:input port="categories"/>
   <p:output port="result"/>

   <p:serialization port="result" indent="true"/>

   <p:declare-step type="my:insert-rule" name="this">
      <p:input  port="source" primary="true"/>
      <p:input  port="report"/>
      <p:output port="result" primary="true"/>
      <!-- did the rule pass? -->
      <p:variable name="pass" select="/rule/@pass"/>
      <!-- insert the rule in the sanity report -->
      <p:insert match="/sanity" position="last-child">
         <p:input port="source">
            <p:pipe port="report" step="this"/>
         </p:input>
         <p:input port="insertion">
            <p:pipe port="source" step="this"/>
         </p:input>
      </p:insert>
      <!-- update /sanity/@pass if the rule failed -->
      <p:choose>
         <p:when test="exists($pass[.]) and xs:boolean($pass)">
            <p:identity/>
         </p:when>
         <p:otherwise>
            <p:add-attribute match="/sanity" attribute-name="pass" attribute-value="false"/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

   <p:declare-step type="my:repo-exists" name="this">
      <p:option name="dir" required="true"/>
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <!-- trying to list dir content -->
      <p:try>
         <p:group>
            <p:directory-list exclude-filter=".+">
               <p:with-option name="path" select="$dir"/>
            </p:directory-list>
         </p:group>
         <p:catch>
            <p:identity>
               <p:input port="source">
                  <p:inline>
                     <does-not-exist/>
                  </p:inline>
               </p:input>
            </p:identity>
         </p:catch>
      </p:try>
      <!-- the rule itself -->
      <p:template name="rule">
         <p:with-param name="dir"  select="$dir"/>
         <p:with-param name="pass" select="empty(/does-not-exist)"/>
         <p:input port="template">
            <p:inline>
               <rule name="repo-dir" pass="{ $pass }">
                  <title>Repo dir exist</title>
                  <msg>The directory { $dir } { if ( xs:boolean($pass) ) then 'exists' else 'does not exist' }.</msg>
                  <repo>{ $dir }</repo>
               </rule>
            </p:inline>
         </p:input>
      </p:template>
      <!-- insert the rule in the sanity report -->
      <my:insert-rule>
         <p:input port="report">
            <p:pipe port="source" step="this"/>
         </p:input>
      </my:insert-rule>
   </p:declare-step>

   <p:declare-step type="my:contains-packages-xml" name="this">
      <p:option name="dir"  required="true"/>
      <p:option name="file" required="true"/>
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:choose>
         <p:when test="/sanity/xs:boolean(@pass)">
            <!-- the rule itself -->
            <p:template name="rule">
               <p:with-param name="dir"  select="$dir"/>
               <p:with-param name="file" select="$file"/>
               <p:with-param name="pass" select="doc-available($file)"/>
               <p:input port="source">
                  <p:empty/>
               </p:input>
               <p:input port="template">
                  <p:inline>
                     <rule name="descriptor" pass="{ $pass }">
                        <title>Contains packages.xml</title>
                        <msg>The repository { $dir } { if ( xs:boolean($pass) ) then 'contains' else 'does not contain' } { $file }.</msg>
                        <repo>{ $dir }</repo>
                        <packages>{ $file }</packages>
                     </rule>
                  </p:inline>
               </p:input>
            </p:template>
            <!-- insert the rule in the sanity report -->
            <my:insert-rule>
               <p:input port="report">
                  <p:pipe port="source" step="this"/>
               </p:input>
            </my:insert-rule>
         </p:when>
         <p:otherwise>
            <p:identity/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

   <p:declare-step type="my:packages-xml-valid" name="this">
      <p:input  port="source" primary="true"/>
      <p:input  port="packages"/>
      <p:output port="result" primary="true"/>
      <p:choose>
         <p:when test="/sanity/xs:boolean(@pass)">
            <!-- trying to validate -->
            <p:try>
               <p:group>
                  <p:validate-with-xml-schema>
                     <p:input port="source">
                        <p:pipe port="packages" step="this"/>
                     </p:input>
                     <p:input port="schema">
                        <p:document href="repo.xsd"/>
                     </p:input>
                  </p:validate-with-xml-schema>
               </p:group>
               <p:catch name="catch">
                  <p:identity>
                     <p:input port="source">
                        <p:pipe port="error" step="catch"/>
                     </p:input>
                  </p:identity>
               </p:catch>
            </p:try>
            <p:identity name="try"/>
            <!-- the rule itself -->
            <p:choose>
               <p:when test="exists(/c:errors)">
                  <p:identity>
                     <p:input port="source">
                        <p:inline>
                           <rule name="valid" pass="false">
                              <title>packages.xml is valid</title>
                              <msg>The file packages.xml is not valid against repo.xsd.</msg>
                           </rule>
                        </p:inline>
                     </p:input>
                  </p:identity>
                  <p:insert match="/rule" position="last-child">
                     <p:input port="insertion">
                        <p:pipe port="result" step="try"/>
                     </p:input>
                  </p:insert>
               </p:when>
               <p:otherwise>
                  <p:identity>
                     <p:input port="source">
                        <p:inline>
                           <rule name="valid" pass="true">
                              <title>packages.xml is valid</title>
                              <msg>The file packages.xml is valid against repo.xsd.</msg>
                           </rule>
                        </p:inline>
                     </p:input>
                  </p:identity>
               </p:otherwise>
            </p:choose>
            <!-- insert the rule in the sanity report -->
            <my:insert-rule>
               <p:input port="report">
                  <p:pipe port="source" step="this"/>
               </p:input>
            </my:insert-rule>
         </p:when>
         <p:otherwise>
            <p:identity/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

   <p:declare-step type="my:pkg-for-each-version" name="this">
      <p:input  port="source" primary="true"/>
      <p:input  port="packages"/>
      <p:output port="result" primary="true"/>
      <!-- the checks and the rule generation all in one stylesheet -->
      <p:xslt>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
         <p:input port="source">
            <p:pipe port="packages" step="this"/>
         </p:input>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                  <xsl:template match="/">
                     <xsl:variable name="wrong" as="element(version)*" select="
                        repo/pkg/version[count(file[@role eq 'pkg']) ne 1]"/>
                     <xsl:choose>
                        <xsl:when test="empty($wrong)">
                           <xsl:apply-templates select="repo" mode="pass"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:apply-templates select="repo" mode="fail">
                              <xsl:with-param name="wrong" select="$wrong"/>
                           </xsl:apply-templates>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:template>
                  <xsl:template match="repo" mode="pass">
                     <rule name="version-pkg" pass="true">
                        <title>One package per version</title>
                        <msg>The file packages.xml contains one package file per package version.</msg>
                     </rule>
                  </xsl:template>
                  <xsl:template match="repo" mode="fail">
                     <xsl:param name="wrong" as="element(version)+"/>
                     <rule name="version-pkg" pass="false">
                        <title>One package per version</title>
                        <msg>
                           <xsl:text>The file packages.xml does not contain exactly one package file per package version.</xsl:text>
                           <xsl:apply-templates select="$wrong" mode="msg"/>
                        </msg>
                        <xsl:apply-templates select="$wrong" mode="info"/>
                     </rule>
                  </xsl:template>
                  <xsl:template match="version" mode="msg">
                     <xsl:text>  </xsl:text>
                     <xsl:variable name="pkg" select="file[@role eq 'pkg']"/>
                     <xsl:variable name="cnt" select="count($pkg)"/>
                     <xsl:variable name="num" select="
                        if ( $cnt eq 0 ) then 'no package file' else concat($cnt, ' package files')"/>
                     <xsl:sequence select="
                        concat('Package ', ../@id, ' version ', @num, ' has ', $num, '.')"/>
                  </xsl:template>
                  <xsl:template match="version" mode="info">
                     <xsl:variable name="pkg" select="file[@role eq 'pkg']"/>
                     <pkg id="{ ../@id }" version="{ @num }" count="{ count($pkg) }">
                        <xsl:copy-of select="$pkg"/>
                     </pkg>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
      <!-- insert the resulting rule in the report -->
      <my:insert-rule>
         <p:input port="report">
            <p:pipe port="source" step="this"/>
         </p:input>
      </my:insert-rule>
   </p:declare-step>

   <p:declare-step type="my:authors-exist" name="this">
      <p:input  port="source" primary="true"/>
      <p:input  port="packages"/>
      <p:input  port="authors"/>
      <p:output port="result" primary="true"/>
      <!-- the checks and the rule generation all in one stylesheet -->
      <p:xslt>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
         <p:input port="source">
            <p:pipe port="packages" step="this"/>
            <p:pipe port="authors"  step="this"/>
         </p:input>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                  <xsl:variable name="packages" as="element(repo)"    select="collection()[1]/*"/>
                  <xsl:variable name="authors"  as="element(authors)" select="collection()[2]/*"/>
                  <xsl:template match="/">
                     <xsl:variable name="wrong" select="$packages/pkg[(author|maintainer)[not(@id = $authors/author/@id)]]"/>
                     <xsl:choose>
                        <xsl:when test="empty($wrong)">
                           <xsl:apply-templates select="$packages" mode="pass"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:apply-templates select="$packages" mode="fail">
                              <xsl:with-param name="wrong" select="$wrong"/>
                           </xsl:apply-templates>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:template>
                  <xsl:template match="repo" mode="pass">
                     <rule name="author" pass="true">
                        <title>Authors must exist</title>
                        <msg>The file packages.xml contains only existing authors.</msg>
                     </rule>
                  </xsl:template>
                  <xsl:template match="repo" mode="fail">
                     <xsl:param name="wrong" as="element(pkg)+"/>
                     <rule name="author" pass="false">
                        <title>Authors must exist</title>
                        <msg>
                           <xsl:text>The file packages.xml contains non-existing authors.</xsl:text>
                           <xsl:apply-templates select="$wrong" mode="msg"/>
                        </msg>
                        <xsl:apply-templates select="$wrong" mode="info"/>
                     </rule>
                  </xsl:template>
                  <xsl:template match="pkg" mode="msg">
                     <xsl:text>  </xsl:text>
                     <xsl:variable name="auth" select="(author|maintainer)[not(@id = $authors/author/@id)]"/>
                     <xsl:sequence select="
                        concat('Package ', @id, ' references author(s) ', string-join($auth/@id, ', '), '.')"/>
                  </xsl:template>
                  <xsl:template match="pkg" mode="info">
                     <xsl:variable name="auth" select="(author|maintainer)[not(@id = $authors/author/@id)]"/>
                     <pkg id="{ @id }">
                        <xsl:copy-of select="$auth"/>
                     </pkg>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
      <!-- insert the resulting rule in the report -->
      <my:insert-rule>
         <p:input port="report">
            <p:pipe port="source" step="this"/>
         </p:input>
      </my:insert-rule>
   </p:declare-step>

   <p:declare-step type="my:categories-exist" name="this">
      <p:input  port="source" primary="true"/>
      <p:input  port="packages"/>
      <p:input  port="categories"/>
      <p:output port="result" primary="true"/>
      <!-- the checks and the rule generation all in one stylesheet -->
      <p:xslt>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
         <p:input port="source">
            <p:pipe port="packages"   step="this"/>
            <p:pipe port="categories" step="this"/>
         </p:input>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                  <xsl:variable name="packages"   as="element(repo)"       select="collection()[1]/*"/>
                  <xsl:variable name="categories" as="element(categories)" select="collection()[2]/*"/>
                  <xsl:template match="/">
                     <xsl:variable name="wrong" select="$packages/pkg[category[not(@id = $categories//cat/@id)]]"/>
                     <xsl:choose>
                        <xsl:when test="empty($wrong)">
                           <xsl:apply-templates select="$packages" mode="pass"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:apply-templates select="$packages" mode="fail">
                              <xsl:with-param name="wrong" select="$wrong"/>
                           </xsl:apply-templates>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:template>
                  <xsl:template match="repo" mode="pass">
                     <rule name="categories" pass="true">
                        <title>Categories must exist</title>
                        <msg>The file packages.xml contains only existing categories.</msg>
                     </rule>
                  </xsl:template>
                  <xsl:template match="repo" mode="fail">
                     <xsl:param name="wrong" as="element(pkg)+"/>
                     <rule name="categories" pass="false">
                        <title>Categories must exist</title>
                        <msg>
                           <xsl:text>The file packages.xml contains non-existing categories.</xsl:text>
                           <xsl:apply-templates select="$wrong" mode="msg"/>
                        </msg>
                        <xsl:apply-templates select="$wrong" mode="info"/>
                     </rule>
                  </xsl:template>
                  <xsl:template match="pkg" mode="msg">
                     <xsl:text>  </xsl:text>
                     <xsl:variable name="cats" select="category[not(@id = $categories//cat/@id)]"/>
                     <xsl:sequence select="
                        concat('Package ', @id, ' references category(-ies) ', string-join($cats/@id, ', '), '.')"/>
                  </xsl:template>
                  <xsl:template match="pkg" mode="info">
                     <xsl:variable name="cats" select="category[not(@id = $categories//cat/@id)]"/>
                     <pkg id="{ @id }">
                        <xsl:copy-of select="$cats"/>
                     </pkg>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
      <!-- insert the resulting rule in the report -->
      <my:insert-rule>
         <p:input port="report">
            <p:pipe port="source" step="this"/>
         </p:input>
      </my:insert-rule>
   </p:declare-step>

   <p:declare-step type="my:expand-directory" name="this">
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:variable name="href" select="resolve-uri(/c:directory/@name/concat(., '/'), base-uri(/*))"/>
      <p:directory-list>
         <p:with-option name="path" select="$href"/>
      </p:directory-list>
      <p:viewport match="/c:directory/c:directory">
         <my:expand-directory/>
      </p:viewport>
   </p:declare-step>

   <p:declare-step type="my:files-exist" name="this">
      <p:option name="dir" required="true"/>
      <p:input  port="source" primary="true"/>
      <p:input  port="packages"/>
      <p:output port="result" primary="true"/>
      <!-- listing the entire repo structure -->
      <p:directory-list include-filter="[a-z][a-z0-9]*(-[a-z0-9]+)*">
         <p:with-option name="path" select="$dir"/>
      </p:directory-list>
      <p:delete match="/c:directory/c:file"/>
      <p:viewport match="/c:directory/c:directory" name="dirs">
         <my:expand-directory/>
      </p:viewport>
      <!-- the checks and the rule generation all in one stylesheet -->
      <p:xslt>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
         <p:input port="source">
            <p:pipe port="packages" step="this"/>
            <p:pipe port="result"   step="dirs"/>
         </p:input>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                  <xsl:variable name="packages"  as="element(repo)"        select="collection()[1]/*"/>
                  <xsl:variable name="directory" as="element(c:directory)" select="collection()[2]/*"/>
                  <xsl:template match="/">
                     <xsl:variable name="wrong" as="element()*">
                        <xsl:apply-templates select="repo" mode="check">
                           <xsl:with-param name="dir" select="$directory"/>
                        </xsl:apply-templates>
                     </xsl:variable>
                     <xsl:choose>
                        <xsl:when test="empty($wrong)">
                           <xsl:apply-templates select="$packages" mode="pass"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:apply-templates select="$packages" mode="fail">
                              <xsl:with-param name="wrong" select="$wrong"/>
                           </xsl:apply-templates>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:template>
                  <xsl:template match="repo" mode="check">
                     <xsl:param name="dir" as="element(c:directory)"/>
                     <xsl:for-each select="pkg">
                        <xsl:variable name="p" select="@id"/>
                        <xsl:variable name="d" select="$dir/c:directory[@name eq $p]"/>
                        <xsl:choose>
                           <xsl:when test="exists($d)">
                              <xsl:apply-templates select="." mode="check">
                                 <xsl:with-param name="dir" select="$d"/>
                              </xsl:apply-templates>
                           </xsl:when>
                           <xsl:otherwise>
                              <pkg id="{ $p }"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:for-each>
                  </xsl:template>
                  <xsl:template match="pkg" mode="check">
                     <xsl:param name="dir" as="element(c:directory)"/>
                     <xsl:for-each select="version">
                        <xsl:variable name="v" select="@num"/>
                        <xsl:variable name="d" select="$dir/c:directory[@name eq $v]"/>
                        <xsl:choose>
                           <xsl:when test="exists($d)">
                              <xsl:apply-templates select="." mode="check">
                                 <xsl:with-param name="dir" select="$d"/>
                              </xsl:apply-templates>
                           </xsl:when>
                           <xsl:otherwise>
                              <version num="{ $v }" pkg="{ ../@id }"/>
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:for-each>
                  </xsl:template>
                  <xsl:template match="version" mode="check">
                     <xsl:param name="dir" as="element(c:directory)"/>
                     <xsl:for-each select="file">
                        <xsl:variable name="name" select="@name"/>
                        <xsl:variable name="file" select="$dir/c:file[@name eq $name]"/>
                        <xsl:if test="empty($file)">
                           <file name="{ $name }" version="{ ../@num }" pkg="{ ../../@id }"/>
                        </xsl:if>
                     </xsl:for-each>
                  </xsl:template>
                  <xsl:template match="repo" mode="pass">
                     <rule name="files" pass="true">
                        <title>Directories and files must exist</title>
                        <msg>All directories (corresponding to pkg/@id and version/@num) and files referenced from packages.xml exist.</msg>
                     </rule>
                  </xsl:template>
                  <xsl:template match="repo" mode="fail">
                     <xsl:param name="wrong" as="element()+"/>
                     <rule name="files" pass="false">
                        <title>Directories and files must exist</title>
                        <msg>
                           <xsl:text>Some directories (corresponding to pkg/@id and version/@num) and/or files referenced from packages.xml do not exist.</xsl:text>
                           <xsl:apply-templates select="$wrong" mode="msg"/>
                        </msg>
                        <xsl:copy-of select="$wrong"/>
                     </rule>
                  </xsl:template>
                  <xsl:template match="pkg" mode="msg">
                     <xsl:text>  There is no package directory </xsl:text>
                     <xsl:value-of select="@id"/>
                     <xsl:text>.</xsl:text>
                  </xsl:template>
                  <xsl:template match="version" mode="msg">
                     <xsl:text>  There is no version directory </xsl:text>
                     <xsl:value-of select="@pkg"/>
                     <xsl:text>/</xsl:text>
                     <xsl:value-of select="@num"/>
                     <xsl:text>.</xsl:text>
                  </xsl:template>
                  <xsl:template match="file" mode="msg">
                     <xsl:text>  There is no file </xsl:text>
                     <xsl:value-of select="@pkg"/>
                     <xsl:text>/</xsl:text>
                     <xsl:value-of select="@version"/>
                     <xsl:text>/</xsl:text>
                     <xsl:value-of select="@name"/>
                     <xsl:text>.</xsl:text>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
      <!-- insert the resulting rule in the report -->
      <my:insert-rule>
         <p:input port="report">
            <p:pipe port="source" step="this"/>
         </p:input>
      </my:insert-rule>
   </p:declare-step>

   <!-- TODO: Merge with my:files-exist? -->
   <!-- TODO: Should we really impose anything here? -->
   <!--p:declare-step type="my:files-naming-scheme" name="this">
      <p:input  port="source" primary="true"/>
      <p:input  port="packages"/>
      <p:output port="result" primary="true"/>
      <my:insert-rule>
         <p:input port="report">
            <p:pipe port="source" step="this"/>
         </p:input>
         <p:input port="source">
            <p:inline>
               <rule pass="true">
                  <msg>TODO: IMPLEMENT ME!</msg>
               </rule>
            </p:inline>
         </p:input>
      </my:insert-rule>
   </p:declare-step-->

   <p:declare-step type="my:main" name="this">
      <p:option name="dir" required="true"/>
      <p:input  port="authors"/>
      <p:input  port="categories"/>
      <p:output port="result" primary="true"/>
      <p:variable name="file" select="resolve-uri('packages.xml', $dir)"/>
      <!-- packages.xml, for steps needing it -->
      <p:load name="packages">
         <p:with-option name="href" select="$file"/>
      </p:load>
      <!-- generate an empty, passing report -->
      <p:identity>
         <p:input port="source">
            <p:inline>
               <sanity pass="true"/>
            </p:inline>
         </p:input>
      </p:identity>
      <!-- call the 3 stopper rules, they check for passing internally -->
      <my:repo-exists>
         <p:with-option name="dir" select="$dir"/>
      </my:repo-exists>
      <my:contains-packages-xml>
         <p:with-option name="dir"  select="$dir"/>
         <p:with-option name="file" select="$file"/>
      </my:contains-packages-xml>
      <my:packages-xml-valid>
         <p:input port="packages">
            <p:pipe port="result" step="packages"/>
         </p:input>
      </my:packages-xml-valid>
      <!-- if still passing here, we apply remaining rules, don't worry whether each pass or fail -->
      <p:choose>
         <p:when test="/sanity/xs:boolean(@pass)">
            <my:pkg-for-each-version>
               <p:input port="packages">
                  <p:pipe port="result" step="packages"/>
               </p:input>
            </my:pkg-for-each-version>
            <my:authors-exist>
               <p:input port="packages">
                  <p:pipe port="result" step="packages"/>
               </p:input>
               <p:input port="authors">
                  <p:pipe port="authors" step="this"/>
               </p:input>
            </my:authors-exist>
            <my:categories-exist>
               <p:input port="packages">
                  <p:pipe port="result" step="packages"/>
               </p:input>
               <p:input port="categories">
                  <p:pipe port="categories" step="this"/>
               </p:input>
            </my:categories-exist>
            <my:files-exist>
               <p:with-option name="dir" select="$dir"/>
               <p:input port="packages">
                  <p:pipe port="result" step="packages"/>
               </p:input>
            </my:files-exist>
            <!--my:files-naming-scheme>
               <p:input port="packages">
                  <p:pipe port="result" step="packages"/>
               </p:input>
            </my:files-naming-scheme-->
         </p:when>
         <p:otherwise>
            <p:identity/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

   <my:main>
      <p:with-option name="dir" select="$repo-dir"/>
      <p:input port="authors">
         <p:pipe port="authors" step="pipeline"/>
      </p:input>
      <p:input port="categories">
         <p:pipe port="categories" step="pipeline"/>
      </p:input>
   </my:main>

</p:declare-step>
