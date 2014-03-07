<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:pkg="http://expath.org/ns/pkg"
           xmlns:app="http://cxan.org/ns/website"
           xmlns:edb="http://cxan.org/ns/website/exist-db"
           xmlns:exist="http://exist.sourceforge.net/NS/exist"
           exclude-inline-prefixes="pkg exist"
           version="1.0"
           pkg:import-uri="##none">

   <p:import href="../tools.xpl"/>

   <p:declare-step type="edb:configure-exist-request" name="config">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Get a c:request document and add the eXist credentials and endpoint
            URI.</p>
         <p>The endpoint is the instance REST endpoint. The optional 'uri' option is
            the path to be added to this endpoint. It can start with a slash or not, it is anyway
            concatenated to the REST endpoint.</p>
      </p:documentation>
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>      
      <p:option name="uri" select="''"/>
      <p:template name="attrs">
         <p:input port="template">
            <p:inline>
               <dummy auth-method="Basic"
                      send-authorization="true"
                      username="{ $exist-user }"
                      password="{ $exist-pwd }"
                      href="{ $exist-rest }{ $path }"/>
            </p:inline>
         </p:input>
         <p:input port="parameters">
            <p:document href="../../../../config-params.xml"/>
         </p:input>
         <p:with-param name="path" select="
             if ( starts-with($uri, '/') ) then substring($uri, 2) else $uri"/>
      </p:template>
      <p:set-attributes match="/c:request">
         <p:input port="source">
            <p:pipe step="config" port="source"/>
         </p:input>
         <p:input port="attributes">
            <p:pipe step="attrs" port="result"/>
         </p:input>
      </p:set-attributes>
   </p:declare-step>

   <p:declare-step type="edb:query-exist-with" name="with">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Send a query to eXist and return the payload.</p>
         <p>The query to send to eXist is in the file pointed to by the option
            "module". This option is the name of a module contained in the "data-access/modules/"
            directory. The name of a module is the name of the file wihout the extension. For
            instance, to use the module "data-access/modules/foobar.xquery", use the value "foobar"
            for this option.</p>
         <p><b>TODO</b>: Would be nice to add "declarative validation" (using named
            schemas to apply to the result of the query).</p>
         <p><b>TODO</b>: Check that the module name actually resolves to a module on
            the file system.</p>
      </p:documentation>
      <p:input  port="parameters" primary="true" kind="parameter"/>
      <p:output port="result"     primary="true"/>
      <p:option name="module" required="true"/>
      <p:variable name="regex" select="'[a-z]+(-[a-z]+)?'"/>
      <p:choose>
         <p:when test="not(matches($module, $regex))">
            <app:error code="EXISTDB001" title="Invalid module name"
                       message="The module name '{ $m }' is invalid, it does not match the regex '{ $r }'.">
               <p:with-param name="m" select="$module"/>
               <p:with-param name="r" select="$regex"/>
               <p:input port="source">
                  <p:empty/>
               </p:input>
            </app:error>
         </p:when>
         <p:otherwise>
            <p:variable name="resolved" select="concat('modules/', $module, '.xquery')"/>
            <!-- there is no p:load-text, so the trick is to use unparsed-text() from XSLT -->
            <!-- good candidate for PipX -->
            <p:xslt template-name="main">
               <p:with-param name="module" select="$resolved"/>
               <p:input port="stylesheet">
                  <p:inline>
                     <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                        <xsl:param name="module" required="yes"/>
                        <xsl:template name="main">
                           <edb:loaded-text>
                              <xsl:sequence select="unparsed-text($module)"/>
                           </edb:loaded-text>
                        </xsl:template>
                     </xsl:stylesheet>
                  </p:inline>
               </p:input>
               <p:input port="source">
                  <p:empty/>
               </p:input>
            </p:xslt>
         </p:otherwise>
      </p:choose>
      <edb:query-exist>
         <p:input port="parameters">
            <p:pipe port="parameters" step="with"/>
         </p:input>
      </edb:query-exist>
   </p:declare-step>

   <p:declare-step type="edb:query-exist" name="exist">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Send a query to eXist and return the payload.</p>
         <p>The source port is an XQuery query, as text. It must be a valid query. The
            text value of the source is used as the query text.</p>
         <p>This step returns the exist:result document.</p>
         <p>The parameters passed to this step are used to replace strings of the form
            "@@.param.@@", where "param" is the name of one parameter, and the whole string
            (inckuding the 4 "@" and the 2 dots) is replaced by the corresponding parameter
            value.</p>
         <p><b>TODO</b>: Add windowing support, through new options.</p>
      </p:documentation>
      <p:input  port="source"     primary="true"/>
      <p:input  port="parameters" primary="true" kind="parameter"/>
      <p:output port="result"     primary="true"/>
      <p:xslt>
         <p:input port="source">
            <p:pipe step="exist" port="source"/>
            <p:pipe step="exist" port="parameters"/>
         </p:input>
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               xmlns:my="internal-cxan-impl"
                               version="2.0">
                  <xsl:function name="my:replace" as="xs:string">
                     <xsl:param name="val"    as="xs:string"/>
                     <xsl:param name="params" as="element(c:param)*"/>
                     <xsl:choose>
                        <xsl:when test="exists($params)">
                           <xsl:variable name="p" select="$params[1]"/>
                           <xsl:sequence select="
                              my:replace(
                                replace($val, concat('@@.', $p/@name, '.@@'), $p/@value),
                                remove($params, 1))"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <xsl:sequence select="$val"/>
                        </xsl:otherwise>
                     </xsl:choose>
                  </xsl:function>
                  <xsl:template match="/">
                     <xsl:variable name="query" select="
                         my:replace(., collection()[2]/c:param-set/c:param)"/>
                     <c:request method="post">
                        <c:body content-type="application/xml">
                           <exist:query>
                              <exist:text>
                                 <xsl:value-of select="$query"/>
                              </exist:text>
                           </exist:query>
                        </c:body>
                     </c:request>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </p:xslt>
      <edb:configure-exist-request/>
      <p:http-request/>
      <!-- TODO: Check the errors (e.g. query parse error, eXist not started, authentication
           error, etc. - in the later case eXist returns an empty octet-stream response). -->
      <!-- TODO: Add conditional logging of the request and response (in debug mode). -->
   </p:declare-step>

   <p:declare-step type="edb:insert-doc">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>Insert a new doc into the database.</p>
         <p>The doc is in the input port 'source'. It is inserted at the URI 'uri'. If
            a document already exists at that URI, it is replaced.</p>
      </p:documentation>
      <p:option name="uri" required="true"/>
      <p:input port="source" primary="true"/>
      <p:wrap wrapper="c:body" match="/"/>
      <p:add-attribute match="/c:body"
                       attribute-name="content-type"
                       attribute-value="application/xml"/>
      <p:wrap wrapper="c:request" match="/"/>
      <p:add-attribute match="/c:request" attribute-name="method" attribute-value="put"/>
      <edb:configure-exist-request>
         <p:log href="/tmp/calabash-http.log" port="result"/>
         <p:with-option name="uri" select="$uri"/>
      </edb:configure-exist-request>
      <p:http-request>
         <p:log href="/tmp/insert.log" port="result"/>
      </p:http-request>
      <!-- TODO: Check the errors... -->
      <p:sink/>
   </p:declare-step>

</p:library>
