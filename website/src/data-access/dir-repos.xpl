<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:pkg="http://expath.org/ns/pkg"
           xmlns:app="http://cxan.org/ns/website"
           xmlns:dir="http://cxan.org/ns/website/dir-repos"
           xmlns:pipx="http://pipx.org/ns/pipx"
           version="1.0"
           pkg:import-uri="##none">

   <p:import href="../tools.xpl"/>
   <!--p:import href="http://pipx.org/ns/pipx.xpl"/-->
   <p:import href="../../../../../xproc/pipx/pipx/src/pipx.xpl"/>

   <p:declare-step type="dir:get-all-packages">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Return all packages from directory repos.</p>
         <p>Each directory repo contains a
            packages.xml file, with a root element "repo", and child elements "pkg". This step
            returns them all, adding an attribute "@xml:base" on each "repo" element to store the
            URI of the packages.xml file this particular repo is stored in (an absolute URI using
            file: scheme). All directory repos are the child directories of the parameter
            "git-base". The output port of this step returns all such documents, wrapped in a single
            "repos" element, which looks like:</p>
         <pre><![CDATA[
            <repos>
               <repo xml:base="...">
                  <pkg id="...">
                     <name>...</name>
                     <version num="...">
                        <file name="..." role="pkg"/>
                     </version>
                     ...
                  </pkg>
                  <pkg id="...">
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
      <pipx:parameter param-name="git-base" required="true"/>
      <p:directory-list>
         <p:with-option name="path" select="string(/param)"/>
      </p:directory-list>
      <p:group>
         <p:variable name="base-dir" select="/c:directory/@xml:base"/>
         <p:viewport match="/c:directory/c:directory">
            <p:variable name="href" select="resolve-uri(concat(/*/@name, '/packages.xml'), $base-dir)"/>
            <p:load>
               <p:with-option name="href" select="$href"/>
            </p:load>
            <p:add-attribute match="/*" attribute-name="xml:base">
               <p:with-option name="attribute-value" select="$href"/>
            </p:add-attribute>
         </p:viewport>
         <p:delete match="/c:directory/c:*"/>
         <p:delete match="/c:directory/@*"/>
         <p:rename match="/c:directory" new-name="repos"/>
      </p:group>
   </p:declare-step>

   <p:declare-step type="dir:list-categories">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Returns the category hierarchy known
            by the system. The hierarchy is stored in the file <code>categories.xml</code> in the
            directory pointed to by the config parameter <code>git-base</code>. It looks like:</p>
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
      <pipx:parameter param-name="git-base" required="true"/>
      <p:load>
         <p:with-option name="href" select="resolve-uri('categories.xml', string(/param))"/>
      </p:load>
   </p:declare-step>

</p:library>
