<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/about.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <p:identity>
      <p:input port="source">
         <p:inline>
            <page menu="about">
               <title>About</title>
               <para>For more information about CXAN, you can ask the
                  <link uri="http://expath.org/lists">EXPath mailing
                  list</link>.</para>
            </page>
         </p:inline>
      </p:input>
   </p:identity>

</p:pipeline>
