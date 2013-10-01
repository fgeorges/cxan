<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/upload.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>
   <p:import href="../upload-lib.xpl"/>

   <p:declare-step type="app:page-upload-unauthenticated">
      <p:output port="result" primary="true"/>
      <p:identity>
         <p:input port="source">
            <p:inline>
               <web:response status="401" message="Unauthorized">
                  <web:header name="WWW-Authenticate" value='BASIC realm="CXAN website"'/>
               </web:response>
            </p:inline>
         </p:input>
      </p:identity>
   </p:declare-step>

   <p:declare-step type="app:page-upload-prepare-file" name="prepare">
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
         <p:variable name="filename" select="
             /web:request
               / web:multipart
               / web:header[ @body eq $pos ][ @name eq 'content-disposition' ]
               / web:parse-header-value(@value)
                   / web:element[@name eq 'form-data']
                   / web:param[@name eq 'filename']
                   / @value"/>
         <p:sink/>
         <p:choose>
            <p:when test="$filename[.]">
               <p:split-sequence name="body">
                  <p:with-option name="test" select="concat('position() eq ', ( $pos[.], -1 )[1])">
                     <p:empty/>
                  </p:with-option>
                  <p:input port="source">
                     <p:pipe step="request" port="not-matched"/>
                  </p:input>
               </p:split-sequence>
               <p:add-attribute match="/c:data" attribute-name="filename">
                  <p:with-option name="attribute-value" select="$filename"/>
               </p:add-attribute>
               <p:split-sequence test="exists(/*/node())"/>
            </p:when>
            <p:otherwise>
               <p:identity>
                  <p:input port="source">
                     <p:empty/>
                  </p:input>
               </p:identity>
            </p:otherwise>
         </p:choose>
      </p:group>
   </p:declare-step>

   <p:declare-step type="app:page-upload-get">
      <p:output port="result" primary="true"/>
      <p:identity>
         <p:input port="source">
            <p:inline>
               <page menu="upload">
                  <title>Upload a package</title>
                  <form xmlns="http://www.w3.org/1999/xhtml"
                        method="post" enctype="multipart/form-data" action="upload">
                     <fieldset>
                        <label style="display: block; padding-top: 10px; padding-bottom: 5px">
                           CXAN ID <em>(optional)</em>
                        </label>
                        <input type="text" class="text" maxlength="64" name="id" value=""/>
                        <label style="display: block; padding-top: 10px; padding-bottom: 5px">Package</label>
                        <input type="file" size="64" name="xar"/>
                        <input style="margin-left: 20px" type="submit" class="submit" value="Upload"/>
                        <label style="display: block; padding-top: 10px; padding-bottom: 5px">Additional file 1</label>
                        <input type="file" size="64" name="file01"/>
                        <label style="display: block; padding-top: 10px; padding-bottom: 5px">Additional file 2</label>
                        <input type="file" size="64" name="file02"/>
                        <label style="display: block; padding-top: 10px; padding-bottom: 5px">Additional file 3</label>
                        <input type="file" size="64" name="file03"/><br/>
                        <input type="checkbox" name="different-name" value="update"/>
                        <label style="padding-top: 10px; padding-bottom: 5px">Trying to update a package with
                           an existing CXAN ID but a different package name (the package URI) is an error.  By
                           ticking this checkbox, you ask explicitely to update the package anyway.  This is
                           useful when a package has changed its URI (a very bad practice), but you want to keep
                           the same CXAN ID).</label>
                     </fieldset>
                  </form>
               </page>
            </p:inline>
         </p:input>
      </p:identity>
   </p:declare-step>

   <p:declare-step type="app:page-upload-post" name="this">
      <p:input  port="source" primary="true" sequence="true"/>
      <p:output port="result" primary="true"/>
      <!--
          The lib step takes c:data elements with @filename
          The POST has several bodies:
            1/ the CXAN ID
            2/ the XAR file
            */ additional files
      -->
      <p:split-sequence test="position() eq 1" name="request">
         <p:input port="source">
            <p:pipe step="this" port="source"/>
         </p:input>
      </p:split-sequence>
      <p:group>
         <p:variable name="cxan-id-pos" select="
             /web:request
               / web:multipart
               / web:header
                   [ @name eq 'content-disposition' ]
                   [ web:parse-header-value(@value)
                       / web:element[@name eq 'form-data']
                       / web:param[@name eq 'name']
                       / @value
                       eq 'id' ]
               / @body"/>
         <p:sink/>
         <p:split-sequence>
            <p:with-option name="test" select="concat('position() eq ', ( $cxan-id-pos[.], -1 )[1])">
               <p:empty/>
            </p:with-option>
            <p:input port="source">
               <p:pipe step="request" port="not-matched"/>
            </p:input>
         </p:split-sequence>
         <p:group>
            <!--
                This is the ID passed from the HTML form.  It will be extracted from
                cxan.xml by app:upload-package if it does not exist.
            -->
            <p:variable name="cxan-id" select="normalize-space(.)"/>
            <!--
                TODO: Pass the whole input sequence to app:page-upload-prepare-file, no
                need to split it directly and pass every result to every call.  Pass the
                whole input sequence and let the step do what it wants with it...
            -->
            <p:for-each>
               <p:iteration-source>
                  <p:inline><part>xar</part></p:inline>
                  <p:inline><part>file01</part></p:inline>
                  <p:inline><part>file02</part></p:inline>
                  <p:inline><part>file03</part></p:inline>
               </p:iteration-source>
               <app:page-upload-prepare-file>
                  <p:with-option name="part-name" select="string(.)"/>
                  <p:input port="source">
                     <p:pipe step="this" port="source"/>
                  </p:input>
               </app:page-upload-prepare-file>
            </p:for-each>
            <!-- call the library step -->
            <app:upload-package>
               <p:input port="parameters">
                  <p:document href="../../../../config-params.xml"/>
               </p:input>
               <p:with-option name="pkg-id" select="$cxan-id">
                  <p:empty/>
               </p:with-option>
               <!-- TODO: Get the value from the form... -->
               <p:with-option name="different-name" select="'error'">
                  <p:empty/>
               </p:with-option>
            </app:upload-package>
            <!-- result page -->
            <p:identity>
               <p:input port="source">
                  <p:inline>
                     <page>
                        <title>Congrats</title>
                        <!--
                            TODO: Add informations about the packae (ID, name, ...)
                            TODO: AND THE LINK TO THE PACKAGE PAGE...!!!
                        -->
                        <para>The package has been successfuly uploaded!</para>
                     </page>
                  </p:inline>
               </p:input>
            </p:identity>
         </p:group>
      </p:group>
   </p:declare-step>

   <!-- FIXME: What?  An element?  Not a document, really?!? -->
   <p:split-sequence test=". instance of element(web:request)" name="request"/>

   <app:ensure-method accepted="get,post"/>

   <!--
       TODO: Use a filter to add the authentication to a page!
   -->
   <p:group>
      <!-- credentials -->
      <p:variable name="auth" select="/web:request/web:header[@name eq 'authorization']/@value"/>
      <p:choose>
         <p:when test="$auth">
            <!-- gotta call it twice, because XProc does not support XDM values...! -->
            <p:variable name="user"       select="web:parse-basic-auth($auth)/@username"/>
            <p:variable name="given-pwd"  select="web:parse-basic-auth($auth)/@password"/>
            <p:variable name="config-pwd" select="doc('../../../../config-users.xml')/users/user[@name eq $user]/@password"/>
            <p:choose>
               <!-- not authenticated -->
               <p:when test="not($user) or not($given-pwd) or not($config-pwd) or not($given-pwd eq $config-pwd)">
                  <p:sink/>
                  <app:page-upload-unauthenticated/>
               </p:when>
               <!-- a GET -->
               <p:when test="/web:request/@method eq 'get'">
                  <p:sink/>
                  <app:page-upload-get/>
               </p:when>
               <!-- a POST (we have already checked as "get,post") -->
               <p:otherwise>
                  <app:page-upload-post>
                     <p:input port="source">
                        <p:pipe step="pipeline" port="source"/>
                     </p:input>
                  </app:page-upload-post>
               </p:otherwise>
            </p:choose>
         </p:when>
         <!-- if no Authorization header at all -->
         <p:otherwise>
            <p:sink/>
            <app:page-upload-unauthenticated/>
         </p:otherwise>
      </p:choose>
   </p:group>

</p:pipeline>
