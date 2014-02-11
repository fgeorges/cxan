<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/home.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../tools.xpl"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <p:xslt template-name="main">
      <p:input port="source">
         <p:empty/>
      </p:input>
      <p:input port="parameters">
         <p:empty/>
      </p:input>
      <p:input port="stylesheet">
         <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                            xmlns:xs="http://www.w3.org/2001/XMLSchema"
                            version="2.0">
               <xsl:function name="app:is-sandbox" as="xs:boolean">
                  <xsl:variable name="params" select="doc('../../../../config-params.xml')/c:param-set"/>
                  <xsl:sequence select="$params/c:param[@name eq 'is-sandbox']/xs:boolean(@value)"/>
               </xsl:function>
               <xsl:template name="main">
                  <page menu="home">
                     <starter>
                        <title>CXAN</title>
                        <subtitle>(: <italic>Organizing and Delivering XML Packages, Libraries and Applications</italic> :)</subtitle>
                        <subtitle>The Comprehensive XML Archive Network.</subtitle>
                     </starter>
                     <para>CXAN stands for <italic>Comprehensive XML Archive Network</italic>. If you know
                        CTAN or CPAN, resp. for (La)TeX and Perl, then you already understood what this
                        website is all about: providing a central place to collect and organize existing
                        libraries and applications writen in XML technologies, like XSLT, XQuery, XProc,
                        and schemas.</para>
                     <para>CXAN is comprised of two different facets: its server, and clients. The server
                        collects the XML libraries and applications, organize them, and make them both
                        browsable and searchable by humans on the website and accessible to programs
                        through a REST-like API. Thanks to its REST-like API, any program can easily
                        integrate with the CXAN server. The <link uri="http://cxan.org/pkg/cxan-client"
                           >CXAN client</link> is an XProc client to be used from the command-line, in
                        order to manage an on-disk repository by downloading and installing packages from
                        the CXAN server. The local on-disk repository manager is <link
                           uri="http://expath-pkg.googlecode.com/">expath-repo</link>.</para>
                     <para>If you are looking for an easy way to build a package out of your source files,
                        take a look at <link uri="http://expath.org/modules/xproject/">XProject</link>
                        (CXAN ID <link uri="pkg/xproject">xproject</link>) and at its <link
                           uri="http://expath.org/modules/xproject/oxygen">plugin for
                        oXygen</link>.</para>
                     <xsl:if test="app:is-sandbox()">
                        <para>Use test/test to connect on the upload page.</para>
                     </xsl:if>
                  </page>
               </xsl:template>
            </xsl:stylesheet>
         </p:inline>
      </p:input>
   </p:xslt>

</p:pipeline>
