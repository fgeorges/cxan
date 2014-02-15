<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:pkg="http://expath.org/ns/pkg"
           xmlns:app="http://cxan.org/ns/website"
           xmlns:da="http://cxan.org/ns/website/data-access"
           xmlns:edb="http://cxan.org/ns/website/exist-db"
           exclude-inline-prefixes="c pkg"
           version="1.0"
           pkg:import-uri="http://cxan.org/ns/website/data-access.xpl">

   <p:import href="exist-db.xpl"/>

   <!--
      Packages.
   -->

   <p:declare-step type="da:list-packages">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return the packages from the database.</p>
         <p>All the packages are returned database. The returned document is of the
            following format (a list of "pkg" elements, each with mandatory "id" and "name",
            and an optional "desc"):</p>
         <pre><![CDATA[
            <packages>
               <pkg>
                  <id>functx</id>
                  <name>http://www.functx.com</name>
                  <desc>The famous FunctX library.</desc>
               </pkg>
               <pkg>
                  <id>pipx</id>
                  <name>http://pipx.org/lib/pipx</name>
               </pkg>
               ...
            </packages>
         ]]></pre>
         <p><b>TODO</b>: Add support for windowing.</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <edb:query-exist-with module="list-packages">
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </edb:query-exist-with>
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
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="name" required="true"/>
      <edb:query-exist-with module="packages-by-name">
         <p:with-param name="name" select="$name"/>
      </edb:query-exist-with>
   </p:declare-step>

   <p:declare-step type="da:package-details">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return details of a packages, given its CXAN ID.</p>
         <p>The details of the package, given its CXAN ID provided through the option
            "id", include its descriptor in the database package list, the package descriptor for
            each version in the database, and the CXAN descriptor for the last version:</p>
         <pre><![CDATA[
            <package>
               <pkg id="functx">
                  <name>http://www.functx.com</name>
                  <version id="1.0">
                     <file>functx/functx-1.0.xar</file>
                     ...
                  </version>
               </pkg>
               <package xmlns="http://expath.org/ns/pkg" ...>
                  ... the initial expath-pkg.xml descriptor ...
                  ... one for each version in the system ...
               </package>
               ...
               <package xmlns="http://cxan.org/ns/package" id="functx">
                  ... the cxan.xml descriptor for the latest version ...
               </package>
            </package>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="id" required="true"/>
      <edb:query-exist-with module="package-details">
         <p:with-param name="id" select="$id"/>
      </edb:query-exist-with>
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
      </p:documentation>
      <p:output port="result" primary="true"/>
      <edb:query-exist-with module="list-tags">
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </edb:query-exist-with>
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
               <pkg id="functx"/>
               <pkg id="pipx"/>
               ...
            </cat>
         ]]></pre>
         <p>Each set of elements (that is, all "tag", then all "subtag", then all
            "pkg") are sorted lexicographically by their ID.</p>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="tags" required="true"/>
      <edb:query-exist-with module="packages-by-tags">
         <p:with-param name="tags" select="$tags"/>
      </edb:query-exist-with>
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
      </p:documentation>
      <p:output port="result" primary="true"/>
      <edb:query-exist>
         <p:input port="source">
            <p:inline>
               <c:data>
                  doc('/db/cxan/categories.xml')
               </c:data>
            </p:inline>
         </p:input>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </edb:query-exist>
   </p:declare-step>

   <p:declare-step type="da:packages-by-category">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return packages within a specific category.</p>
         <p>The category is passed through the option "category", by using the
            category ID. The returned document is of the following format (note that categories can
            be recursive):</p>
         <pre><![CDATA[
            <cat id="the-cat" name="The category">
               <pkg id="..."/>
               <pkg id="..."/>
               ...
               <cat id="sub-cat-1" name="A sub-category">
                  <pkg id="..."/>
                  <pkg id="..."/>
                  ...
               </cat>
               <cat id="sub-cat-2" name="Another sub-category">
                  <pkg id="..."/>
                  <pkg id="..."/>
                  ...
               </cat>
               ...
            </cat>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="category" required="true"/>
      <edb:query-exist-with module="packages-by-category">
         <p:with-param name="category" select="$category"/>
      </edb:query-exist-with>
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
               <author id="fgeorges">Florent Georges</author>
               <author id="...">...</author>
               ...
            </authors>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <edb:query-exist-with module="list-authors">
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </edb:query-exist-with>
   </p:declare-step>

   <p:declare-step type="da:packages-by-author">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return packages with a specific author.</p>
         <p>A package can have several authors. The author is passed through the
            option "author", by using the author ID. The returned document is of the following
            format:</p>
         <pre><![CDATA[
            <packages-by-author>
               <author>Florent Georges</author>
               <pkg id="cxan-client"/>
               <pkg id="cxan-website"/>
               ...
            </packages-by-author>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="author" required="true"/>
      <edb:query-exist-with module="packages-by-author">
         <p:with-param name="author" select="$author"/>
      </edb:query-exist-with>
   </p:declare-step>

   <!--
      Package files.
   -->

   <p:declare-step type="da:package-file-by-id">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return a package XAR file from a CXAN ID.</p>
         <p>The file is returned as a document with a single element, containing the
            file location:</p>
         <pre><![CDATA[
            <file>functx/functx-1.0.xar</file>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="id"      required="true"/>
      <p:option name="version" required="true"/>
      <edb:query-exist-with module="package-file-by-id">
         <p:with-param name="id"      select="$id"/>
         <p:with-param name="version" select="$version"/>
      </edb:query-exist-with>
   </p:declare-step>

   <p:declare-step type="da:package-file-by-name">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return a package XAR file from a package name URI.</p>
         <p>The file is returned as a document with a single element, containing the
            file location:</p>
         <pre><![CDATA[
            <file>functx/functx-1.0.xar</file>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="name"    required="true"/>
      <p:option name="version" required="true"/>
      <edb:query-exist-with module="package-file-by-name">
         <p:with-param name="name"    select="$name"/>
         <p:with-param name="version" select="$version"/>
      </edb:query-exist-with>
   </p:declare-step>

   <!--
      Backup and restore.
   -->

   <p:declare-step type="da:suck-database">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return all documents in the CXAN collection.</p>
         <p>The returned document is of the following format:</p>
         <pre><![CDATA[
            <documents>
               <doc uri="/db/cxan/some-file.xml">
                  <root>
                     <elem>Contains the entire some-file.xml content.</elem>
                  </root>
               </doc>
               <doc uri="/db/cxan/...">
                  ...
               </doc>
               ...
            </documents>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <edb:query-exist-with module="suck-database">
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </edb:query-exist-with>
   </p:declare-step>

   <p:declare-step type="da:restore-backup">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Restore a backup.</p>
         <p>The input port is the backup (a document as those created by
            da:suck-database). The backup document is inserted in the database into the CXAN
            collection, then expanded. If there is any other document in the CXAN collection, the
            error "DB002" is thrown. The returned document is the list of all documents inserted
            in the database, as following:</p>
         <pre><![CDATA[
            <result>
               <created>/db/cxan/some-file.xml</created>
               <created>/db/cxan/...</created>
               ...
            </result>
         ]]></pre>
      </p:documentation>
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <edb:insert-doc uri="/db/cxan/backup.xml"/>
      <edb:query-exist-with module="restore-backup">
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </edb:query-exist-with>
   </p:declare-step>

</p:library>
