<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:pkg="http://expath.org/ns/pkg"
           xmlns:app="http://cxan.org/ns/website"
           xmlns:da="http://cxan.org/ns/website/data-access"
           xmlns:dir="http://cxan.org/ns/website/dir-repos"
           exclude-inline-prefixes="c pkg"
           version="1.0"
           pkg:import-uri="http://cxan.org/ns/website/data-access.xpl">

   <p:import href="dir-repos.xpl"/>

   <!--
      Repositories.
   -->

   <p:declare-step type="da:list-repositories">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return the repositories.</p>
         <p>All the repositories. The returned document is of the following format (a list of "repo"
            elements, each with mandatory "id" and "desc"):</p>
         <pre><![CDATA[
            <repositories>
               <repo>
                  <id>expath</id>
                  <desc>The EXPath project's repository.</desc>
               </repo>
               <repo>
                  <id>fgeorges</id>
                  <desc>Florent Georges's personal repository.</desc>
               </repo>
               ...
            </repositories>
         ]]></pre>
         <p><b>TODO</b>: Add support for windowing.</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <dir:get-all-repositories/>
      <p:xslt>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                  <xsl:template match="repositories">
                     <xsl:copy>
                        <xsl:apply-templates select="*"/>
                     </xsl:copy>
                  </xsl:template>
                  <xsl:template match="repo">
                     <xsl:copy>
                        <id>
                           <xsl:value-of select="@abbrev"/>
                        </id>
                        <xsl:copy-of select="desc"/>
                     </xsl:copy>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <p:declare-step type="da:packages-by-repo">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return the packages in one repository.</p>
         <p>All the packages in one given repository, passed through the option "repo". The returned
            document is of the following format (a list of "pkg" elements, each with mandatory "id"
            and "name", and an optional "desc"):</p>
         <pre><![CDATA[
            <packages repo="fgeorges">
               <pkg>
                  <id>fgeorges/functx</id>
                  <abbrev>functx</abbrev>
                  <name>http://www.functx.com</name>
                  <desc>The famous FunctX library.</desc>
               </pkg>
               <pkg>
                  <id>fgeorges/pipx</id>
                  <abbrev>pipx</abbrev>
                  <name>http://pipx.org/lib/pipx</name>
               </pkg>
               ...
            </packages>
         ]]></pre>
         <p><b>TODO</b>: Add support for windowing.</p>
      </p:documentation>
      <p:option name="repo" required="true"/>
      <p:output port="result" primary="true"/>
      <dir:repo-packages>
         <p:with-option name="repo" select="$repo"/>
      </dir:repo-packages>
      <p:rename match="/repo" new-name="packages"/>
      <p:add-attribute attribute-name="abbrev" match="/*">
         <p:with-option name="attribute-value" select="$repo"/>
      </p:add-attribute>
      <p:viewport match="/packages/pkg">
         <p:xslt>
            <p:with-param name="repo" select="$repo"/>
            <p:input port="stylesheet">
               <p:inline>
                  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                  exclude-result-prefixes="#all"
                                  version="2.0">
                     <xsl:param name="repo" required="yes"/>
                     <xsl:template match="node()">
                        <xsl:message terminate="yes">
                           ERROR - Unknown node: <xsl:copy-of select="."/>
                        </xsl:message>
                     </xsl:template>
                     <xsl:template match="/pkg">
                        <xsl:copy>
                           <id>
                              <xsl:value-of select="@id"/>
                           </id>
                           <repo>
                              <xsl:value-of select="$repo"/>
                           </repo>
                           <abbrev>
                              <xsl:value-of select="@abbrev"/>
                           </abbrev>
                           <name>
                              <xsl:value-of select="name"/>
                           </name>
                           <xsl:if test="exists(abstract)">
                              <desc>
                                 <xsl:value-of select="abstract"/>
                              </desc>
                           </xsl:if>
                        </xsl:copy>
                     </xsl:template>
                  </xsl:stylesheet>
               </p:inline>
            </p:input>
         </p:xslt>
      </p:viewport>
   </p:declare-step>

   <!--
      Packages.
   -->

   <!-- TODO: Where is it still used, now? -->
   <p:declare-step type="da:list-packages">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return the packages.</p>
         <p>All the packages. The returned document is of the following format (a list of "pkg"
            elements, each with mandatory "id" and "name", and an optional "desc"):</p>
         <pre><![CDATA[
            <packages>
               <pkg>
                  <id>fgeorges/functx</id>
                  <repo>fgeorges</repo>
                  <abbrev>functx</abbrev>
                  <name>http://www.functx.com</name>
                  <desc>The famous FunctX library.</desc>
               </pkg>
               <pkg>
                  <id>fgeorges/pipx</id>
                  <repo>fgeorges</repo>
                  <abbrev>pipx</abbrev>
                  <name>http://pipx.org/lib/pipx</name>
               </pkg>
               ...
            </packages>
         ]]></pre>
         <p><b>TODO</b>: Add support for windowing.</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <dir:get-all-packages/>
      <p:unwrap match="/repos/repo"/>
      <p:rename match="/repos" new-name="packages"/>
      <p:viewport match="/packages/pkg">
         <p:xslt>
            <p:input port="stylesheet">
               <p:inline>
                  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                  exclude-result-prefixes="#all"
                                  version="2.0">
                     <xsl:template match="node()" priority="-10">
                        <xsl:message terminate="yes">
                           ERROR - Unknown node: <xsl:copy-of select="."/>
                        </xsl:message>
                     </xsl:template>
                     <xsl:template match="/pkg">
                        <xsl:copy>
                           <id>
                              <xsl:value-of select="@id"/>
                           </id>
                           <repo>
                              <xsl:value-of select="substring-before(@id, '/')"/>
                           </repo>
                           <abbrev>
                              <xsl:value-of select="@abbrev"/>
                           </abbrev>
                           <name>
                              <xsl:value-of select="name"/>
                           </name>
                           <xsl:if test="exists(abstract)">
                              <desc>
                                 <xsl:value-of select="abstract"/>
                              </desc>
                           </xsl:if>
                        </xsl:copy>
                     </xsl:template>
                  </xsl:stylesheet>
               </p:inline>
            </p:input>
            <p:input port="parameters">
               <p:empty/>
            </p:input>
         </p:xslt>
      </p:viewport>
   </p:declare-step>

   <p:declare-step type="da:packages-by-name">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return the packages from the database, with a given name.</p>
         <p>The packages with a given name are returned database. The returned
            document is of the following format (a list of "pkg" elements, each with mandatory "id"
            and an optional "desc"):</p>
         <pre><![CDATA[
            <packages name="http://expath.org/lib/http-client">
               <pkg>
                  <id>http-client-saxon</id>
                  <desc>The HTTP Client implementation for Saxon.</desc>
               </pkg>
               <pkg>
                  <id>http-client-exist</id>
               </pkg>
               ...
            </packages>
         ]]></pre>
         <p><b>TODO</b>: For now, loads the full
            package list, then filters it. Might be implemented more efficiently.</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="name" required="true"/>
      <da:list-packages/>
      <p:xslt>
         <p:with-param name="name" select="$name"/>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               version="2.0">
                  <xsl:param name="name" as="xs:string"/>
                  <xsl:template match="node()" priority="-10">
                     <xsl:message terminate="yes">
                        ERROR - Unknown node: <xsl:copy-of select="."/>
                     </xsl:message>
                  </xsl:template>
                  <xsl:template match="/packages">
                     <xsl:copy>
                        <xsl:attribute name="name" select="$name"/>
                        <xsl:apply-templates select="pkg[name eq $name]"/>
                     </xsl:copy>
                  </xsl:template>
                  <xsl:template match="pkg">
                     <xsl:copy>
                        <xsl:copy-of select="* except name"/>
                     </xsl:copy>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <p:declare-step type="da:package-details">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return details of a packages, given its CXAN ID.</p>
         <p>The details of the package, given its CXAN ID. The CXAN ID is provided through the
            options "repo" and "pkg" (the CXAN ID itself being "repo/pkg"). Including information
            from its package descriptor and from the CXAN descriptor (as they appear in packages.xml
            in the directory repos):</p>
         <pre><![CDATA[
            <pkg id="expath/http-client-saxon" abbrev="http-client-saxon" repo="expath" xml:base="...">
               <name>http://expath.org/lib/http-client</name>
               <abstract>Implementation for Saxon of the EXPath HTTP Client module.</abstract>
               <author id="fgeorges">Florent Georges</author>
               <category id="libs">Libraries</category>
               <category id="saxon">Saxon extensions</category>
               <tag>http</tag>
               <tag>library</tag>
               <tag>saxon</tag>
               <version num="0.11.0dev">
                  <dependency processor="http://saxon.sf.net/he"/>
                  <file name="expath-http-client-saxon-0.11.0dev.xar" role="pkg"/>
               </version>
               <version num="0.10.0">
                  <dependency processor="http://saxon.sf.net/he"/>
                  <file name="expath-http-client-saxon-0.11.0.xar" role="pkg"/>
                  <file name="expath-http-client-saxon-0.11.0.zip"/>
               </version>
               ...
            </pkg>
         ]]></pre>
         <p>In case there is no package corresponding to the options <code>repo</code> and
               <code>pkg</code>, the step returns the following document:</p>
         <pre><![CDATA[
            <no-such-package>
               <id>fgeorges/time-travel</id>
               <repo>fgeorges</repo>
               <abbrev>time-travel</abbrev>
            </no-such-package>
         ]]></pre>
         <p><b>TODO</b>: For now, loads the full package list, then filters it. Might be implemented
            more efficiently.  At least by resolving only the specific repo...</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="repo" required="true"/>
      <p:option name="pkg"  required="true"/>
      <dir:get-all-packages/>
      <p:xslt>
         <p:with-param name="repo" select="$repo"/>
         <p:with-param name="pkg"  select="$pkg"/>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               version="2.0">
                  <xsl:param name="repo" as="xs:string"/>
                  <xsl:param name="pkg"  as="xs:string"/>
                  <xsl:template match="node()" priority="-10">
                     <xsl:message terminate="yes">
                        ERROR - Unknown node: <xsl:copy-of select="."/>
                     </xsl:message>
                  </xsl:template>
                  <xsl:template match="/repos">
                     <xsl:variable name="id"    select="concat($repo, '/', $pkg)"/>
                     <xsl:variable name="found" select="repo/pkg[@id eq $id]"/>
                     <xsl:if test="empty($found)">
                        <no-such-package>
                           <id>
                              <xsl:value-of select="$id"/>
                           </id>
                           <repo>
                              <xsl:value-of select="$repo"/>
                           </repo>
                           <abbrev>
                              <xsl:value-of select="$pkg"/>
                           </abbrev>
                        </no-such-package>
                     </xsl:if>
                     <xsl:apply-templates select="$found"/>
                  </xsl:template>
                  <xsl:template match="pkg">
                     <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <xsl:attribute name="repo" select="$repo"/>
                        <xsl:attribute name="xml:base" select="resolve-uri(concat($pkg, '/'), base-uri(..))"/>
                        <xsl:copy-of select="node()"/>
                     </xsl:copy>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <!--
      Tags.
   -->

   <p:declare-step type="da:list-tags">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return the tags from the database.</p>
         <p>The tags are organized as a simple list. The returned document is of the
            following format (lexicographically ordered by tag name):</p>
         <pre><![CDATA[
            <tags>
               <tag>bar</tag>
               <tag>foo</tag>
               ...
            </tags>
         ]]></pre>
         <p><b>TODO</b>: For now, loads the
            entire package description list, then filters it. Put in place a denormalization
            mechanism, that would create a tags.xml file in each dir repo (first managed by hand in
            the Git repo directly, then maybe automatically generated when updating Git repos).</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <dir:get-all-packages/>
      <p:xslt>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:template match="node()" priority="-10">
                     <xsl:message terminate="yes">
                        ERROR - Unknown node: <xsl:copy-of select="."/>
                     </xsl:message>
                  </xsl:template>
                  <xsl:template match="/repos">
                     <tags>
                        <xsl:for-each select="distinct-values(repo/pkg/tag)">
                           <xsl:sort select="."/>
                           <tag>
                              <xsl:value-of select="."/>
                           </tag>
                        </xsl:for-each>
                     </tags>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <p:declare-step type="da:packages-by-tags">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return packages matching given tags.</p>
         <p>The tags are passed through the option "tags", as a slash-separated list
            of tags (e.g. "foo/bar" means both tags "foo" and "bar"). The returned document include
            the tags themselves, the packages matching all those tags, as well as a list of
            "subtags" (subtags are all the other tags from the packages matching the given
            tags):</p>
         <pre><![CDATA[
            <tags>
               <tag id="foo"/>
               <tag id="bar"/>
               ...
               <!-- among all packages matching "foo" and "bar", they also have "baz" -->
               <subtag id="baz"/>
               ...
               <pkg id="functx" repo="..." abbrev="...">
                  <desc>...</desc>
                  <tag>foo</tag>
                  <tag>bar</tag>
                  <tag>another</tag>
               </pkg>
               <pkg id="pipx" repo="..." abbrev="...">
                  <desc>...</desc>
                  <tag>foo</tag>
                  <tag>bar</tag>
               </pkg>
               ...
            </tags>
         ]]></pre>
         <p>Each set of elements (that is, all "tag", then all "subtag", then all "pkg") are sorted
            lexicographically by their ID.</p>
         <p><b>TODO</b>: For now, loads the entire package description list, then filters it. Put in
            place a denormalization mechanism, that would create a tags.xml file in each dir repo
            (first managed by hand in the Git repo directly, then maybe automatically generated when
            updating Git repos).</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="tags" required="true"/>
      <dir:get-all-packages/>
      <p:xslt>
         <p:with-param name="tags-str" select="$tags"/>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:param name="tags-str" as="xs:string"/>
                  <xsl:variable name="tags"  as="xs:string+"    select="tokenize($tags-str, '/')"/>
                  <xsl:variable name="pkgs"  as="element(pkg)*" select="/repos/repo/pkg[every $t in $tags satisfies $t = tag]"/>
                  <xsl:template match="node()" priority="-10">
                     <xsl:message terminate="yes">
                        ERROR - Unknown node: <xsl:copy-of select="."/>
                     </xsl:message>
                  </xsl:template>
                  <xsl:template match="/repos">
                     <tags>
                        <xsl:for-each select="$tags">
                           <xsl:sort select="."/>
                           <tag id="{ . }"/>
                        </xsl:for-each>
                        <xsl:for-each select="distinct-values($pkgs/tag)[not(. = $tags)]">
                           <xsl:sort select="."/>
                           <subtag id="{ . }"/>
                        </xsl:for-each>
                        <xsl:for-each select="$pkgs">
                           <xsl:sort select="."/>
                           <pkg id="{ @id }" abbrev="{ @abbrev }" repo="{ ../@abbrev }">
                              <desc>
                                 <xsl:value-of select="abstract"/>
                              </desc>
                              <xsl:copy-of select="tag"/>
                           </pkg>
                        </xsl:for-each>
                     </tags>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <!--
      Categories.
   -->

   <p:declare-step type="da:list-categories">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return the categories tree from the database.</p>
         <p>The categories are organized as a tree. That tree is stored in the
            database. The returned document is of the following format:</p>
         <pre><![CDATA[
            <categories>
               <cat id="doctypes" name="Document types"/>
               <cat id="processor" name="Processor-specific">
                  <cat id="saxon" name="Saxon extensions"/>
                  <cat id="exist" name="eXist extensions"/>
                  ...
               </cat>
               ...
            </categories>
         ]]></pre>
         <p><b>TODO</b>: For now, loads the
            entire package description list, then filters it. Put in place a denormalization
            mechanism, that would create a categories.xml file in each dir repo (first managed by
            hand in the Git repo directly, then maybe automatically generated when updating Git
            repos).</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <dir:list-categories/>
   </p:declare-step>

   <p:declare-step type="da:packages-by-category">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return packages within a specific category.</p>
         <p>The category is passed through the option "category", by using the category ID. The
            returned document is of the following format (note that categories can be
            recursive):</p>
         <pre><![CDATA[
            <cat id="the-cat" name="The category">
               <pkg id="fgeorges/functx" repo="fgeorges" abbrev="functx">
                  <desc>...</desc>
               </pkg>
               <pkg id="..." repo="..." abbrev="...">
                  <desc>...</desc>
               </pkg>
               ...
               <cat id="sub-cat-1" name="A sub-category">
                  <pkg id="..." repo="..." abbrev="...">
                     <desc>...</desc>
                  </pkg>
                  ...
               </cat>
               <cat id="sub-cat-2" name="Another sub-category">
                  <pkg id="..." repo="..." abbrev="...">
                     <desc>...</desc>
                  </pkg>
                  ...
               </cat>
               ...
            </cat>
         ]]></pre>
         <p>Generate an error if the category ID
            does not exist (should maybe return something saing "empty" or an empty document
            instead?)</p>
         <p><b>TODO</b>: Add an option to return
            the category content non-recursively. Or maybe never return it recursively, just mention
            sub-categories (that the client can decide to retrieve recursively or not).</p>
         <p><b>TODO</b>: For now, loads the
            entire package description list, then filters it. Put in place a denormalization
            mechanism, that would create a categories.xml file in each dir repo (first managed by
            hand in the Git repo directly, then maybe automatically generated when updating Git
            repos).</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="category" required="true"/>
      <dir:get-all-packages name="all-pkgs"/>
      <dir:list-categories  name="all-cats"/>
      <p:sink/>
      <p:xslt>
         <p:with-param name="cat-id" select="$category"/>
         <p:input port="source">
            <p:pipe step="all-pkgs" port="result"/>
            <p:pipe step="all-cats" port="result"/>
         </p:input>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:param name="cat-id" as="xs:string"/>
                  <!-- TODO: Check there is nothing in collection()[3]... -->
                  <xsl:variable name="all-pkgs" as="element(pkg)+"       select="collection()[1]/repos/repo/pkg"/>
                  <xsl:variable name="all-cats" as="element(categories)" select="collection()[2]/categories"/>
                  <xsl:template match="node()" priority="-10">
                     <xsl:message terminate="yes">
                        ERROR - Unknown node: <xsl:copy-of select="."/>
                     </xsl:message>
                  </xsl:template>
                  <xsl:template match="/repos">
                     <xsl:variable name="category" as="element(cat)?" select="$all-cats//cat[@id eq $cat-id]"/>
                     <xsl:apply-templates select="$category"/>
                  </xsl:template>
                  <xsl:template match="cat">
                     <!-- shallow copy -->
                     <xsl:copy>
                        <xsl:copy-of select="@*"/>
                        <!-- this category ID -->
                        <xsl:variable name="id"   select="@id"/>
                        <!-- the packages in this category -->
                        <xsl:variable name="pkgs" select="$all-pkgs[category/@id = $id]"/>
                        <!-- for each distinct of them, create a "pkg" element -->
                        <xsl:for-each select="$pkgs">
                           <xsl:sort select="@id"/>
                           <pkg id="{ @id }" abbrev="{ @abbrev }" repo="{ ../@abbrev }">
                              <desc>
                                 <xsl:value-of select="abstract"/>
                              </desc>
                           </pkg>
                        </xsl:for-each>
                        <!-- recurse categories -->
                        <xsl:apply-templates select="cat"/>
                     </xsl:copy>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <!--
      Authors.
   -->

   <p:declare-step type="da:list-authors">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return all distinct authors in the CXAN descriptors.</p>
         <p>The returned document is of the following format:</p>
         <pre><![CDATA[
            <authors>
               <author id="fgeorges">
                  <name>
                     <display>Florent Georges</display>
                  </name>
               </author>
               <author id="...">
                  ...
               </author>
               ...
            </authors>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <dir:list-authors/>
   </p:declare-step>

   <p:declare-step type="da:get-author">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return the author with the ID passed through the option "author".</p>
         <p>The returned document is of the following format:</p>
         <pre><![CDATA[
            <author id="fgeorges">
               <name>
                  <display>Florent Georges</display>
               </name>
            </author>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="author" required="true"/>
      <da:list-authors/>
      <p:xslt>
         <p:with-param name="auth-id" select="$author"/>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:param name="auth-id" as="xs:string"/>
                  <xsl:template match="node()" priority="-10">
                     <xsl:message terminate="yes">
                        ERROR - Unknown node: <xsl:copy-of select="."/>
                     </xsl:message>
                  </xsl:template>
                  <xsl:template match="/authors">
                     <xsl:sequence select="author[@id eq $auth-id]"/>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <p:declare-step type="da:packages-by-author">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return packages with a specific author.</p>
         <p>A package can have several authors. The author is passed through the option "author", by
            using the author ID. The returned document is of the following format:</p>
         <pre><![CDATA[
            <author id="fgeorges">
               <name>
                  <display>Florent Georges</display>
               </name>
               <packages>
                  <pkg id="fgeorges/cxan-website" repo="fgeorges" abbrev="cxan-website" role="maintainer"/>
                  <pkg id="fgeorges/functx"       repo="fgeorges" abbrev="functx"       role="author"/>
                  <pkg id="expath/http-client"    repo="expath"   abbrev="http-client"  role="maintainer"/>
               </packages>
            </author>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="author" required="true"/>
      <dir:author-packages>
         <p:with-option name="author" select="$author"/>
      </dir:author-packages>
   </p:declare-step>

   <!--
      Package files.
   -->

   <p:declare-step type="da:package-file-by-id">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return a package XAR file from a CXAN ID and version number.</p>
         <p>The file is returned as a document with a single element, containing the absolute file
            location:</p>
         <pre><![CDATA[
            <file>file:/.../git-base/repos/some-repo/functx/functx-1.0.xar</file>
         ]]></pre>
         <p><b>TODO</b>: The option $version is required, but can it be empty to explicitly say "the
            latest version"? Not sure there is a use case, double-check this is not used...</p>
         <p><b>TODO</b>: For now, loads the entire package description list, then filters it. Create
            a step in the dir:* library to return the one <code>pkg</code> element corresponding to
            this ID (would not need to build the entire list in memory, and could stop iterating in
            all "dir repositories" as soon as a package match is found).</p>
         <p><b>TODO</b>: What to do in case no package nor no version matches?</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="id"      required="true"/>
      <p:option name="version" required="true"/>
      <dir:get-all-packages/>
      <p:xslt>
         <p:with-param name="pkg-id"  select="$id"/>
         <p:with-param name="pkg-ver" select="$version"/>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:param name="pkg-id"  as="xs:string"/>
                  <xsl:param name="pkg-ver" as="xs:string"/>
                  <xsl:template match="node()" priority="-10">
                     <xsl:message terminate="yes">
                        ERROR - Unknown node: <xsl:copy-of select="."/>
                     </xsl:message>
                  </xsl:template>
                  <xsl:template match="/repos">
                     <xsl:variable name="pkg"  as="element(pkg)"     select="repo/pkg[@id eq $pkg-id]"/>
                     <xsl:variable name="ver"  as="element(version)" select="
                         if ( $pkg-ver[.] ) then
                            (: TODO: Handle the case where no version match (so @as won't match.) :)
                            $pkg/version[@num eq $pkg-ver]
                         else
                            (: by definition, the 1st version is the newest one:)
                            $pkg/version[1]"/>
                     <xsl:variable name="file" as="element(file)"    select="$ver/file[@role eq 'pkg']"/>
                     <xsl:variable name="path" select="concat($pkg/@abbrev, '/', $ver/@num, '/', $file/@name)"/>
                     <file mime="{ ( $file/@mime, 'application/zip'[$file/@role = ('pkg', 'archive')], 'application/octet-stream' )[1] }">
                        <xsl:value-of select="resolve-uri($path, base-uri($pkg))"/>
                     </file>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <p:declare-step type="da:package-file-by-name">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return a package XAR file from a package name URI and version number.</p>
         <p>The file is returned as a document with a single element, containing the absolute file
            location:</p>
         <pre><![CDATA[
            <file>file:/.../git-base/repos/some-repo/functx/functx-1.0.xar</file>
         ]]></pre>
         <p><b>TODO</b>: The option $version is required, but can it be empty to explicitly say "the
            latest version"? Not sure there is a use case, double-check this is not used...</p>
         <p><b>TODO</b>: For now, loads the entire package description list, then filters it. Create
            a step in the dir:* library to return the one <code>pkg</code> element corresponding to
            this name (would not need to build the entire list in memory, and could stop iterating
            in all "dir repositories" as soon as a package match is found).</p>
         <p><b>TODO</b>: What to do in case no package nor no version matches?</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="name"    required="true"/>
      <p:option name="version" required="true"/>
      <dir:get-all-packages/>
      <p:xslt>
         <p:with-param name="pkg-name" select="$name"/>
         <p:with-param name="pkg-ver"  select="$version"/>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:param name="pkg-name" as="xs:string"/>
                  <xsl:param name="pkg-ver"  as="xs:string"/>
                  <xsl:template match="node()" priority="-10">
                     <xsl:message terminate="yes">
                        ERROR - Unknown node: <xsl:copy-of select="."/>
                     </xsl:message>
                  </xsl:template>
                  <xsl:template match="/repos">
                     <xsl:variable name="pkg"  as="element(pkg)"     select="repo/pkg[name eq $pkg-name]"/>
                     <xsl:variable name="ver"  as="element(version)" select="$pkg/version[@num eq $pkg-ver]"/>
                     <xsl:variable name="file" as="element(file)"    select="$ver/file[@role eq 'pkg']"/>
                     <xsl:variable name="path" select="concat($pkg/@abbrev, '/', $pkg-ver, '/', $file/@name)"/>
                     <file mime="{ ( $file/@mime, 'application/zip'[$file/@role = ('pkg', 'archive')], 'application/octet-stream' )[1] }">
                        <xsl:value-of select="resolve-uri($path, base-uri($pkg))"/>
                     </file>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
   </p:declare-step>

   <p:declare-step type="da:package-file-by-file">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return a package XAR file from a CXAN ID and filename.</p>
         <p>The file is returned as a document with a single element, containing the absolute file
            location:</p>
         <pre><![CDATA[
            <file>file:/.../git-base/repos/some-repo/functx/functx-1.0.xar</file>
         ]]></pre>
         <p>In the above case, <code>repo</code> would be <code>some-repo</code>, <code>pkg</code>
            would be <code>functx</code> and <code>file</code> would be <code>functx-1.0.xar</code>.
            This implies that the file names are different for all versions (the exact same file
            name cannot be part of 2 different versions, therefore the version number should really
            be part of the file naming convention).</p>
         <p><b>TODO</b>: For now, loads the entire package description list, then filters it. Create
            a step in the dir:* library to return the one <code>pkg</code> element corresponding to
            this name (would not need to build the entire list in memory, and could stop iterating
            in all "dir repositories" as soon as a package match is found).</p>
         <p><b>TODO</b>: What to do in case no package nor no version matches?</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="repo" required="true"/>
      <p:option name="pkg"  required="true"/>
      <p:option name="file" required="true"/>
      <dir:get-all-packages/>
      <p:xslt>
         <p:with-param name="repo" select="$repo"/>
         <p:with-param name="pkg"  select="$pkg"/>
         <p:with-param name="file" select="$file"/>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               exclude-result-prefixes="#all"
                               version="2.0">
                  <xsl:param name="repo" as="xs:string"/>
                  <xsl:param name="pkg"  as="xs:string"/>
                  <xsl:param name="file" as="xs:string"/>
                  <xsl:template match="node()" priority="-10">
                     <xsl:message terminate="yes">
                        ERROR - Unknown node: <xsl:copy-of select="."/>
                     </xsl:message>
                  </xsl:template>
                  <xsl:template match="/repos">
                     <xsl:variable name="repo-elem" as="element(repo)" select="repo[@abbrev eq $repo]"/>
                     <xsl:variable name="pkg-elem"  as="element(pkg)"  select="$repo-elem/pkg[@abbrev eq $pkg]"/>
                     <xsl:variable name="found"     as="element(file)" select="$pkg-elem/version/file[@name eq $file]"/>
                     <xsl:variable name="path" select="concat($pkg-elem/@abbrev, '/', $found/../@num, '/', $found/@name)"/>
                     <file mime="{ ( $found/@mime, 'application/zip'[$found/@role = ('pkg', 'archive')], 'application/octet-stream' )[1] }">
                        <xsl:value-of select="resolve-uri($path, base-uri($pkg-elem))"/>
                     </file>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
      </p:xslt>
   </p:declare-step>

</p:library>
