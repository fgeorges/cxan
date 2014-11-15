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
               <subtitle>What does CXAN contain?</subtitle>
               <para>CXAN offers a variety of packages, from simple tool libraries to entire web
                  applications. It is based on the EXPath packaging system. The package format
                  supports technologies such as XQuery, Javascript, XSLT, RDF, XML Schema, SPARQL,
                  and more.</para>
               <para>Each package has its own package page on the website, containing more
                  information about it. The website can be searched for packages, or simply
                  browsed.</para>
               <subtitle>Who maintain packages?</subtitle>
               <para>The packages on CXAN are maintained by a community of volunteers. Each package
                  is assigned to one maintainer. Each package page contains more information about
                  its maintainer.</para>
               <subtitle>How are packages maintained?</subtitle>
               <para>Technically, packages are maintained in Git repositories. CXAN monitors some
                  specific repositories. Each maintainer has his/her own repository, containing all
                  the packages he/she maintains. Each Git repository has a specific structure,
                  defined by CXAN (basically containing packages in a specific directory structure,
                  based on conventions, besides a few config informations kept in a couple of XML
                  files).</para>
               <image src="images/git-repos.png" alt="The community collaboration approach using Git."/>
               <para>Maintainers simply maintain the packages they are responsible for in their own
                  Git repository, using all the Git tools they want. As soon as they push changes to
                  the remote repository (well, as soon as CXAN pull these changes), like adding a
                  new version of an existing package, the change becomes available on the CXAN
                  website.</para>
               <subtitle>Why using Git?</subtitle>
               <para>By using Git, there is no need to implement a secutiry mechanism, or a form to
                  upload new packages. Maintainers can use all Git tools, as they are used to,
                  possibly entire teams collaborating, or using several branches to map their
                  development and release process, as they do for any other piece of
                  software.</para>
               <para>By using Git, having a copy of each repository on (at the very least) the
                  remote host, the maintainer local machine and the CXAN website, effectively
                  creates as much backup of each repository on different locations, and maintained
                  and backed up each by different persons or companies or organizations. The updates
                  are transmitted by following the chain of Git pushes. The risk of loosing anything
                  is very low (virtually inexistant), without even having to write any backup
                  strategy.</para>
               <subtitle>GitHub does not allow binaries!</subtitle>
               <para>CXAN does not use GitHub (except for its own source code). It uses Git. If a
                  maintainer wants to use GitHub, that is its responsibility (I do not think that a
                  couple of small packages, typically less than 100 Ko, is a real problem). I
                  personally use my own server of remote Git repositories.</para>
               <subtitle>How can I add a new package to CXAN?</subtitle>
               <para>Either you contact a maintainer and convince him/her to add your package (e.g.
                  if the package is related to the maintainer activity). Or you volunteer to become
                  a maintainer yourself. In that case the first step is to create a remote Git
                  repository with the format CXAN expectes. Then contact Florent Georges on the
                     <link uri="http://expath.org/lists">EXPath mailing list</link> (or directly to
                  me if you don't want to write to the mailing list for whatever reason) in order to
                  add your repository to CXAN.</para>
               <subtitle>What is the structure of a CXAN repository?</subtitle>
               <para>The format is quite simple. If you prefer to learn by example, you can have a
                  look at my <link uri="http://git.fgeorges.org/summary/~fgeorges:cxan-repo.git">own
                     repository</link>.</para>
               <para>The root directory must contain a file called <code>packages.xml</code>, with
                  the following format (there must be one element <code>pkg</code> for each package
                  in the repository):</para>
               <code><![CDATA[<repo>
   <pkg id="my-library">
      <name>http://example.org/lib/super-tools</name>
      <version num="0.1.0">
         <file name="my-library-0.1.0.xar" role="pkg"/>
      </version>
   </pkg>
   <pkg id="web-app-uno">
      <name>http://example.org/app/web-app-uno</name>
      <abstract>...</abstract>
      <author id="fgeorges">Florent Georges</author>
      <category id="libs">Libraries</category>
      <category id="saxon">Saxon extensions</category>
      <tag>http</tag>
      <tag>library</tag>
      <tag>saxon</tag>
      <version num="0.11.0dev">
         <dependency processor="http://saxon.sf.net/he"/>
         <file name="expath-http-client-saxon-0.11.0dev.xar" role="pkg"/>
         <file name="expath-http-client-saxon-0.11.0dev.zip" role="archive"/>
      </version>
   </pkg>
</repo>]]></code>
            </page>
         </p:inline>
      </p:input>
   </p:identity>

</p:pipeline>
