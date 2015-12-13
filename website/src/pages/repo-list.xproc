<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            xmlns:local="repo-list.xproc#local"
            pkg:import-uri="http://cxan.org/website/pages/repo-list.xproc"
            name="pipeline"
            version="1.0">

   <!--
       Get the repository list for the /pkg page.
       
       If the name URI param is there, display the list of packages with that
       name.  If there is only one such package, send a HTTP redirect to the
       page of that package.
   -->

   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <p:declare-step type="local:wrap-it-up" name="this">
      <p:option name="accept"   required="true"/>
      <p:option name="base-uri" required="true"/>
      <p:input  port="source" primary="true"/>
      <p:input  port="stylesheet"/>
      <p:output port="result" primary="true"/>
      <p:choose>
         <p:when test="$accept eq 'application/xml'">
            <!-- return the raw XML -->
            <app:wrap-xml-result/>
         </p:when>
         <p:otherwise>
            <!-- format the data to a page document -->
            <p:xslt name="result">
               <p:input port="stylesheet">
                  <p:pipe port="stylesheet" step="this"/>
               </p:input>
               <p:with-param name="base-uri" select="$base-uri"/>
               <p:with-param name="repolist" select="true()"/>
            </p:xslt>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

   <p:variable name="accept" select="/web:request/web:header[@name eq 'accept']/@value"/>
   <p:variable name="name"   select="/web:request/web:param[@name eq 'name']/@value"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <app:config-params name="config"/>

   <p:group>

      <p:variable name="base-uri" select="/c:param-set/c:param[@name eq 'home-uri']/@value"/>
      <p:sink/>

      <!-- retrieve the repositories id and name -->
      <p:choose>
         <!-- Note: I don't know why, but $name[.] does NOT work... -->
         <p:when test="exists($name) and $name ne ''">
            <da:packages-by-name>
               <p:with-option name="name" select="$name"/>
            </da:packages-by-name>
            <local:wrap-it-up>
               <p:with-option name="accept"   select="$accept"/>
               <p:with-option name="base-uri" select="$base-uri"/>
               <p:input port="stylesheet">
                  <p:document href="pkg-list.xsl"/>
               </p:input>
            </local:wrap-it-up>
         </p:when>
         <p:otherwise>
            <da:list-repositories/>
            <local:wrap-it-up>
               <p:with-option name="accept"   select="$accept"/>
               <p:with-option name="base-uri" select="$base-uri"/>
               <p:input port="stylesheet">
                  <p:document href="repo-list.xsl"/>
               </p:input>
            </local:wrap-it-up>
         </p:otherwise>
      </p:choose>

   </p:group>

</p:pipeline>
