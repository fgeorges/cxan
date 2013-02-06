<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:proj="http://expath.org/ns/project"
                xmlns:tools="http://cxan.org/ns/website/tools"
                xmlns:exist="http://exist.sourceforge.net/NS/exist"
                xmlns:http="http://expath.org/ns/http-client"
                name="pipeline"
                version="1.0">

   <!-- get the current svn revision number -->
   <p:exec command="svnversion" result-is-xml="false">
      <p:input port="source">
         <p:empty/>
      </p:input>
   </p:exec>

   <p:group>

      <!-- put the revision into a variable, then forget p:exec output -->
      <p:variable name="revision" select="normalize-space(.)"/>
      <p:sink/>

      <!-- build the project package -->
      <p:xslt>
         <p:input port="source">
            <p:document href="../xproject/project.xml"/>
         </p:input>
         <p:input port="stylesheet">
            <p:document href="../xproject/package-project.xsl"/>
         </p:input>
         <p:with-param name="proj:revision" select="$revision"/>
      </p:xslt>
      <p:sink/>

      <!-- build the project release -->
      <!-- commented out, not needed for now -->
      <!--p:xslt>
         <p:input port="source">
            <p:document href="../xproject/project.xml"/>
         </p:input>
         <p:input port="stylesheet">
            <p:document href="http://expath.org/ns/project/release.xsl" pkg:kind="xslt"/>
         </p:input>
         <p:with-param name="proj:revision" select="$revision"/>
      </p:xslt-->

      <!-- undeploy the webapp -->
      <!-- TODO: configure the access point -->
      <p:http-request>
         <p:input port="source">
            <p:inline>
               <c:request status-only="true" detailed="true" method="get"
                          href="http://localhost:8090/servlex/manager/remove/cxan"/>
            </p:inline>
         </p:input>
      </p:http-request>
      <p:choose>
         <p:when test="/c:response/xs:integer(@status) eq 200">
            <p:identity/>
         </p:when>
         <p:otherwise>
            <p:error code="tools:ERR001"/>
         </p:otherwise>
      </p:choose>
      <p:choose>
         <p:when test="/c:response/xs:integer(@status) eq 200">
            <p:identity/>
         </p:when>
         <p:otherwise>
            <p:error code="tools:ERR001"/>
         </p:otherwise>
      </p:choose>
      <p:sink/>

      <!-- deploy the webapp -->
      <!--
          XProc (and at least Calabash) does not support to send binary as
          binary content.  It always has to be encoded as base64.  But the
          Apache fileupload lib does not handle Content-Transfer-Encoding, and
          thus not base64-encoded content neither.  Well, it saves the file
          correctly, except it saves the base64-encoded content...
          
          Because the deployer servlet uses this lib, I cannot use the XProc
          step bu I have to use the EXPath HTTP Client from within XSLT (because
          it enables me to just give a filename, and it sends it as is...)
          
          I kept the XProc step just in case below, commented out.
      -->
      <p:xslt template-name="main">
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               version="2.0">
                  <xsl:import href="http://expath.org/ns/http-client.xsl"/>
                  <xsl:template name="main">
                     <xsl:variable name="req" as="element()">
                        <!-- TODO: configure the access point -->
                        <http:request href="http://localhost:8090/servlex/manager/deploy"
                                      method="post">
                           <http:multipart media-type="multipart/form-data"
                                           boundary="soMe-bOunDarY-ThAt-WOnT-bE-ThErE">
                              <http:header name="Content-Disposition"
                                           value='form-data; name="xawfile"; filename="cxan-website-0.1.0pre.xaw"'/>
                              <http:body media-type="application/octet-stream"
                                         src="{ resolve-uri('../dist/cxan-website-0.1.0pre.xaw') }"/>
                           </http:multipart>
                        </http:request>
                     </xsl:variable>
                     <xsl:sequence select="http:send-request($req)[1]"/>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
         <p:input port="source">
            <p:empty/>
         </p:input>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </p:xslt>
      <p:choose>
         <p:when test="/http:response/xs:integer(@status) eq 200">
            <p:identity/>
         </p:when>
         <p:otherwise>
            <p:error code="tools:ERR001"/>
         </p:otherwise>
      </p:choose>
      <!--p:identity>
         <p:input port="source">
            <!- - TODO: Retrieve the version number from xproject/project.xml. - ->
            <p:data href="../dist/cxan-website-0.1.0pre.xaw"/>
         </p:input>
      </p:identity>
      <p:document-template>
         <p:input port="template">
            <p:inline>
               <c:request status-only="true" detailed="true" method="post"
                          href="http://localhost:8090/servlex/manager/deploy">
                  <c:multipart content-type="multipart/form-data"
                               boundary="soMe-bOunDarY-ThAt-WOnT-bE-ThErE">
                     <c:body content-type="application/octet-stream" encoding="base64"
                             disposition='form-data; name="xawfile"; filename="cxan-website-0.1.0pre.xaw"'>{ . }</c:body>
                  </c:multipart>
               </c:request>
            </p:inline>
         </p:input>
      </p:document-template>
      <p:http-request/>
      <p:choose>
         <p:when test="/c:response/xs:integer(@status) eq 200">
            <p:identity/>
         </p:when>
         <p:otherwise>
            <p:error code="tools:ERR001"/>
         </p:otherwise>
      </p:choose-->
      <p:sink/>

   </p:group>

</p:declare-step>
