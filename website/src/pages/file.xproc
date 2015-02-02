<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            pkg:import-uri="http://cxan.org/website/pages/file.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

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
      Generate the web:response, given the full path to the file (on the server FS).
   -->
   <p:declare-step type="app:page-file-impl">
      <p:input  port="source" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:template>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
         <p:input port="template">
            <p:inline>
               <web:response status="200" message="Ok">
                  <web:header name="content-disposition"
                              value='attachment; filename="{ tokenize(., "/")[last()] }"'/>
                  <web:body content-type="{ ( /*/@mime/string(.), 'application/octet-stream' )[1] }"
                            src="{ string(.) }"/>
               </web:response>
            </p:inline>
         </p:input>
      </p:template>
   </p:declare-step>

   <!--
       Implementation in case of the file name in the URI.
   -->
   <p:declare-step type="app:page-file-file">
      <p:option name="repo" required="true"/>
      <p:option name="pkg"  required="true"/>
      <p:option name="file" required="true"/>
      <p:output port="result" primary="true"/>
      <da:package-file-by-file>
         <p:with-option name="repo" select="$repo"/>
         <p:with-option name="pkg"  select="$pkg"/>
         <p:with-option name="file" select="$file"/>
      </da:package-file-by-file>
      <!-- TODO: Handle the case where no file is found. -->
      <app:page-file-impl/>
   </p:declare-step>

   <!--
       Implementation in case of the id param.
   -->
   <p:declare-step type="app:page-file-id">
      <p:option name="id"      required="true"/>
      <p:option name="version" required="true"/>
      <p:output port="result" primary="true"/>
      <da:package-file-by-id>
         <p:with-option name="id"      select="$id"/>
         <p:with-option name="version" select="$version"/>
      </da:package-file-by-id>
      <!-- TODO: Handle the case where no file is found. -->
      <app:page-file-impl/>
   </p:declare-step>

   <!--
       Implementation in case of the name param.
   -->
   <p:declare-step type="app:page-file-name">
      <p:option name="name"    required="true"/>
      <p:option name="version" required="true"/>
      <p:output port="result" primary="true"/>
      <da:package-file-by-name>
         <p:with-option name="name"    select="$name"/>
         <p:with-option name="version" select="$version"/>
      </da:package-file-by-name>
      <!-- TODO: Handle the case where no file is found. -->
      <app:page-file-impl/>
   </p:declare-step>

   <!-- the repo -->
   <p:variable name="repo" select="/web:request/web:path/web:match[@name eq 'repo']"/>
   <!-- the pkg -->
   <p:variable name="pkg"  select="/web:request/web:path/web:match[@name eq 'pkg']"/>
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
      <p:when test="count(($repo, $pkg, $file)[.]) = (1, 2)">
         <app:error code="invalid-rest-params" title="Params repo, pkg and file must all be there together"
                    message="If params repo, pkg or file are given, all must be there, got: '{$r}', '{$p}' and '{$f}' resp.">
            <p:with-param name="r" select="$repo"/>
            <p:with-param name="p" select="$pkg"/>
            <p:with-param name="f" select="$file"/>
         </app:error>         
      </p:when>
      <p:when test="$file[.] and ($id, $name, $version)[.][1]">
         <app:error code="invalid-rest-params" title="Cannot have pkg and file params on a file endpoint"
                    message="Endpoint for '{$r}'/'{$p}'/'{$f}' has params id: '{$i}', name: '{$n}' and version: '{$v}'.">
            <p:with-param name="r" select="$repo"/>
            <p:with-param name="p" select="$pkg"/>
            <p:with-param name="f" select="$file"/>
            <p:with-param name="i" select="$id"/>
            <p:with-param name="n" select="$name"/>
            <p:with-param name="v" select="$version"/>
         </app:error>         
      </p:when>
      <p:when test="$file[.]">
         <app:page-file-file>
            <p:with-option name="repo" select="$repo"/>
            <p:with-option name="pkg"  select="$pkg"/>
            <p:with-option name="file" select="$file"/>
         </app:page-file-file>
      </p:when>
      <p:when test="$id[.] and $name[.]">
         <app:error code="invalid-rest-params" title="Cannot have both id and name params"
                    message="File service has both params id: '{$i}' and name: '{$n}'.">
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
         <app:error code="invalid-rest-params" title="No file given on the file service"
                    message="File service has neither file name nor id or name params."/>
      </p:otherwise>
   </p:choose>

</p:pipeline>
