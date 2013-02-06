<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:cx="http://xmlcalabash.com/ns/extensions"
            xmlns:pxp="http://exproc.org/proposed/steps"
            xmlns:pxf="http://exproc.org/proposed/steps/file"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            pkg:import-uri="http://cxan.org/website/pages/pkg.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
   <p:import href="../tools.xpl"/>
   <p:import href="../upload-lib.xpl"/>

   <!--
       Implementation in case of a GET.
   -->
   <p:declare-step type="app:page-pkg-get">
      <p:option name="id"     required="true"/>
      <p:option name="accept" required="true"/>
      <p:output port="result" primary="true"/>
      <!-- retrieve the pkg element from eXist, given its ID -->
      <!-- TODO: Due to a bug in Calabash (svn r649, 0.9.28), p:template is not
           suitable here, see my email on the XProc Dev mailing list:
           http://xproc.markmail.org/thread/zb6ndcdphjb5y74h.  Use it when fixed. -->
      <p:variable name="id-str" select="replace($id, '''', '''''')"/>
      <p:identity>
         <p:input port="source">
            <p:inline>
               <c:data>
                  declare variable $id := '<app:id/>';
                  let $p := doc('/db/cxan/packages.xml')/packages/pkg[@id eq $id]
                  (: TODO: Sort not as a string, but as a SemVer instead. :)
                  let $v := ( for $v_ in $p/version/@id order by $v_ descending return $v_ )[1]
                  let $c := concat('/db/cxan/packages/', $id, '/')
                  return
                    &lt;package> {
                      $p,
                      (: Return the latest cxan.xml, but the package descriptor for every
                         version (to describe the dependencies for each version, for
                         instance).  But the cxan.xml info are for the entire package. :)
                      (: TODO: This explicit loop is a work around the bug I reported at
                         http://exist.markmail.org/thread/vqn2ojcpfxcl6syf in eXist SVN
                         pre-1.5. :)
                      for $v_ in $p/version/@id return
                        doc(concat($c, $v_, '/expath-pkg.xml')),
                      doc(concat($c, $v, '/cxan.xml'))
                    }
                    &lt;/package>
               </c:data>
            </p:inline>
         </p:input>
      </p:identity>
      <!-- paste the package id within the query -->
      <p:string-replace match="app:id">
         <p:log href="/tmp/yo1.log" port="result"/>
         <!-- the *value* of this option is an XPath expression, in this case a
              literal string, that is, the quoted string "'the-id'" -->
         <p:with-option name="replace" select="concat('''', $id-str, '''')"/>
      </p:string-replace>
      <!-- send the request to eXist -->
      <app:query-exist>
         <p:log href="/tmp/yo2.log" port="result"/>
      </app:query-exist>
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
                  <p:document href="../config-params.xml"/>
               </p:input>
            </app:page-pkg-put>
         </p:otherwise>
      </p:choose>
   </p:group>

</p:pipeline>
