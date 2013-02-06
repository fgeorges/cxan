<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:c="http://www.w3.org/ns/xproc-step"
           xmlns:err="http://www.w3.org/ns/xproc-error"
           xmlns:cx="http://xmlcalabash.com/ns/extensions"
           xmlns:pxp="http://exproc.org/proposed/steps"
           xmlns:pxf="http://exproc.org/proposed/steps/file"
           xmlns:pkg="http://expath.org/ns/pkg"
           xmlns:web="http://expath.org/ns/webapp"
           xmlns:app="http://cxan.org/ns/website"
           xmlns:cxan="http://cxan.org/ns/package"
           xmlns:exist="http://exist.sourceforge.net/NS/exist"
           pkg:import-uri="##none"
           version="1.0">

   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

   <!--
       Main entry point.  Get the XAR and additional files and update the website.
       
       Get the files on port "source".  The first one must be the XAR,
       additional files can be provided.  Each of them is a c:data element
       base64-encoded, with an attribute @filename.
   -->
   <p:declare-step type="app:upload-package" name="upl">
      <!-- the files (including the XAR), each with @filename -->
      <p:input port="source" sequence="true" primary="true"/>
      <!-- the config parameters -->
      <p:input  port="parameters" kind="parameter" primary="true"/>
      <!-- the CXAN ID -->
      <p:option name="pkg-id" required="true"/>
      <!-- what to do if the package name has changed for the same CXAN ID? -->
      <p:option name="different-name" required="true"/>      
      <!-- extract parameters (TODO: check they are there) -->
      <p:wrap-sequence wrapper="wrapper">
         <p:input port="source">
            <p:pipe step="upl" port="parameters"/>
         </p:input>
      </p:wrap-sequence>
      <p:group>
         <p:variable name="staging-area" select="/wrapper/c:param-set/c:param[@name eq 'staging-area']/@value"/>
         <p:variable name="files-area"   select="/wrapper/c:param-set/c:param[@name eq 'files-area']/@value"/>
         <p:sink/>
         <!-- compute the temporary file name -->
         <!-- TODO: Use pxf:tempfile instead. -->
         <p:uuid match="app:placeholder" name="uuid">
            <p:input port="source">
               <p:inline>
                  <root>
                     <app:placeholder/>
                  </root>
               </p:inline>
            </p:input>
         </p:uuid>
         <!-- First we save the XAR in a tmp location, in order to extract some
              info out of it (used among other things to check everything is ok to
              put files in their final destination).  The remainder of the sequence
              (if any, the additional files in a multipart PUT) is saved later on,
              directly in the final dest. -->
         <p:split-sequence test="position() eq 1" name="split">
            <p:input port="source">
               <p:pipe port="source" step="upl"/>
            </p:input>
         </p:split-sequence>
         <p:group>
            <p:variable name="filename" select="/c:data/@filename"/>
            <!-- store the first body, this is the XAR -->
            <p:store cx:decode="true" name="store">
               <p:with-option name="href" select="
                   resolve-uri(concat(normalize-space(.), '.bin'), $staging-area)">
                  <p:pipe step="uuid" port="result"/>
               </p:with-option>
            </p:store>
            <p:group>
               <!-- where we save the XAR -->
               <p:variable name="tmp-file" select="/xs:string(c:result)">
                  <p:pipe step="store" port="result"/>
               </p:variable>
               <!-- validate the package and extract both descriptors -->
               <app:validate-package name="validate">
                  <p:with-option name="href" select="$tmp-file"/>
               </app:validate-package>
               <!-- do it! -->
               <app:record-package>
                  <p:input port="source">
                     <p:pipe step="validate" port="expath-pkg"/>
                  </p:input>
                  <p:input port="cxan">
                     <p:pipe step="validate" port="cxan"/>
                  </p:input>
                  <p:input port="files">
                     <p:pipe port="not-matched" step="split"/>
                  </p:input>
                  <p:with-option name="pkg-id"         select="$pkg-id"/>
                  <p:with-option name="different-name" select="$different-name"/>
                  <p:with-option name="href"           select="$tmp-file"/>
                  <p:with-option name="filename"       select="$filename"/>
                  <p:with-option name="files-area"     select="$files-area"/>
               </app:record-package>
            </p:group>
         </p:group>
      </p:group>
   </p:declare-step>

