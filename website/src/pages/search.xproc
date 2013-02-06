<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/search.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <app:ensure-method accepted="get"/>

   <!-- TODO: FIXME: Not implemented yet! -->
   <app:error-page code="501" message="Not implemented"/>

</p:pipeline>
