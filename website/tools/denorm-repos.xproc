<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pxp="http://exproc.org/proposed/steps"
                xmlns:my="investigate.xsl#impl"
                version="1.0"
                exclude-inline-prefixes="c pxp my">

   <!--
      "investigate.xproc", because it gathers information from the repository
      and store it in a denormalized file at the root of it: packages.xml.
   -->

   <p:option name="repos-dir" required="true">
      <p:documentation xmlns="http://www.w3.org/1999/xhtml">
         <p>The directory for the repositories to investigate.</p>
         <p>Each sub-directory in this directory is considered a repository, and must
            therefore contain a packages.xml file.</p>
         <p>It must be an absolute URI. So for a human being to invoke this pipeline,
            the best solution is to use a wrapper shell script.</p>
      </p:documentation>
   </p:option>

   <p:output port="result"/>

   <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

   <!-- return the package directories -->
   <p:directory-list>
      <p:with-option name="path" select="$repos-dir"/>
   </p:directory-list>

   <!-- TODO: Generate an error if there is any file at this level! -->
   <!--p:delete match="c:file"/-->

   <!-- return the version directories -->
   <p:for-each>
      <p:iteration-source select="/c:directory/c:directory"/>
      <p:variable name="dir-name" select="/c:directory/@name"/>
      <p:variable name="relative" select="concat('./', $dir-name, '/'[not(ends-with($dir-name, '/'))])"/>
      <p:variable name="absolute" select="resolve-uri($relative, base-uri(.))"/>
      <p:load name="load">
         <p:with-option name="href" select="resolve-uri('packages.xml', $absolute)"/>
      </p:load>
      <p:add-attribute attribute-name="xml:base" match="/*">
         <p:with-option name="attribute-value" select="$relative"/>
      </p:add-attribute>
   </p:for-each>

   <!-- wrap into a 'repos' element with the proper xml:base attribute -->
   <p:wrap-sequence wrapper="repos"/>

   <p:add-attribute attribute-name="xml:base" match="/*">
      <p:with-option name="attribute-value" select="$repos-dir"/>
   </p:add-attribute>

</p:declare-step>
