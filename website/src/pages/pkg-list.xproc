<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            pkg:import-uri="http://cxan.org/website/pages/pkg-list.xproc"
            name="pipeline"
            version="1.0">

   <!--
       Get the package list for the /pkg page.
       
       If the name URI param is there, restrict the list to the packages with
       that name.  If there is only one such package, send a HTTP redirect to
       the page of that package.
   -->

   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <p:variable name="accept"   select="/web:request/web:header[@name eq 'accept']/@value"/>
   <p:variable name="repo"     select="/web:request/web:path/web:match[@name eq 'repo']"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <app:config-params name="config"/>

   <p:group>

      <p:variable name="base-uri" select="/c:param-set/c:param[@name eq 'home-uri']/@value"/>
      <p:sink/>

      <da:packages-by-repo>
         <p:with-option name="repo" select="$repo"/>
      </da:packages-by-repo>

      <p:choose>
         <p:when test="$accept eq 'application/xml'">
            <!-- return the raw XML -->
            <app:wrap-xml-result/>
         </p:when>
         <p:otherwise>
            <!-- format the data to a page document -->
            <p:xslt name="result">
               <p:input port="stylesheet">
                  <p:document href="pkg-list.xsl"/>
               </p:input>
               <p:with-param name="base-uri" select="$base-uri"/>
               <p:with-param name="repo-id"  select="$repo"/>
            </p:xslt>
         </p:otherwise>
      </p:choose>

   </p:group>

</p:pipeline>
