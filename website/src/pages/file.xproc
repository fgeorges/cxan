<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/file.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <!--
       The file download service.
       
       The request path must be 'file/...'.  This step simply removes
       the 'file/' and then resolve the remainder relatively to the
       binary store directory.  It then returns the corresponding
       web:response, with a web:body/@src.
       
       In case the enpoint is 'file?...', it must have either the URI
       param 'id' or 'name' (one or the other), and the optional param
       'version'.
   -->

   <!--
       Implementation in case of the file name in the URI.
   -->
   <p:declare-step type="app:page-file-file">
      <p:option name="file" required="true"/>
      <p:output port="result" primary="true"/>
      <p:template name="attrs">
         <p:with-param name="file" select="$file"/>
         <p:with-param name="filename" select="substring-after($file, '/')"/>
         <p:input port="parameters">
            <p:document href="../config-params.xml"/>
         </p:input>
         <p:input port="source">
            <p:empty/>
         </p:input>
         <p:input port="template">
            <p:inline>
               <web:response status="200" message="Ok">
                  <web:header name="content-disposition"
                              value='attachment; filename="{ $filename }"'/>
                  <web:body content-type="application/octet-stream"
                            src="{ $files-area }{ $file }"/>
               </web:response>
            </p:inline>
         </p:input>
      </p:template>
   </p:declare-step>

   <!--
       Implementation in case of the id param.
   -->
   <p:declare-step type="app:page-file-id">
      <p:option name="id"      required="true"/>
      <p:option name="version" required="true"/>
      <p:output port="result" primary="true"/>
      <p:template>
         <p:input port="source">
            <p:empty/>
         </p:input>
         <p:input port="template">
            <p:inline>
               <c:data>
                  declare variable $id      := '{ $id }';
                  declare variable $version := '{ $version }';
                  let $p := doc('/db/cxan/packages.xml')/packages/pkg[@id eq $id]
                  let $v :=
                        if ( $version[.] ) then
                          $version
                        else
                          (: TODO: Sort not as a string, but as a SemVer instead. :)
                          ( for $v_ in $p/version/@id order by $v_ descending return $v_ )[1]
                  return
                    $p/version[@id eq $v]/file[1]
               </c:data>
            </p:inline>
         </p:input>
         <p:with-param name="id"      select="$id"/>
         <p:with-param name="version" select="$version"/>
      </p:template>
      <!-- send the request to eXist -->
      <app:query-exist>
         <p:log href="/tmp/yo-file-id.log" port="result"/>
      </app:query-exist>
      <!-- TODO: Handle the case where no file is found (no package with that version). -->
      <!-- read the file -->
      <app:page-file-file>
         <p:with-option name="file" select="/*/file"/>
      </app:page-file-file>
   </p:declare-step>

   <!--
       Implementation in case of the name param.
   -->
   <p:declare-step type="app:page-file-name">
      <p:option name="name"    required="true"/>
      <p:option name="version" required="true"/>
      <p:output port="result" primary="true"/>
      <p:template>
         <p:input port="source">
            <p:empty/>
         </p:input>
         <p:input port="template">
            <p:inline>
               <c:data>
                  declare variable $name    := '{ $name }';
                  declare variable $version := '{ $version }';
                  let $p := doc('/db/cxan/packages.xml')/packages/pkg[name eq $name]
                  let $v :=
                        if ( $version[.] ) then
                          $version
                        else
                          (: TODO: Sort not as a string, but as a SemVer instead. :)
                          ( for $v_ in $p/version/@id order by $v_ descending return $v_ )[1]
                  return
                    $p/version[@id eq $v]/file[1]
               </c:data>
            </p:inline>
         </p:input>
         <p:with-param name="name"    select="$name"/>
         <p:with-param name="version" select="$version"/>
      </p:template>
      <!-- send the request to eXist -->
      <app:query-exist>
         <p:log href="/tmp/yo-file-name.log" port="result"/>
      </app:query-exist>
      <!-- TODO: Handle the case where no file is found (no package with that version). -->
      <!-- read the file -->
      <app:page-file-file>
         <p:with-option name="file" select="/*/file"/>
      </app:page-file-file>
   </p:declare-step>

   <!-- the file -->
   <p:variable name="file" select="/web:request/web:path/web:match[@name eq 'file']"/>

   <!-- the id -->
   <p:variable name="id" select="/web:request/web:param[@name eq 'id']/@value"/>
   <!-- the name -->
   <p:variable name="name" select="/web:request/web:param[@name eq 'name']/@value"/>
   <!-- the version -->
   <p:variable name="version" select="/web:request/web:param[@name eq 'version']/@value"/>

   <app:ensure-method accepted="get"/>

   <p:choose>
      <p:when test="$file[.] and ($id, $name, $version)[.][1]">
         <app:error code="ERR007" title="Cannot have file params on a file endpoint"
                    message="Endpoint for '{ $f }' has params id: '{ $i }', name: '{ $n }' and version: '{ $v }'.">
            <p:with-param name="f" select="$file"/>
            <p:with-param name="i" select="$id"/>
            <p:with-param name="n" select="$name"/>
            <p:with-param name="v" select="$version"/>
         </app:error>         
      </p:when>
      <p:when test="$file[.]">
         <app:page-file-file>
            <p:with-option name="file" select="$file"/>
         </app:page-file-file>
      </p:when>
      <p:when test="$id[.] and $name[.]">
         <app:error code="ERR008" title="Cannot have both id and name params"
                    message="File service has both params id: '{ $i }' and name: '{ $n }'.">
            <p:with-param name="i" select="$id"/>
            <p:with-param name="n" select="$name"/>
         </app:error>         
      </p:when>
      <p:when test="$id[.]">
         <app:page-file-id>
            <p:with-option name="id"      select="$id"/>
            <p:with-option name="version" select="$version"/>
         </app:page-file-id>
      </p:when>
      <p:when test="$name[.]">
         <app:page-file-name>
            <p:with-option name="name"    select="$name"/>
            <p:with-option name="version" select="$version"/>
         </app:page-file-name>
      </p:when>
      <p:otherwise>
         <app:error code="ERR009" title="No file given on the file service"
                    message="File service has neither file name nor id or name params."/>
      </p:otherwise>
   </p:choose>

</p:pipeline>
