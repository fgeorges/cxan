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
   <p:import href="../upload-lib.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <!--
       Implementation in case of a GET.
   -->
   <p:declare-step type="app:page-pkg-get">
      <p:option name="id"     required="true"/>
      <p:option name="accept" required="true"/>
      <p:output port="result" primary="true"/>
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
   </p:declare-step>

   <!--
       Implementation in case of a PUT.
   -->
   <p:declare-step type="app:page-pkg-put" name="pkg-put">
      <p:option name="id" required="true"/>
      <p:input  port="request" primary="true"/>
      <p:input  port="request-bodies" sequence="true"/>
      <p:input  port="parameters" kind="parameter" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:variable name="diff-name" select="
          ( /web:request/web:param[@name eq 'different-name']/@value, 'error' )[1]"/>
      <!-- augment the c:data for XAR file and additional files with @filename -->
      <p:for-each>
         <p:iteration-source>
            <p:pipe step="pkg-put" port="request-bodies"/>
         </p:iteration-source>
         <p:variable name="pos"      select="p:iteration-position()"/>
         <!-- TODO: There is some kind of grouping here: we don't really want the
              Nth header with name '...', we want the header with that name which is
              between the N-1th and the Nth web:body element in web:multipart... -->
         <p:variable name="dispo"    select="
             ( /web:request/( web:multipart, . )[1]/web:header[@name eq 'content-disposition'] )
               [number($pos)]/@value">
            <p:pipe step="pkg-put" port="request"/>
         </p:variable>
         <p:variable name="filename" select="
             web:parse-header-value($dispo)
               / web:element[@name eq 'attachment']
               / web:param[@name eq 'filename']
               / @value"/>
         <p:add-attribute match="/c:data" attribute-name="filename">
            <p:with-option name="attribute-value" select="$filename"/>
         </p:add-attribute>
      </p:for-each>
      <!-- call the library step -->
      <app:upload-package>
         <p:with-option name="pkg-id"         select="$id">
            <p:empty/>
         </p:with-option>
         <p:with-option name="different-name" select="$diff-name">
            <p:empty/>
         </p:with-option>
      </app:upload-package>
      <!-- respond with 200 / Ok / <success/> -->
      <p:identity>
         <p:input port="source">
            <p:inline>
               <web:response status="200" message="Ok">
                  <web:body content-type="application/xml">
                     <success/>
                  </web:body>
               </web:response>
            </p:inline>
         </p:input>
      </p:identity>
   </p:declare-step>

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

      <app:ensure-method accepted="get,put"/>
      <app:ensure-value desc="package ID">
         <p:with-option name="value" select="$id"/>
      </app:ensure-value>

      <p:choose>
         <!-- a GET -->
         <p:when test="/web:request/@method eq 'get'">
            <p:sink/>
            <app:page-pkg-get>
               <p:with-option name="id"     select="$id"/>
               <p:with-option name="accept" select="$accept"/>
            </app:page-pkg-get>
         </p:when>
         <!-- a PUT (we have already checked as "get,put") -->
         <p:otherwise>
            <app:page-pkg-put>
               <p:with-option name="id" select="$id"/>
               <p:input port="request-bodies">
                  <p:pipe port="not-matched" step="request"/>
               </p:input>
               <p:input port="parameters">
                  <p:document href="../../../../config-params.xml"/>
               </p:input>
            </app:page-pkg-put>
         </p:otherwise>
      </p:choose>
   </p:group>

</p:pipeline>
