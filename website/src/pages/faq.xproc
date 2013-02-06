<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/faq.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <p:identity>
      <p:input port="source">
         <p:inline>
            <page menu="faq">
               <title>FAQ</title>
               <subtitle>How can I add a new package to CXAN?</subtitle>
               <para>There is no public access to add new packages to CXAN. If you want to add a
                  library you wrote, or a webapp for Servlex, you can send an email to the <link
                     uri="http://expath.org/lists">EXPath mailing list</link> (or directly to
                  Florent Georges if you don't want to write to the mailing list for whatever
                  reason).</para>
            </page>
         </p:inline>
      </p:input>
   </p:identity>

</p:pipeline>
