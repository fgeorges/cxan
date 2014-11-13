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
               <para>CXAN is a distribution network for web technologies-related packages. The
                  content of CXAN is a set of packages for technologies such as XML, Javascript,
                  XQuery, XSLT, RDF, XML Schema, SPARQL, and more. The packages themselves can
                  be libraries, web applications, or command-line applications.</para>
               <para>CXAN stands for Comprehensive XML Archive Network. It was born initally to
                  support XML-related technologies such as XQuery and XSLT, but has evolved since
                  then to support way more technologies, and allows to mix them.</para>
               <para>The set of packages available on CXAN is maintained by a community. Each
                  package is identfied by a short ID string (such as <code>functx</code> for
                  instance), and is maintained by one maintainer. Each maintainer has a Git
                  repository containing all the packages he/she maintains, in a specific format.
                  Adding new packages to CXAN or updating existing packages is then as easy as
                  pushing changes on those Git repositories monitored by CXAN.</para>
               <para>You can find more informaiton about CXAN on the <link
                     uri="http://expath.org/lists">EXPath mailing list</link>.</para>
            </page>
         </p:inline>
      </p:input>
   </p:identity>

</p:pipeline>
