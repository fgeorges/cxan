<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:client="http://cxan.org/ns/client"
                pkg:import-uri="http://cxan.org/client/xml-action.xproc"
                name="pipeline"
                version="1.0">

   <p:input port="parameters" kind="parameter" primary="true"/>

   <p:output port="result" primary="true"/>

   <p:option name="action" required="true"/>

   <p:import href="tools.xpl"/>
   <p:import href="actions/category.xproc"/>
   <p:import href="actions/resolve.xproc"/>
   <p:import href="actions/tag.xproc"/>
   <p:import href="actions/upload.xproc"/>

   <p:choose>
      <p:when test="$action eq 'category'">
         <client:category output="xml"/>
      </p:when>
      <p:when test="$action eq 'resolve'">
         <client:resolve output="xml"/>
      </p:when>
      <p:when test="$action eq 'tag'">
         <client:tag output="xml"/>
      </p:when>
      <p:when test="$action eq 'upload'">
         <client:upload output="xml"/>
      </p:when>
      <p:otherwise>
         <client:error code="client:ERR001">
            <p:with-option name="msg" select="concat('Unsupported action: ''', $action, '''')"/>
         </client:error>
      </p:otherwise>
   </p:choose>

</p:declare-step>
