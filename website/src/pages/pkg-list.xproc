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
   <p:variable name="name"     select="/web:request/web:param[@name eq 'name']/@value"/>
   <p:variable name="base-uri" select="/c:param-set/c:param[@name eq 'home-uri']/@value">
      <p:document href="../../../../config-params.xml"/>
   </p:variable>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <!-- retrieve the packages id and name from eXist -->
   <p:choose>
      <!-- Note: I don't know why, but $name[.] does NOT work... -->
      <p:when test="exists($name) and $name ne ''">
         <da:packages-by-name>
            <p:with-option name="name" select="$name"/>
         </da:packages-by-name>
      </p:when>
      <p:otherwise>
         <da:list-packages/>
      </p:otherwise>
   </p:choose>

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
         </p:xslt>
      </p:otherwise>
   </p:choose>

</p:pipeline>
