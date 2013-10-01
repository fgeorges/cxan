<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/admin/export.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../../tools.xpl"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <app:query-exist>
      <p:input port="source">
         <p:inline>
            <c:data>
               &lt;documents> {
                 for $doc in collection('/db/cxan/')
                 return
                   &lt;doc uri="{ document-uri($doc) }"> {
                     $doc
                   }
                   &lt;/doc>
               }
               &lt;/documents>
            </c:data>
         </p:inline>
      </p:input>
   </app:query-exist>

   <app:wrap-xml-result/>

</p:pipeline>
