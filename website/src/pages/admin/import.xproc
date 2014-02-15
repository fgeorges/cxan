<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            pkg:import-uri="http://cxan.org/website/pages/admin/import.xproc"
            name="pipeline"
            version="1.0">

   <!--
       Import a backup into the database.
       
       TODO: FIXME: Check that the collection is empty before restoring anything!
   -->

   <p:import href="../../tools.xpl"/>
   <p:import href="../../data-access/data-access.xpl"/>

   <!--
       TODO: Adapted from app:page-upload-prepare-file in upload.xproc,
       move it to tools.xpl.
   -->
   <p:declare-step type="app:page-import-get-file" name="get">
      <p:option name="part-name" required="true"/>
      <p:input  port="source" primary="true" sequence="true"/>
      <p:output port="result" sequence="true" primary="true"/>
      <p:split-sequence test=". instance of element(web:request)" name="request"/>
      <p:group>
         <p:variable name="pos" select="
             /web:request
               / web:multipart
               / web:header
                   [ @name eq 'content-disposition' ]
                   [ web:parse-header-value(@value)
                       / web:element[@name eq 'form-data']
                       / web:param[@name eq 'name']
                       / @value eq $part-name ]
               / @body"/>
         <p:sink/>
         <p:split-sequence name="body">
            <p:with-option name="test" select="concat('position() eq ', ( $pos[.], -1 )[1])">
               <p:empty/>
            </p:with-option>
            <p:input port="source">
               <p:pipe step="request" port="not-matched"/>
            </p:input>
         </p:split-sequence>
         <!--p:split-sequence test="exists(/*/node())"/-->
      </p:group>
   </p:declare-step>

   <!-- FIXME: What?  An element?  Not a document, really?!? -->
   <!-- Plus, app:ensure-method should be a pass-through for the
        entire input sequence... -->
   <p:split-sequence test=". instance of element(web:request)"/>

   <p:group>
      <p:variable name="accept" select="/web:request/web:header[@name eq 'accept']/@value"/>

      <app:ensure-method accepted="post"/>
      <p:sink/>

      <!--
          The first and only body, that is the second item in the input
          sequence, is the backup XML file.
          
          TODO: Make some checks here (we have exactly one body, it is a
          document node with root element 'documents' and children 'doc'
          elements, etc.)
      -->
      <app:page-import-get-file part-name="backup">
         <p:input port="source">
            <p:pipe step="pipeline" port="source"/>
         </p:input>
      </app:page-import-get-file>

      <da:restore-backup/>

      <p:choose>
         <p:when test="$accept eq 'application/xml'">
            <app:wrap-xml-result/>
         </p:when>
         <p:otherwise>
            <p:xslt>
               <p:input port="stylesheet">
                  <p:inline>
                     <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                                     xmlns:xs="http://www.w3.org/2001/XMLSchema"
                                     xmlns:exist="http://exist.sourceforge.net/NS/exist"
                                     version="2.0">
                        <xsl:template match="/exist:result/result">
                           <page menu="import">
                              <title>Import</title>
                              <para>Import successful.  The following collections and document
                                 have been created or updated:</para>
                              <list>
                                 <xsl:for-each select="created">
                                    <item>
                                       <xsl:value-of select="."/>
                                    </item>
                                 </xsl:for-each>
                              </list>
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
   </p:group>

</p:pipeline>
