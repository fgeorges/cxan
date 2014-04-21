<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:cx="http://xmlcalabash.com/ns/extensions"
            xmlns:pxp="http://exproc.org/proposed/steps"
            xmlns:pxf="http://exproc.org/proposed/steps/file"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            pkg:import-uri="http://cxan.org/website/pages/pkg.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <!--
       The main processing.
       
       TODO: We can see that more and more, each action main processing is the
       same: split the source sequence, get params from the path, check the
       method, dispatch (maybe) between different methods, format either to
       XML or a page, handle errors, etc.  Is it possible to factorize that
       out, or to use filters? (e.g. for errors and page formating)
   -->

   <!-- FIXME: What?  An element?  Not a document, really?!? -->
   <p:split-sequence test=". instance of element(web:request)" name="request"/>

   <p:group>
      <!-- the package id -->
      <p:variable name="id" select="/web:request/web:path/web:match[@name eq 'id']">
         <p:pipe step="request" port="matched"/>
      </p:variable>
      <p:variable name="accept" select="/web:request/web:header[@name eq 'accept']/@value">
         <p:pipe step="request" port="matched"/>
      </p:variable>

      <app:ensure-method accepted="get"/>
      <app:ensure-value desc="package ID">
         <p:with-option name="value" select="$id"/>
      </app:ensure-value>
      <p:sink/>

      <!-- retrieve the pkg element from the database, given its ID -->
      <da:package-details>
         <p:with-option name="id" select="$id"/>
      </da:package-details>
      <!-- format the data to a page document -->
      <p:choose>
         <p:when test="$accept eq 'application/xml'">
            <app:wrap-xml-result/>
         </p:when>
         <p:otherwise>
            <p:xslt name="result">
               <p:input port="stylesheet">
                  <p:document href="pkg-get.xsl"/>
               </p:input>
               <p:input port="parameters">
                  <p:empty/>
               </p:input>
            </p:xslt>
         </p:otherwise>
      </p:choose>
   </p:group>

</p:pipeline>
