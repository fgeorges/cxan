<p:library  xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:cx="http://xmlcalabash.com/ns/extensions"
            xmlns:cxan="http://cxan.org/ns/package"
            xmlns:client="http://cxan.org/ns/client"
            xmlns:pkg="http://expath.org/ns/pkg"
            pkg:import-uri="#none"
            version="1.0">

   <!--
       ...
       
           <success/>
       
       XML output in case of error (TODO: this is the same for all actions, they
       should be detected and treated all the same way...):
       
           <error code="ERR000">
              <title>Error title</title>
              <message>Error description.</message>
           </error>
   -->

   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
   <p:import href="../tools.xpl"/>

   <p:declare-step type="client:do-upload" name="pipeline">
      <p:input port="parameters" kind="parameter" primary="true"/>
      <p:output port="result" primary="true"/>
      <p:option name="xar"    required="true"/>
      <p:option name="files"  required="true"/>
      <p:option name="pkg-id" required="true"/>
      <p:choose>
         <p:when test="not($xar)">
            <!-- Cannot happen if called from the shell script, but we never know... -->
            <client:error code="client:ERR003" msg="Parameter 'xar' not passed."/>
         </p:when>
         <p:when test="not($pkg-id)">
            <cx:unzip file="cxan.xml" name="unzip">
               <p:with-option name="href" select="$xar"/>
            </cx:unzip>
            <p:group>
               <p:variable name="id" select="/cxan:package/@id">
                  <p:pipe step="unzip" port="result"/>
               </p:variable>
               <client:http-put>
                  <p:with-option name="id"    select="$id"/>
                  <p:with-option name="xar"   select="$xar"/>
                  <p:with-option name="files" select="$files"/>
               </client:http-put>
            </p:group>
         </p:when>
         <p:otherwise>
            <client:http-put>
               <p:with-option name="id"    select="$pkg-id"/>
               <p:with-option name="xar"   select="$xar"/>
               <p:with-option name="files" select="$files"/>
            </client:http-put>
         </p:otherwise>
      </p:choose>
   </p:declare-step>

   <!--
       TODO: To document...
       
       TODO: WRT the additional files (aka release files, etc.), add the ability
       to give them a name, in order to display that name in the interface.
       
       The input params.  Can only have a param 'xar' (mandatory) which is a
       file path pointing at the XAR/XAW file, a param 'pkg-id' (optional) which
       is a package ID to override the one in cxan.xml (mandatory when the XAR
       does not contain a cxan.xml), and a param 'files' (optional) which is a
       newline-separated list of file paths, pointing at additional file to
       upload (like a release ZIP file, source archive, etc.)
   -->
   <p:declare-step type="client:upload" name="pipeline">
      <p:input port="parameters" kind="parameter" primary="true"/>
      <p:output port="result" primary="true"/>
      <!-- Must be either 'text' or 'xml'. -->
      <p:option name="output" required="true"/>
      <p:wrap-sequence wrapper="wrapper">
         <p:input port="source">
            <p:pipe step="pipeline" port="parameters"/>
         </p:input>
      </p:wrap-sequence>
      <p:group>
         <p:variable name="xar"    select="/wrapper/c:param-set/c:param[@name eq 'xar']/@value"/>
         <p:variable name="files"  select="/wrapper/c:param-set/c:param[@name eq 'files']/@value"/>
         <p:variable name="pkg-id" select="/wrapper/c:param-set/c:param[@name eq 'pkg-id']/@value"/>
         <client:do-upload>
            <p:with-option name="xar"    select="$xar"/>
            <p:with-option name="files"  select="$files"/>
            <p:with-option name="pkg-id" select="$pkg-id"/>
         </client:do-upload>
         <!--p:choose>
            <p:when test="$output eq 'xml'">
               <p:identity/>
            </p:when>
            <p:otherwise>
               <client:upload-stdout/>
            </p:otherwise>
         </p:choose-->
      </p:group>
   </p:declare-step>

</p:library>
