<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/news.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <p:identity>
      <p:input port="source">
         <p:inline>
            <page menu="news">
               <title>News</title>
               <subtitle>From beta to life</subtitle>
               <details>June 26, 2011</details>
               <para>The CXAN website has just gone in production.</para>
               <subtitle>Tweet it!</subtitle>
               <details>February 8, 2013</details>
               <para>Live from @<link uri="http://twitter.com/xmlprague">xmlprague</link>, launched automatic tweeting
                 of new uploads to CXAN: @<link uri="http://twitter.com/cxannounce">cxannounce</link> for the main CXAN
                 site, and @<link uri="http://twitter.com/cxandbox">cxandbox</link> for the CXAN sandbox.</para>
            </page>
         </p:inline>
      </p:input>
   </p:identity>

</p:pipeline>
