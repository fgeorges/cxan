<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:pkg="http://expath.org/ns/pkg"
           xmlns:web="http://expath.org/ns/webapp"
           xmlns:app="http://cxan.org/ns/website"
           xmlns:exist="http://exist.sourceforge.net/NS/exist"
           exclude-inline-prefixes="c pkg exist"
           version="1.0"
           pkg:import-uri="##none">

   <!--
       Usable when a step is required but without any input/output.
       
       For instance in a p:catch when the p:try/p:group has no output.
   -->
   <p:declare-step type="app:empty">
      <!-- cannot be completely empty, or it is treated as a *declaration* only -->
      <p:identity>
         <p:input port="source">
            <p:empty/>
         </p:input>
      </p:identity>
      <p:sink/>
   </p:declare-step>

   <!--
       Throws an error, with a proper title, message, and other infos.
       
       This is the central piece in the error handling machanism, still to
       define precisely.
       
       TODO: Error handling machanism, still to define precisely!
       
       TODO: Enable the ability to give an input to p:error, through an input
       to this step.
   -->
   <p:declare-step type="app:error" name="error">
      <!-- the error code, an NCName in the app space -->
      <p:option name="code"    required="true"/>
      <!-- the error title, can contain '{' and '}' as in p:template -->
      <p:option name="title"   required="true"/>
      <!-- the error message, can contain '{' and '}' as in p:template -->
      <p:option name="message" required="true"/>
      <!-- additional input to add in the error document -->
      <p:input  port="source" primary="true" sequence="true"/>
      <!-- the parameters used in '{...}' replacements in $title and $message -->
      <p:input  port="parameters" kind="parameter" primary="true"/>
      <!-- the "output" of the resulting p:error -->
      <p:output port="result" primary="true"/>
      <!-- create the error title template -->
      <p:template name="title-tpl">
         <p:input port="source">
            <p:empty/>
         </p:input>
         <p:input port="template">
            <p:inline><app:title>{ $title }</app:title></p:inline>
         </p:input>
         <p:with-param name="title" select="$title"/>
      </p:template>
      <!-- format the error title -->
      <p:template name="title">
         <p:input port="parameters">
            <p:pipe step="error" port="parameters"/>
         </p:input>
         <p:input port="source">
            <p:empty/>
         </p:input>
         <p:input port="template">
            <p:pipe step="title-tpl" port="result"/>
         </p:input>
      </p:template>
      <!-- create the error message template -->
      <p:template name="message-tpl">
         <p:input port="source">
            <p:empty/>
         </p:input>
         <p:input port="template">
            <p:inline><app:message>{ $message }</app:message></p:inline>
         </p:input>
         <p:with-param name="message" select="$message"/>
      </p:template>
      <!-- format the error message -->
      <p:template name="message">
         <p:input port="parameters">
            <p:pipe step="error" port="parameters"/>
         </p:input>
         <p:input port="source">
            <p:empty/>
         </p:input>
         <p:input port="template">
            <p:pipe step="message-tpl" port="result"/>
         </p:input>
      </p:template>
      <!-- wrap the title, the message, and the additional documents into app:error -->
      <p:wrap-sequence wrapper="app:error">
         <p:input port="source">
            <p:pipe step="title"   port="result"/>
            <p:pipe step="message" port="result"/>
            <p:pipe step="error"   port="source"/>
         </p:input>
      </p:wrap-sequence>
      <!-- add @code to app:error -->
      <p:add-attribute match="/*" attribute-name="code" name="desc">
         <p:with-option name="attribute-value" select="$code"/>
      </p:add-attribute>
      <!-- actually throw the error -->
      <p:error>
         <p:with-option name="code" select="concat('app:', $code)"/>
         <p:input port="source">
            <p:pipe step="desc" port="result"/>
         </p:input>
      </p:error>
   </p:declare-step>

   <!--
       Return a page doc in case of error.
       
       Seems to be used only by pages/search.xproc because it is not implemented yet...
       TODO: What is its relationships with error-handler.xproc?
   -->
   <p:declare-step type="app:error-page">
      <p:option name="message" required="true"/>
      <p:option name="code"    required="true"/>
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:xslt template-name="main">
         <p:input port="stylesheet">
            <p:inline>
               <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                               xmlns:xs="http://www.w3.org/2001/XMLSchema"
                               xmlns:ser="http://fgeorges.org/xslt/serial"
                               version="2.0">
                  <xsl:import href="http://fgeorges.org/ns/xslt/serial.xsl"/>
                  <xsl:import href="http://fgeorges.org/ns/xslt/serial-html.xsl"/>
                  <xsl:param name="msg"  as="xs:string"/>
                  <xsl:param name="code" as="xs:string"/>
                  <xsl:template name="main">
                     <page http-code="{ $code }" http-message="{ $msg }">
                        <title>Error</title>
                        <para>
                           <xsl:value-of select="$msg"/>
                        </para>
                        <code>
                           <xsl:sequence select="ser:serialize-to-html(.)"/>
                        </code>
                     </page>
                  </xsl:template>
               </xsl:stylesheet>
            </p:inline>
         </p:input>
         <p:with-param name="msg"  select="$message"/>
         <p:with-param name="code" select="$code"/>
      </p:xslt>
   </p:declare-step>

   <!--
       Ensure the request method is one among the accepted methods.
       
       If the method is valid, nothing happens, if it is not an error is thrown.  The
       input port is the web:request.  This step is a pass-through, the output port is
       also the web:request (unless the method does not match, in that case that's an
       error an the step never "returns").
   -->
   <p:declare-step type="app:ensure-method" name="check">
      <!-- the set of accepted methods, comma-separated -->
      <p:option name="accepted" required="true"/>
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <!-- the actual method -->
      <p:variable name="method" select="/web:request/@method">
         <p:pipe port="source" step="check"/>
      </p:variable>
      <p:choose>
         <p:when test="not($method = tokenize($accepted, '\s*,\s*'))">
            <app:error code="ERR001" title="Unsupported HTTP method"
                       message="The method '{ $m }' is not supported, must be one of: '{ $a }'.">
               <p:with-param name="m" select="$method"/>
               <p:with-param name="a" select="$accepted"/>
            </app:error>
         </p:when>
         <p:otherwise>
            <p:identity/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

   <!--
       Ensure a value is existent and different than the zero-length string.
       
       The string to test is passed as the option value.  If $value is valid, nothing
       happens, if it is not an error is thrown.  The input port can be anything, this
       step is a pass-through, the input port is copied to the output port (unless
       $value is not valid, in that case that's an error an the step never "returns").
   -->
   <p:declare-step type="app:ensure-value">
      <!-- the value to check -->
      <p:option name="value" required="true"/>
      <!-- a short description for the value, to use in the error message -->
      <p:option name="desc"  required="true"/>
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:choose>
         <p:when test="not($value)">
            <app:error code="ERR006" title="Required value not passed"
                       message="The value '{ $d }' is not set, though it is required.">
               <p:with-param name="d" select="$desc"/>
            </app:error>
         </p:when>
         <p:otherwise>
            <p:identity/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

   <!--
       Wrap the source XML to be returned out of the web framework.
       
       Basically, it is wrapped within a web:response element, and within a web:body
       element with the XML content-type.  This can then be returned straight to
       Servlex which will returned it to the client.
       
       If the source is an exist:result element, it first unwraps its content.
   -->
   <p:declare-step type="app:wrap-xml-result">
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:unwrap match="/exist:result"/>
      <p:wrap match="/" wrapper="web:body"/>
      <p:add-attribute attribute-name="content-type" attribute-value="application/xml"
                       match="/web:body"/>
      <p:wrap match="/" wrapper="web:response"/>
      <p:add-attribute attribute-name="status"  attribute-value="200" match="/web:response"/>
      <p:add-attribute attribute-name="message" attribute-value="Ok"  match="/web:response"/>
   </p:declare-step>

</p:library>
