<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            xmlns:da="http://cxan.org/ns/website/data-access"
            pkg:import-uri="http://cxan.org/website/pages/admin/export.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../../tools.xpl"/>
   <p:import href="../../data-access/data-access.xpl"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <da:suck-database/>

   <app:wrap-xml-result/>

</p:pipeline>
