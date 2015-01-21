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
               <subtitle>Where is the REST API?</subtitle>
               <para>You can access CXAN information using a read-only REST-like API.
                  Just use the same URLs as for the website, but add the HTTP header
                  <code>Accept: application/xml</code>.  You will get back a simple XML
                  representation of the information shown on the corresponding webpage.</para>
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
               <para>By using Git, there is no need to implement a security mechanism, or a form to
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
                  repository with the format CXAN expects. Then contact Florent Georges on the <link
                     uri="http://expath.org/lists">EXPath mailing list</link> (or in private if you
                  don't want to write to the mailing list for whatever reason) in order to add your
                  repository to CXAN.</para>
               <subtitle>What is the structure of a CXAN repository?</subtitle>
               <para>The format is quite simple. If you prefer to learn by example, you can have a
                  look at Florent's personnal <link
                     uri="http://git.fgeorges.org/tree/~fgeorges:cxan-repo.git">repository</link>,
                  or at the EXPath <link uri="http://git.fgeorges.org/tree/expath:cxan-repo.git"
                     >repository</link>.</para>
               <para>The root directory must contain a file called <code>packages.xml</code>, with
                  the following format (there must be one element <code>pkg</code> for each package
                  in the repository):</para>
               <code><![CDATA[<repo abbrev="my-repo">

   <pkg abbrev="my-library" id="my-repo/my-library">
      <name>http://example.org/lib/super-tools</name>
      <version num="0.1.0">
         <file name="my-library-0.1.0.xar" role="pkg"/>
      </version>
   </pkg>

   <pkg abbrev="web-app-uno" id="my-repo/web-app-uno">
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
               <subtitle>How do I install a local CXAN?</subtitle>
               <para>You can install your own CXAN locally, either to deploy your own local system,
                  or as a package repository maintainer, to double-check your packages before
                  pushing them to http://cxan.org/. In a nutshell, you need to install the
                  following:</para>
               <list>
                  <item><link uri="http://servlex.net/">Servlex</link></item>
                  <item>the <link uri="http://cxan.org/pkg/fgeorges/cxan-website">CXAN
                        website</link> package</item>
                  <item>the repositories you want to be part of your deployment</item>
                  <item>your own master repository</item>
               </list>
               <para>First, create a directory which will contain your installation. It will contain
                  Servlex as a sub-directpry, another one will be its application repository, yet
                  another one will be the Git base for the package repositories, and so on. Let us
                  call that directory <code>cxan.home</code>.</para>
               <para>To install Servlex, just go to <link uri="http://servlex.net/"
                     >http://servlex.net/</link>, and follow the instructions. The easiest way is to
                  download the installer, and execute it (that is a JAR file, either with a
                  graphical installer, or text-based if your system is text-only). Adapt the
                  directory to <code>cxan.home/servlex</code>. Once it is installed, move the
                  directory <code>cxan.home/servlex/repo</code> to <code>cxan.home/repo</code>
                  and adapt the value of <code>org.expath.servlex.repo.dir</code> accordingly in
                  <code>cxan.home/servlex/conf/catalina.properties</code>.</para>
               <para>Adapt the port 19757 to the port number you want to use, in
                     <code>cxan.home/servlex/conf/server.xml</code>. Now you can start Servlex by
                  executing <code>cxan.home/servlex/bin/startup.sh</code> (you might need to set the
                  exec bit on the shell scripts first: <code>chmod u+x *.sh</code>). Go to the
                  Servlex Manager on <link uri="http://localhost:19757/manager/"
                     >http://localhost:19757/manager/</link> (adapt the port number if you changed
                  it in Servlex configuration) to validate it has been installed correctly.</para>
               <para>Go to the "Deploy" page of the Servlex Manager, and write down
                     <code>fgeorges/fxsl</code> in the CXAN ID field. Press "Deploy" in order to
                  install the first dependency of the CXAN website application directly from CXAN
                  itself. Confirm the installation. Then go back to the "Deploy' page and repeat
                  this process for the packages <code>fgeorges/pipx</code>,
                     <code>fgeorges/serial</code> and finally the CXAN Website itself:
                     <code>fgeorges/cxan-website</code>. But before testing it, we need to create
                  the Git base directory.</para>
               <para>Create the directory <code>cxan.home/git-base/master/</code>. Copy the file
                     <code>cxan.home/repo/cxan-website-0.7.0/content/config-params.xml</code> to
                     <code>cxan.home/repo/config-params.xml</code>, and edit the value of the
                     <code>git-base</code> parameter (make sure that all references to
                     <code>config-params.xml</code> in
                     <code>cxan.home/repo/cxan-website-0.7.0/content/data-access/dir-repos.xpl</code>
                  are pointing to the file (they should all be exactly
                     <code>../../../../config-params.xml</code>). The value must be an absolute path
                  on your system, starting with <code>file:/</code>, and pointing to the directory
                     <code>cxan.home/git-base/master/</code> you have just created. Create the file
                     <code>cxan.home/git-base/master/repositories.xml</code> with the following
                  content:</para>
               <code><![CDATA[<repositories>

   <repo abbrev="expath" href="../repos/expath/">
      <desc>The EXPath project repository.</desc>
      <packages>../repos/expath/packages.xml</packages>
      <git>
         <remote>http://git.fgeorges.org/r/expath/cxan-repo.git</remote>
         <branch>master</branch>
      </git>
   </repo>

</repositories>]]></code>
               <para>Adapt the values to the package repositories you want to add to your own CXAN
                  deployment, and create a new element <code>repo</code> well, for each such repo.
                  Do not forget to actually clone each of the repositories at the given
                  place.</para>
               <para>Create both directpries <code>cxan.home/git-base/master/sanity/</code> and
                     <code>cxan.home/git-base/master/authors/</code>. And create the file
                     <code>cxan.home/git-base/master/authors.xml</code> with the following content
                  (adapt the content, all author codes in your repositories must exist in this
                  file):</para>
               <code><![CDATA[<authors>

   <author id="dnovatchev">
      <name>
         <display>Dimitre Novatchev</display>
      </name>
   </author>

   <author id="fgeorges">
      <name>
         <display>Florent Georges</display>
      </name>
   </author>

   <author id="jkosek">
      <name>
         <display>Jirka Kosek</display>
      </name>
   </author>

   <author id="nwalsh">
      <name>
         <display>Norman Walsh</display>
      </name>
   </author>

   <author id="oasis">
      <name>
         <display>OASIS</display>
      </name>
   </author>

   <author id="pwalmsley">
      <name>
         <display>Priscilla Walmsley</display>
      </name>
   </author>

</authors>]]></code>
               <para>Create <code>cxan.home/git-base/master/categories.xml</code>, with the
                  following content (like for authors, adapt the content, as all category codes in
                  your repositories must exist in this file):</para>
               <code><![CDATA[<categories>
   <cat id="applications" name="Applications"/>
   <cat id="databases" name="Databases"/>
   <cat id="doctypes" name="Document types"/>
   <cat id="libs" name="Libraries"/>
   <cat id="pkg" name="Packaging"/>
   <cat id="tools" name="Tools"/>
   <cat id="web-api" name="Web APIs"/>
   <cat id="webapps" name="Webapps"/>
   <cat id="processor" name="Processor-related">
      <cat id="saxon" name="Saxon"/>
      <cat id="exist" name="eXist"/>
      <cat id="calabash" name="Calabash"/>
      <cat id="basex" name="BaseX"/>
   </cat>
</categories>]]></code>
               <para>Now, the last step is to download the CXAN tools. Create the directory
                     <code>cxan.home/tools/</code>, and unzip there the content of the latest file
                     <code>cxan-website-tools-*.zip</code> that you can find on the CXAN page of the
                     <link uri="http://cxan.org/pkg/fgeorges/cxan-website">CXAN website</link>
                  package. You can then invoke the shell script, with the git-base directory as an
                  option (use an absolute path): <code>./update-repos.sh
                  cxan.hom/git-base</code>.</para>
            </page>
         </p:inline>
      </p:input>
   </p:identity>

</p:pipeline>
