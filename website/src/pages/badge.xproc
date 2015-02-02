<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            pkg:import-uri="http://cxan.org/website/pages/badge.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>
   <p:import href="../data-access/data-access.xpl"/>

   <!--
       Implementation.
   -->
   <p:declare-step type="app:page-badge">
      <p:option name="repo" required="true"/>
      <p:option name="pkg"  required="true"/>
      <p:output port="result" primary="true"/>
      <da:package-badge>
         <p:with-option name="repo" select="$repo"/>
         <p:with-option name="pkg"  select="$pkg"/>
      </da:package-badge>
      <!-- TODO: Handle the case where no file is found. -->
      <p:template>
         <p:input port="parameters">
            <p:empty/>
         </p:input>
         <p:input port="template">
            <p:inline>
               <web:response status="200" message="Ok">
                  <web:body content-type="{ ( /*/@mime/string(.), 'application/octet-stream' )[1] }"
                            src="{ string(.) }"/>
               </web:response>
            </p:inline>
         </p:input>
      </p:template>
   </p:declare-step>

   <!-- the repo -->
   <p:variable name="repo" select="/web:request/web:path/web:match[@name eq 'repo']"/>
   <!-- the pkg -->
   <p:variable name="pkg"  select="/web:request/web:path/web:match[@name eq 'pkg']"/>

   <app:ensure-method accepted="get"/>

   <p:choose>
      <p:when test="empty($repo[.])">
         <app:error code="invalid-rest-params" title="Param repo is mandatory"
                    message="The badge service must have at least a repo (repo='{$r}', pkg='{$p}')">
            <p:with-param name="r" select="$repo"/>
            <p:with-param name="p" select="$pkg"/>
         </app:error>         
      </p:when>
      <p:otherwise>
         <app:page-badge>
            <p:with-option name="repo" select="$repo"/>
            <p:with-option name="pkg"  select="$pkg"/>
         </app:page-badge>
      </p:otherwise>
   </p:choose>

</p:pipeline>
