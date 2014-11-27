<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:pkg="http://expath.org/ns/pkg"
           xmlns:app="http://cxan.org/ns/website"
           xmlns:dir="http://cxan.org/ns/website/dir-repos"
           xmlns:pipx="http://pipx.org/ns/pipx"
           version="1.0"
           pkg:import-uri="##none">

   <p:import href="../tools.xpl"/>
   <p:import href="http://pipx.org/ns/pipx.xpl"/>
   <!--p:import href="../../../../../xproc/pipx/pipx/src/pipx.xpl"/-->

   <!--
      Repositories.
   -->

   <p:declare-step type="dir:get-all-repositories">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return all repositories from the master repo.</p>
         <p>The output port of this step returns all repositories, wrapped in a single
            "repositories" element, which looks like:</p>
         <pre><![CDATA[
            <repositories>
               <repo abbrev="fgeorges" href="../repos/fgeorges/">
                  <desc>Florent Georges's personal repository.</desc>
                  <packages>../repos/fgeorges/packages.xml</packages>
                  <git>
                     <remote>http://fgeorges@git.fgeorges.org/r/~fgeorges/cxan-repo.git</remote>
                     <branch>master</branch>
                  </git>
               </repo>
               <repo ...>
                  ...
               </repo>
               ...
            </repositories>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <dir:get-all-repositories-impl>
         <p:input port="parameters">
            <!-- TODO: Which one? -->
            <!--p:document href="../../../../config-params.xml"/-->
            <p:document href="../config-params.xml"/>
         </p:input>
      </dir:get-all-repositories-impl>
   </p:declare-step>

   <p:declare-step type="dir:get-all-repositories-impl">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Implementation step for dir:get-all-repositories.</p>
         <p>The step dir:get-all-repositories simply pass the config parameters.</p>
      </p:documentation>
      <p:input  port="parameters" primary="true" kind="parameter"/>
      <p:output port="result"     primary="true"/>
      <pipx:parameter param-name="master-repo" required="true"/>
      <p:load>
         <p:with-option name="href" select="resolve-uri('repositories.xml', /param)"/>
      </p:load>
   </p:declare-step>

   <p:declare-step type="dir:repo-packages">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return all packages from a given directory repo.</p>
         <p>Each directory repo contains a packages.xml file, with a root element "repo", and child
            elements "pkg". This step returns the one from the repository passed through the option
            "repo". The output port of this step returns this documents, which looks like:</p>
         <pre><![CDATA[
            <repo abbrev="...">
               <pkg id="fgeorges/functx" abbrev="functx">
                  <name>...</name>
                  <version num="...">
                     <file name="..." role="pkg"/>
                  </version>
                  ...
               </pkg>
               <pkg id="fgeorges/fxsl" abbrev="fxsl">
                  <name>...</name>
                  <abstract>...</abstract>
                  <author id="...">...</author>
                  <category id="...">...</category>
                  <category id="...">...</category>
                  <tag>...</tag>
                  <version num="..">
                     <dependency processor="..."/>
                     <file name="..." role="pkg"/>
                     ...
                  </version>
               </pkg>
               ...
            </repo>
         ]]></pre>
      </p:documentation>
      <p:option name="repo" required="true"/>
      <p:output port="result" primary="true"/>
      <dir:repo-packages-impl>
         <p:with-option name="repo" select="$repo"/>
         <p:input port="parameters">
            <!-- TODO: Which one? -->
            <!--p:document href="../../../../config-params.xml"/-->
            <p:document href="../config-params.xml"/>
         </p:input>
      </dir:repo-packages-impl>
   </p:declare-step>

   <p:declare-step type="dir:repo-packages-impl">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Implementation step for dir:repo-packages.</p>
         <p>The step dir:repo-packages simply pass the config parameters.</p>
      </p:documentation>
      <p:option name="repo" required="true"/>
      <p:input  port="parameters" primary="true" kind="parameter"/>
      <p:output port="result"     primary="true"/>
      <p:variable name="path" select="concat('../repos/', $repo, '/packages.xml')"/>
      <pipx:parameter param-name="master-repo" required="true"/>
      <p:load>
         <p:with-option name="href" select="resolve-uri($path, /param)"/>
      </p:load>
   </p:declare-step>

   <!--
      Packages.
   -->

   <p:declare-step type="dir:get-all-packages">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return all packages from directory repos.</p>
         <p>Each directory repo contains a packages.xml file, with a root element "repo", and child
            elements "pkg". This step returns them all, adding an attribute "@xml:base" on each
            "repo" element to store the URI of the packages.xml file this particular repo is stored
            in (an absolute URI using file: scheme). All directory repos are the child directories
            of the parameter "git-base". The output port of this step returns all such documents,
            wrapped in a single "repos" element, which looks like:</p>
         <pre><![CDATA[
            <repos>
               <repo xml:base="...">
                  <pkg id="fgeorges/functx" abbrev="functx">
                     <name>...</name>
                     <version num="...">
                        <file name="..." role="pkg"/>
                     </version>
                     ...
                  </pkg>
                  <pkg id="fgeorges/fxsl" abbrev="fxsl">
                     <name>...</name>
                     <abstract>...</abstract>
                     <author id="...">...</author>
                     <category id="...">...</category>
                     <category id="...">...</category>
                     <tag>...</tag>
                     <version num="..">
                        <dependency processor="..."/>
                        <file name="..." role="pkg"/>
                     </version>
                  </pkg>
                  ...
               </repo>
               ...
            </repos>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <dir:get-all-packages-impl>
         <p:input port="parameters">
            <!-- TODO: Which one? -->
            <!--p:document href="../../../../config-params.xml"/-->
            <p:document href="../config-params.xml"/>
         </p:input>
      </dir:get-all-packages-impl>
   </p:declare-step>

   <p:declare-step type="dir:get-all-packages-impl">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Implementation step for dir:get-all-packages.</p>
         <p>The step dir:get-all-packages simply pass the config parameters.</p>
      </p:documentation>
      <p:input  port="parameters" primary="true" kind="parameter"/>
      <p:output port="result"     primary="true"/>
      <pipx:parameter param-name="master-repo" required="true"/>
      <p:group>
         <p:variable name="href" select="resolve-uri('packages.xml', /param)"/>
         <p:load>
            <p:with-option name="href" select="$href"/>
         </p:load>
         <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="$href"/>
         </p:add-attribute>
      </p:group>
   </p:declare-step>

   <!--
      Authors.
   -->

   <p:declare-step type="dir:list-authors">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Returns the list of authors known by the system. The authors are stored in the file
               <code>authors.xml</code> in the directory pointed to by the config parameter
               <code>git-base</code>. It looks like:</p>
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
            </categories>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <dir:list-authors-impl>
         <p:input port="parameters">
            <!-- TODO: Which one? -->
            <!--p:document href="../../../../config-params.xml"/-->
            <p:document href="../config-params.xml"/>
         </p:input>
      </dir:list-authors-impl>
   </p:declare-step>

   <p:declare-step type="dir:list-authors-impl">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Implementation step for dir:list-authors.</p>
         <p>The step dir:list-authors simply pass the config parameters.</p>
      </p:documentation>
      <p:input  port="parameters" primary="true" kind="parameter"/>
      <p:output port="result"     primary="true"/>
      <pipx:parameter param-name="master-repo" required="true"/>
      <p:load>
         <p:with-option name="href" select="resolve-uri('authors.xml', string(/param))"/>
      </p:load>
   </p:declare-step>

   <p:declare-step type="dir:author-packages">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Returns a specific author, with the list of its packages. The author is stored in the
            file <code>authors/{author}.xml</code> in the directory pointed to by the config
            parameter <code>git-base</code>, where <code>{author}</code> is the author ID, passed
            through the option "author". It looks like:</p>
         <pre><![CDATA[
            <author id="fgeorges">
               <name>
                  <display>Florent Georges</display>
               </name>
               <packages>
                  <pkg id="cxan-website"/>
                  <pkg id="expath-http-client"/>
               </packages>
            </author>
         ]]></pre>
      </p:documentation>
      <p:output port="result" primary="true"/>
      <p:option name="author" required="true"/>
      <dir:author-packages-impl>
         <p:with-option name="author" select="$author"/>
         <p:input port="parameters">
            <!-- TODO: Which one? -->
            <!--p:document href="../../../../config-params.xml"/-->
            <p:document href="../config-params.xml"/>
         </p:input>
      </dir:author-packages-impl>
   </p:declare-step>

   <p:declare-step type="dir:author-packages-impl">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Implementation step for dir:author-packages.</p>
         <p>The step dir:author-packages simply pass the config parameters.</p>
      </p:documentation>
      <p:input  port="parameters" primary="true" kind="parameter"/>
      <p:output port="result"     primary="true"/>
      <p:option name="author" required="true"/>
      <pipx:parameter param-name="master-repo" required="true"/>
      <p:try>
         <p:group>
            <p:load>
               <p:with-option name="href" select="resolve-uri(concat('authors/', $author, '.xml'), string(/param))"/>
            </p:load>
         </p:group>
         <p:catch>
            <p:identity>
               <p:input port="source">
                  <p:inline><no-author/></p:inline>
               </p:input>
            </p:identity>
            <p:add-attribute attribute-name="id" match="/*">
               <p:with-option name="attribute-value" select="$author"/>
            </p:add-attribute>
         </p:catch>
      </p:try>
   </p:declare-step>

   <!--
      Categories.
   -->

   <p:declare-step type="dir:list-categories">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Returns the category hierarchy known by the system. The hierarchy is stored in the file
               <code>categories.xml</code> in the directory pointed to by the config parameter
               <code>git-base</code>. It looks like:</p>
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
      <dir:list-categories-impl>
         <p:input port="parameters">
            <!-- TODO: Which one? -->
            <!--p:document href="../../../../config-params.xml"/-->
            <p:document href="../config-params.xml"/>
         </p:input>
      </dir:list-categories-impl>
   </p:declare-step>

   <p:declare-step type="dir:list-categories-impl">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Implementation step for dir:list-categories.</p>
         <p>The step dir:list-categories simply pass the config parameters.</p>
      </p:documentation>
      <p:input  port="parameters" primary="true" kind="parameter"/>
      <p:output port="result"     primary="true"/>
      <pipx:parameter param-name="master-repo" required="true"/>
      <p:load>
         <p:with-option name="href" select="resolve-uri('categories.xml', string(/param))"/>
      </p:load>
   </p:declare-step>

</p:library>