<!--
    TODO: Tmp notes...
    
    Create a step "validate-package", option $href, no input, 2 outputs (expath-pkg.xml +
    cxan.xml), extracts the descriptors from the XAR, validate them, validate the XAR
    structure, and throw clear message in case of error...
    
    The step could be reused in a "validate package" action in the UI...
-->
   <p:declare-step type="app:validate-package" name="this">
      <!-- the package descriptor -->
      <p:output port="expath-pkg">
         <p:pipe step="pkg" port="result"/>
      </p:output>
      <!-- the CXAN descriptor -->
      <p:output port="cxan">
         <p:pipe step="cxan" port="result"/>
      </p:output>
      <!-- the location on disk of the package XAR file -->
      <p:option name="href" required="true"/>
      <!-- extract the package descriptor -->
      <app:extract-descriptor descriptor="expath-pkg.xml" name="pkg">
         <p:with-option name="href" select="$href"/>
         <p:input port="source">
            <p:document href="schemas/expath-pkg.xsd"/>
         </p:input>
      </app:extract-descriptor>
      <!-- extract the CXAN descriptor -->
      <app:extract-descriptor descriptor="cxan.xml" name="cxan">
         <p:with-option name="href" select="$href"/>
         <p:input port="source">
            <p:document href="schemas/cxan.xsd"/>
         </p:input>
      </app:extract-descriptor>
      <!-- TODO: Validate the structure of the package as well. -->
      <!-- ... -->
   </p:declare-step>

   <p:declare-step type="app:extract-descriptor" name="this">
      <!-- the schema to validate the descriptor against -->
      <p:input port="source"/>
      <!-- the validated descriptor -->
      <p:output port="result"/>
      <!-- the location on disk of the package XAR file -->
      <p:option name="href"       required="true"/>
      <!-- the filename of the descriptor within the XAR file -->
      <p:option name="descriptor" required="true"/>
      <!-- extract the descriptor out of the XAR file -->
      <pxp:unzip>
         <p:with-option name="file" select="$descriptor"/>
         <p:with-option name="href" select="$href"/>
      </pxp:unzip>
      <p:try>
         <p:group>
            <!-- validate -->
            <p:validate-with-xml-schema assert-valid="true">
               <p:input port="schema">
                  <p:pipe step="this" port="source"/>
               </p:input>
            </p:validate-with-xml-schema>
         </p:group>
         <p:catch name="catch">
            <app:error code="ERR010"
                       title="Descriptor not valid"
                       message="The descriptor '{ $d }' is not valid.">
               <p:with-param name="d" select="$descriptor"/>
               <p:input port="source">
                  <p:pipe step="catch" port="error"/>
               </p:input>
            </app:error>
         </p:catch>
      </p:try>
   </p:declare-step>

   <!--
       Check the package descriptor, update the database and handle the files.
       
       The package descriptor is passed on port "source".  The files are
       passed on port "files".  The package itself is located at $href (in the
       staging-area, will be moved to $target).  The c:data element with the
       files content (on port "files") must have been augmented with a new
       attribute @filename.
   -->
   <p:declare-step type="app:record-package" name="record">
      <!-- the package descriptor -->
      <p:input port="source" primary="true"/>
      <!-- the CXAN descriptor -->
      <p:input port="cxan"/>
      <!-- the additional files, as c:data documents, base64 encoded -->
      <p:input port="files"  sequence="true"/>
      <!-- the config parameters -->
      <p:input  port="parameters" kind="parameter" primary="true"/>
      <!-- the CXAN id of the pkg this file belongs to (if empty, look into cxan.xml) -->
      <p:option name="pkg-id"         required="true"/>
      <!-- the location on disk of the package XAR file -->
      <p:option name="href"           required="true"/>
      <!-- the filename to use for the XAR file -->
      <p:option name="filename"       required="true"/>
      <!-- the directory where to save files -->
      <p:option name="files-area"     required="true"/>
      <!-- what to do if the package name has changed for the same CXAN ID? -->
      <p:option name="different-name" required="true"/>
      <p:variable name="cxan-id"  select="
          if ( exists($pkg-id[.]) ) then $pkg-id else /cxan:package/@id">
         <p:pipe step="record" port="cxan"/>
      </p:variable>
      <p:variable name="version"  select="/pkg:package/@version"/>
      <p:variable name="file"     select="concat($cxan-id, '/', $filename)"/>
      <p:variable name="target"   select="resolve-uri($file, $files-area)"/>
      <app:ensure-pkg-for-put>
         <p:with-option name="id"             select="$cxan-id"/>
         <p:with-option name="name"           select="/pkg:package/@name"/>
         <p:with-option name="version"        select="$version"/>
         <p:with-option name="different-name" select="$different-name"/>
      </app:ensure-pkg-for-put>
      <!-- create the package dir if it does not exist -->
      <pxf:mkdir fail-on-error="false">
         <p:with-option name="href" select="resolve-uri($cxan-id, $files-area)"/>
      </pxf:mkdir>
      <!-- move the file from the staging area to its final destination -->
      <!-- TODO: Maybe make a copy instead, and scan from time to time the staging area
           to check every file has been correctly inserted and then remove them. -->
      <pxf:move>
         <p:with-option name="href"   select="$href"/>
         <p:with-option name="target" select="$target"/>
      </pxf:move>
      <!-- insert the version descriptor in /db/cxan/packages.xml -->
      <app:insert-new-version>
         <p:with-option name="id"      select="$cxan-id"/>
         <p:with-option name="version" select="$version"/>
         <p:with-option name="file"    select="$file"/>
      </app:insert-new-version>
      <!-- save additional files, from a multipart request -->
      <p:for-each>
         <p:iteration-source>
            <p:pipe step="record" port="files"/>
         </p:iteration-source>
         <app:save-and-add-file>
            <p:with-option name="files-area"  select="$files-area"/>
            <p:with-option name="pkg-id"      select="$cxan-id"/>
            <p:with-option name="pkg-version" select="$version"/>
         </app:save-and-add-file>
      </p:for-each>
      <app:insert-doc>
         <p:input port="source">
            <p:pipe step="record" port="source"/>
         </p:input>
         <p:with-option name="uri" select="
             concat('/db/cxan/packages/', $cxan-id, '/', $version, '/expath-pkg.xml')"/>
      </app:insert-doc>
      <p:try>
         <p:group>
            <pxp:unzip file="cxan.xml" name="unzip-cxan">
               <p:with-option name="href" select="$target"/>
            </pxp:unzip>
            <app:insert-doc>
               <p:input port="source">
                  <p:pipe step="unzip-cxan" port="result"/>
               </p:input>
               <p:with-option name="uri" select="
                   concat('/db/cxan/packages/', $cxan-id, '/', $version, '/cxan.xml')"/>
            </app:insert-doc>
         </p:group>
         <p:catch>
            <!-- pxp:unzip throw an error if cxan.xml does not exist: ignore -->
            <app:empty/>
         </p:catch>
      </p:try>
      <app:tweet-upload>
         <p:with-option name="pkg-id"  select="$cxan-id"/>
         <p:with-option name="version" select="$version"/>
      </app:tweet-upload>
   </p:declare-step>

   <!--
       Store a file and record it in the database.
       
       The file is passed as a c:data element (base64 encoded) on port
       "source".  It must have an attribute @filename.
   -->
   <p:declare-step type="app:save-and-add-file">
      <!-- the directory where to save it -->
      <p:option name="files-area"  required="true"/>
      <!-- the CXAN id of the pkg this file belongs to -->
      <p:option name="pkg-id"      required="true"/>
      <!-- the version of the pkg this file belongs to -->
      <p:option name="pkg-version" required="true"/>
      <!-- a c:data document with the base64 encoding of the file to save -->
      <p:input port="source" primary="true"/>
      <!-- the file name as in the header -->
      <p:variable name="filename" select="/c:data/@filename"/>
      <!-- the path of the file, relative to $files-area -->
      <p:variable name="path" select="concat($pkg-id, '/', $filename)"/>
      <!-- store it on disk (decoding base64...) -->
      <p:store cx:decode="true">
         <p:with-option name="href" select="resolve-uri($path, $files-area)"/>
      </p:store>
      <!--
          TODO: Give files a name ('package' for the XAR/XAW, 'release' for the
          ZIP, etc.)  That can be done by giving a name to each part of the
          multipart.
      -->
      <!-- update the database -->
      <p:template>
         <p:input port="template">
            <p:inline>
               <c:data>
                  declare variable $id      := '{ $id }';
                  declare variable $version := '{ $version }';
                  declare variable $file    := '{ $file }';
                  let $pkg := doc('/db/cxan/packages.xml')/packages/pkg[@id eq $id]
                  let $ver := $pkg/version[@id eq $version]
                  return
                    update insert &lt;file>{{ $file }}&lt;/file> into $ver
               </c:data>
            </p:inline>
         </p:input>
         <p:input port="source">
            <p:empty/>
         </p:input>
         <p:with-param name="id"      select="replace($pkg-id, '''', '''''')"/>
         <p:with-param name="version" select="replace($pkg-version, '''', '''''')"/>
         <p:with-param name="file"    select="replace($path, '''', '''''')"/>
      </p:template>
      <!-- do it! -->
      <app:query-exist/>
      <!-- TODO: Check the result! -->
      <p:sink/>
   </p:declare-step>

   <!--
       Ensure the package is in the database to add a new version.
       
       If the package does not exist (based on its ID), the corresponding package
       element, without any version element, is inserted.  If it exists (based on
       its ID), it is an error if the name does not match, or if the version to
       be added already exists.
       
       Note: The package 'name' could be used by another abbrev.  For instance
       the EXPath HTTP Client can have both IDs expath-http-client-saxon and
       expath-http-client-exist.
   -->
   <p:declare-step type="app:ensure-pkg-for-put">
      <p:option name="id"             required="true"/>
      <p:option name="name"           required="true"/>
      <p:option name="version"        required="true"/>
      <p:option name="different-name" required="true"/>
      <!-- get the pkg id+version -->
      <p:template>
         <p:input port="template">
            <p:inline>
               <c:data>
                  let $p := doc('/db/cxan/packages.xml')/packages/pkg[@id eq '{ $id }']
                  return
                    if ( empty(doc('/db/cxan/packages.xml')) ) then
                      &lt;no-doc/>
                    else if ( exists($p) ) then
                      &lt;pkg> {{
                        $p/name,
                        $p/version[@id eq '{ $version }']
                      }}
                      &lt;/pkg>
                    else
                      ()
               </c:data>
            </p:inline>
         </p:input>
         <p:input port="source">
            <p:empty/>
         </p:input>
         <!-- escape the single quotes in the values (there shouldn't be any, but just
              in case, we still want a well-formed query) -->
         <p:with-param name="id"      select="replace($id, '''', '''''')"/>
         <p:with-param name="version" select="replace($version, '''', '''''')"/>
      </p:template>
      <!-- send the request to eXist -->
      <app:query-exist>
         <p:log href="/tmp/yo-yo.log" port="result"/>
      </app:query-exist>
      <!-- check the result -->
      <p:choose>
         <!-- 1. if the packages.xml doc does not exist, create it (+ the pkg) -->
         <p:when test="exists(exist:result/no-doc)">
            <p:template>
               <p:input port="template">
                  <p:inline>
                     <packages>
                        <pkg id="{ $id }">
                           <name>{ $name }</name>
                        </pkg>
                     </packages>
                  </p:inline>
               </p:input>
               <p:input port="source">
                  <p:empty/>
               </p:input>
               <p:with-param name="id"   select="$id"/>
               <p:with-param name="name" select="$name"/>
            </p:template>
            <app:insert-doc uri="/db/cxan/packages.xml"/>
         </p:when>
         <!-- 2. if the pkg does not exist, create it (w/o any version) -->
         <p:when test="empty(exist:result/pkg)">
            <p:template>
               <p:input port="template">
                  <p:inline>
                     <c:data>
                        let $p := &lt;pkg id="{ $id }">
                                     &lt;name>{ $name }&lt;/name>
                                  &lt;/pkg>
                        return
                          update insert $p into doc('/db/cxan/packages.xml')/packages
                     </c:data>
                  </p:inline>
               </p:input>
               <p:input port="source">
                  <p:empty/>
               </p:input>
               <p:with-param name="id"   select="$id"/>
               <p:with-param name="name" select="$name"/>
            </p:template>
            <app:query-exist/>
            <p:sink/>
         </p:when>
         <!-- 3. if the version exists -> error -->
         <!-- TODO: Create a way to override it instead. -->
         <p:when test="exists(exist:result/pkg/version)">
            <app:error code="ERR003"
                       title="Uploading the same package version"
                       message="Trying to upload the version '{ $ver }' of package '{ $id }', which already exists.">
               <p:with-param name="id"  select="$id"/>
               <p:with-param name="ver" select="$version"/>
            </app:error>
            <p:sink/>
         </p:when>
         <!-- 4.a if the name is not the same -> error if asked (the default) -->
         <p:when test="exist:result/pkg/name ne $name and $different-name eq 'error'">
            <app:error code="ERR004"
                       title="Uploading the same package with a different name"
                       message="Trying to upload package '{ $new }' instead of '{ $old }'.">
               <p:with-param name="new" select="$name"/>
               <p:with-param name="old" select="exist:result/pkg/name"/>
            </app:error>
            <p:sink/>
         </p:when>
         <!-- 4.b if the name is not the same -> update if asked -->
         <p:when test="exist:result/pkg/name ne $name and $different-name eq 'update'">
            <app:update-pkg-name>
               <p:with-option name="id"   select="$id"/>
               <p:with-option name="name" select="$name"/>
            </app:update-pkg-name>
         </p:when>
         <!-- 5. otherwise, nothing -->
         <p:otherwise>
            <app:empty/>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

   <!--
       Update the name of a package.
   -->
   <p:declare-step type="app:update-pkg-name">
      <p:option name="id"   required="true"/>
      <p:option name="name" required="true"/>
      <!-- 1. get the pkg id+version -->
      <!-- TODO: Due to a bug in Calabash (svn r649, 0.9.28), p:document-template
           is not suitable here, see my email on the XProc Dev mailing list:
           http://xproc.markmail.org/thread/zb6ndcdphjb5y74h. -->
      <p:variable name="id-str"   select="replace($id, '''', '''''')"/>
      <p:variable name="name-str" select="replace($name, '''', '''''')"/>
      <p:identity>
         <p:input port="source">
            <p:inline>
               <c:data>
                  declare variable $id   := '<app:id/>';
                  declare variable $name := '<app:name/>';
                  let $p := doc('/db/cxan/packages.xml')/packages/pkg[@id eq $id]
                  return
                    update value $p/name with $name
               </c:data>
            </p:inline>
         </p:input>
      </p:identity>
      <!-- paste the package id within the query -->
      <p:string-replace match="app:id">
         <p:with-option name="replace" select="concat('''', $id-str, '''')"/>
      </p:string-replace>
      <!-- paste the name within the query -->
      <p:string-replace match="app:name">
         <p:with-option name="replace" select="concat('''', $name-str, '''')"/>
      </p:string-replace>
      <!-- send the request to eXist -->
      <app:query-exist/>
      <!-- TODO: Check the result! -->
      <p:sink/>
   </p:declare-step>

   <!--
       Insert a new package version into the database.
       
       The corresponding package element must already exist and be consistent
       with the version to add (see app:ensure-pkg-for-put).
   -->
   <p:declare-step type="app:insert-new-version">
      <p:option name="id"      required="true"/>
      <p:option name="version" required="true"/>
      <p:option name="file"    required="true"/>
      <!-- 1. get the pkg id+version -->
      <!-- TODO: Due to a bug in Calabash (svn r649, 0.9.28), p:document-template
           is not suitable here, see my email on the XProc Dev mailing list:
           http://xproc.markmail.org/thread/zb6ndcdphjb5y74h. -->
      <p:variable name="id-str"      select="replace($id, '''', '''''')"/>
      <p:variable name="version-str" select="replace($version, '''', '''''')"/>
      <p:variable name="file-str"    select="replace($file, '''', '''''')"/>
      <p:identity>
         <p:input port="source">
            <p:inline>
               <c:data>
                  declare variable $id      := '<app:id/>';
                  declare variable $version := '<app:version/>';
                  declare variable $file    := '<app:file/>';
                  let $p := doc('/db/cxan/packages.xml')/packages/pkg[@id eq $id]
                  let $v := &lt;version id="{ $version }">
                               &lt;file>{ $file }&lt;/file>
                            &lt;/version>
                  return
                    update insert $v into $p
               </c:data>
            </p:inline>
         </p:input>
      </p:identity>
      <!-- paste the package id within the query -->
      <p:string-replace match="app:id">
         <p:with-option name="replace" select="concat('''', $id-str, '''')"/>
      </p:string-replace>
      <!-- paste the version within the query -->
      <p:string-replace match="app:version">
         <p:with-option name="replace" select="concat('''', $version-str, '''')"/>
      </p:string-replace>
      <!-- paste the file within the query -->
      <p:string-replace match="app:file">
         <p:with-option name="replace" select="concat('''', $file-str, '''')"/>
      </p:string-replace>
      <!-- send the request to eXist -->
      <app:query-exist/>
      <!-- TODO: Check the result! -->
      <p:sink/>
   </p:declare-step>

   <!--
       Send a tweet for the new upload.
       
       TODO: We should be able to disable it, e.g. for localhost...
   -->
   <p:declare-step type="app:tweet-upload" name="tweet">
      <!-- the config parameters -->
      <p:input  port="parameters" kind="parameter" primary="true"/>
      <!-- the CXAN id of the uploaded pkg -->
      <p:option name="pkg-id"  required="true"/>
      <!-- the version number of the uploaded pkg -->
      <p:option name="version" required="true"/>
      <!-- extract parameters (TODO: check they are there) -->
      <p:wrap-sequence wrapper="wrapper">
         <p:input port="source">
            <p:pipe step="tweet" port="parameters"/>
         </p:input>
      </p:wrap-sequence>
      <p:group>
         <p:variable name="home-uri"        select="/wrapper/c:param-set/c:param[@name eq 'home-uri']/@value"/>
         <p:variable name="user-token"      select="/wrapper/c:param-set/c:param[@name eq 'user-token']/@value"/>
         <p:variable name="user-secret"     select="/wrapper/c:param-set/c:param[@name eq 'user-secret']/@value"/>
         <p:variable name="consumer-key"    select="/wrapper/c:param-set/c:param[@name eq 'consumer-key']/@value"/>
         <p:variable name="consumer-secret" select="/wrapper/c:param-set/c:param[@name eq 'consumer-secret']/@value"/>
         <!-- TODO: Check the length of the status, and add the package description is enough room
              for it (might have to truncate it...) -->
         <p:variable name="status" select="
             concat(
               'Package &quot;',
               $pkg-id,
               '&quot;, version ',
               $version,
               ' just uploaded: ',
               $home-uri,
               'pkg/',
               $pkg-id,
               ' #cxan #expath')"/>
         <p:sink/>
         <p:choose>
            <p:when test="$user-token[.]">
               <p:xslt template-name="twit:tweet" xmlns:twit="http://cxan.org/ns/website/twitter">
                  <p:input port="stylesheet">
                     <p:document href="tweet.xsl"/>
                  </p:input>
                  <p:input port="source">
                     <p:empty/>
                  </p:input>
                  <p:input port="parameters">
                     <p:empty/>
                  </p:input>
                  <p:with-param name="status"          select="$status"/>
                  <p:with-param name="user-token"      select="$user-token"/>
                  <p:with-param name="user-secret"     select="$user-secret"/>
                  <p:with-param name="consumer-key"    select="$consumer-key"/>
                  <p:with-param name="consumer-secret" select="$consumer-secret"/>
               </p:xslt>
               <p:choose>
                  <p:when test="empty(/success)">
                     <!-- TODO: Should not throw an error, but should returning a warning (to be
                          displayed on the website or included in the XML response). -->
                     <app:error code="ERR005"
                                title="Error tweeting the new upload">
                        <p:with-option name="message" select="string(.)"/>
                     </app:error>
                     <p:sink/>
                  </p:when>
                  <p:otherwise>
                     <p:sink/>
                  </p:otherwise>
               </p:choose>
            </p:when>
            <p:otherwise>
               <!-- we then assume we don't have to tweet -->
               <p:sink>
                  <p:input port="source">
                     <p:empty/>
                  </p:input>
               </p:sink>
            </p:otherwise>
         </p:choose>
      </p:group>
   </p:declare-step>

</p:library>
