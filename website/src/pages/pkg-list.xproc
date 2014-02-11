<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/pkg-list.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <!--
       Get the package list for the /pkg page.
       
       If the name URI param is there, restrict the list to the packages with
       that name.  If there is only one such package, send a HTTP redirect to
       the page of that package.
       
       TODO: Add support for windowing.
   -->
   <p:declare-step type="app:pkg-list" name="pkg-list">
      <p:option name="name" required="true"/>
      <p:output port="result" primary="true"/>
      <p:choose>
         <!-- Note: I don't know why, but $name[.] does NOT work... -->
         <p:when test="exists($name) and $name ne ''">
            <p:variable name="name-str" select="replace($name, '''', '''''')"/>
            <p:identity>
               <p:input port="source">
                  <p:inline>
                     <c:data>
                        let $name := '<app:name/>'
                        return
                          &lt;packages name="{ $name }"> {
                            for $pkg in doc('/db/cxan/packages.xml')/packages/pkg[name eq $name]
                            order by $pkg/@id
                            return
                              &lt;pkg>
                                &lt;id>{ string($pkg/@id) }&lt;/id>
                                {
                                  let $ver := ( for $v in $pkg/version/@id order by $v descending return $v )[1]
                                  let $uri := concat('/db/cxan/packages/', $pkg/@id, '/', $ver, '/cxan.xml')
                                  let $abs := doc($uri)/cxan:package/cxan:abstract
                                  return
                                    if ( exists($abs) ) then
                                      &lt;desc>{ normalize-space($abs) }&lt;/desc>
                                    else
                                      ()
                                }
                              &lt;/pkg>
                          }
                          &lt;/packages>
                     </c:data>
                  </p:inline>
               </p:input>
            </p:identity>
            <!-- paste the package id within the query -->
            <p:string-replace match="app:name">
               <p:with-option name="replace" select="concat('''', $name-str, '''')"/>
            </p:string-replace>
         </p:when>
         <p:otherwise>
            <p:identity>
               <p:input port="source">
                  <p:inline>
                     <c:data>
                        declare namespace cxan = "http://cxan.org/ns/package";
                        &lt;packages> {
                          for $pkg in doc('/db/cxan/packages.xml')/packages/pkg
                          order by $pkg/@id
                          return
                            &lt;pkg>
                              &lt;id>{ string($pkg/@id) }&lt;/id>
                              &lt;name>{ string($pkg/name) }&lt;/name>
                              {
                                let $ver := ( for $v in $pkg/version/@id order by $v descending return $v )[1]
                                let $uri := concat('/db/cxan/packages/', $pkg/@id, '/', $ver, '/cxan.xml')
                                let $abs := doc($uri)/cxan:package/cxan:abstract
                                return
                                  if ( exists($abs) ) then
                                    &lt;desc>{ normalize-space($abs) }&lt;/desc>
                                  else
                                    ()
                              }
                            &lt;/pkg>
                        }
                        &lt;/packages>
                     </c:data>
                  </p:inline>
               </p:input>
            </p:identity>
         </p:otherwise>
      </p:choose>
      <!-- send the query to the database -->
      <!-- TODO: Check the result! -->
      <app:query-exist/>
   </p:declare-step>

   <!--
       The main processing.
   -->

   <p:variable name="accept"     select="/web:request/web:header[@name eq 'accept']/@value"/>
   <p:variable name="name-param" select="/web:request/web:param[@name eq 'name']/@value"/>
   <p:variable name="base-uri"   select="/c:param-set/c:param[@name eq 'home-uri']/@value">
      <p:document href="../../../../config-params.xml"/>
   </p:variable>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <!-- retrieve the packages id and name from eXist -->
   <app:pkg-list>
      <p:with-option name="name" select="$name-param"/>
   </app:pkg-list>

   <p:choose>
      <p:when test="$accept eq 'application/xml'">
         <!-- return the raw XML -->
         <app:wrap-xml-result/>
      </p:when>
      <p:otherwise>
         <!-- format the data to a page document -->
         <p:xslt name="result">
            <p:input port="stylesheet">
               <p:document href="pkg-list.xsl"/>
            </p:input>
            <p:with-param name="base-uri" select="$base-uri"/>
         </p:xslt>
      </p:otherwise>
   </p:choose>

</p:pipeline>
