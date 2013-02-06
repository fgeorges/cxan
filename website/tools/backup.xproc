<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:proj="http://expath.org/ns/project"
            xmlns:tools="http://cxan.org/ns/website/tools"
            xmlns:exist="http://exist.sourceforge.net/NS/exist"
            xmlns:http="http://expath.org/ns/http-client"
            name="pipeline"
            version="1.0">

   <!-- Should be able to configure the URI for eXist from here... -->
   <!--p:import href="../src/tools.xpl"/-->

   <p:variable name="base" select="static-base-uri()"/>

   <p:http-request>
      <p:input port="source">
         <p:inline>
            <!-- TODO: FIXME: Configure the credentials and endpoint! -->
            <c:request method="post" auth-method="Basic" send-authorization="true"
                       username="cxan" password="someprivatepassword"
                       href="http://cxan.org:8020/exist/rest/">
               <c:body content-type="application/xml">
                  <exist:query>
                     <exist:text>
                        &lt;docs> {
                          for $doc in collection('/db/cxan/') return
                            &lt;doc>{ document-uri($doc) }&lt;/doc>
                        }
                        &lt;/docs>
                     </exist:text>
                  </exist:query>
               </c:body>
            </c:request>
         </p:inline>
      </p:input>
   </p:http-request>

   <p:for-each>
      <p:iteration-source select="/exist:result/docs/doc"/>
      <p:variable name="to" select="resolve-uri(substring(., 2), $base)"/>
      <!-- TODO: Error if it does not end with *.xml (this is the assumption for now...) -->
      <p:template>
         <p:with-param name="uri" select="string(.)"/>
         <p:input port="template">
            <p:inline>
               <!-- TODO: FIXME: Configure the credentials and endpoint! -->
               <c:request method="post" auth-method="Basic" send-authorization="true"
                          username="cxan" password="someprivatepassword"
                          href="http://cxan.org:8020/exist/rest/">
                  <c:body content-type="application/xml">
                     <exist:query>
                        <exist:text>
                           doc('{ $uri }')
                        </exist:text>
                     </exist:query>
                  </c:body>
               </c:request>
            </p:inline>
         </p:input>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
      </p:template>
      <p:http-request/>
      <p:unwrap match="/exist:result"/>
      <p:store>
         <p:with-option name="href" select="$to"/>
      </p:store>
   </p:for-each>

   <p:load>
      <p:with-option name="href" select="resolve-uri('db/cxan/packages.xml', $base)"/>
   </p:load>

   <p:xslt>
      <p:input port="stylesheet">
         <p:inline>
            <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
               <xsl:template match="/">
                  <files>
                     <xsl:text>&#10;</xsl:text>
                     <xsl:for-each select="//file">
                        <xsl:value-of select="."/>
                        <xsl:text>&#10;</xsl:text>
                     </xsl:for-each>
                  </files>
               </xsl:template>
            </xsl:stylesheet>
         </p:inline>
      </p:input>
      <p:input port="parameters">
         <p:empty/>
      </p:input>
   </p:xslt>

</p:pipeline>
