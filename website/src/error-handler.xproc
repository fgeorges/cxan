<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:web="http://expath.org/ns/webapp"
                xmlns:app="http://cxan.org/ns/website"
                xmlns:exist="http://exist.sourceforge.net/NS/exist"
                pkg:import-uri="http://cxan.org/website/error-handler.xproc"
                name="pipeline"
                version="1.0">

   <!--
       TODO: Review and define exactly the error handling mechanism.  What is its
       relationships with app:error-page in tools.xpl? (which by the way seems to be
       used only by pages/search.xproc because it is not implemented yet...)
   -->

   <!-- TODO: sequence="true" is because it might be not connected for now, as the error
        mechanism in Servlex is not implemented yet, waiting for a fix in Calabash -->
   <p:input  port="source"    primary="true" sequence="true"/>
   <p:input  port="user-data" sequence="true"/>
   <p:output port="result"    primary="true"/>

   <p:option name="web:code-name"      required="true"/>
   <p:option name="web:code-namespace" required="true"/>
   <p:option name="web:message"        required="true"/>

   <p:variable name="accept" select="/web:request/web:header[@name eq 'accept']/@value"/>

   <p:count>
      <p:input port="source">
         <p:pipe step="pipeline" port="user-data"/>
      </p:input>
   </p:count>

   <p:choose name="data">
      <p:when test="number(.) eq 0">
         <p:output port="result"/>
         <p:identity>
            <p:input port="source">
               <p:empty/>
            </p:input>
         </p:identity>
      </p:when>
      <p:otherwise>
         <p:output port="result"/>
         <p:wrap-sequence wrapper="web:user-data">
            <p:input port="source">
               <p:pipe step="pipeline" port="user-data"/>
            </p:input>
         </p:wrap-sequence>
      </p:otherwise>
   </p:choose>

   <p:template name="msg">
      <p:input port="source">
         <p:empty/>
      </p:input>
      <p:input port="template">
         <p:inline><web:message>{ $msg }</web:message></p:inline>
      </p:input>
      <p:with-param name="msg" select="$web:message"/>
   </p:template>

   <p:wrap-sequence wrapper="web:error">
      <p:input port="source">
         <p:pipe step="msg"  port="result"/>
         <p:pipe step="data" port="result"/>
      </p:input>
   </p:wrap-sequence>
   <p:add-attribute attribute-name="code" match="/*">
      <p:with-option name="attribute-value" select="$web:code-name"/>
   </p:add-attribute>
   <p:add-attribute attribute-name="code-namespace" match="/*">
      <p:with-option name="attribute-value" select="$web:code-namespace"/>
   </p:add-attribute>

   <p:choose>
      <p:when test="$accept eq 'application/xml'">
         <p:wrap wrapper="web:body" match="/*"/>
         <p:add-attribute attribute-name="content-type" attribute-value="application/xml" match="/*"/>
         <p:wrap wrapper="web:response" match="/*"/>
         <!-- TODO: What status and message...? -->
         <p:add-attribute attribute-name="status"  attribute-value="400"         match="/*"/>
         <p:add-attribute attribute-name="message" attribute-value="Bad Request" match="/*"/>
      </p:when>
      <p:otherwise>
         <p:xslt>
            <p:input port="stylesheet">
               <p:inline>
                  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                  xmlns:xs="http://www.w3.org/2001/XMLSchema"
                                  xmlns:app="http://cxan.org/ns/website"
                                  xmlns:ser="http://fgeorges.org/xslt/serial"
                                  version="2.0">
                     <xsl:import href="http://fgeorges.org/ns/xslt/serial.xsl"/>
                     <xsl:import href="http://fgeorges.org/ns/xslt/serial-html.xsl"/>
                     <xsl:template match="/web:error">
                        <page http-code="400" http-message="Bad Request">
                           <title>Oops</title>
                           <para>
                              <xsl:value-of select="
                                  if ( exists(web:user-data/app:error) ) then
                                    web:user-data/app:error/app:title
                                  else
                                    'Something went wrong...'"/>
                           </para>
                           <named-info>
                              <row>
                                 <name>Error code</name>
                                 <info>
                                    <xsl:value-of select="@code"/>
                                 </info>
                              </row>
                              <row>
                                 <name>Error code NS</name>
                                 <info>
                                    <xsl:value-of select="@code-namespace"/>
                                 </info>
                              </row>
                              <row>
                                 <name>Error message</name>
                                 <info>
                                    <xsl:value-of select="
                                        if ( exists(web:user-data/app:error) ) then
                                          web:user-data/app:error/app:message
                                        else
                                          web:message"/>
                                 </info>
                              </row>
                           </named-info>
                           <xsl:if test="exists(web:user-data)">
                              <code>
                                 <xsl:sequence select="ser:serialize-to-html(web:user-data)"/>
                              </code>
                           </xsl:if>
                        </page>
                     </xsl:template>
                  </xsl:stylesheet>
               </p:inline>
            </p:input>
            <p:input port="parameters">
               <p:empty/>
            </p:input>
         </p:xslt>
      </p:otherwise>
   </p:choose>

</p:declare-step>
