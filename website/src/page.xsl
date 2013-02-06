<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:c="http://www.w3.org/ns/xproc-step"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:web="http://expath.org/ns/webapp"
                exclude-result-prefixes="#all"
                version="2.0">

   <pkg:import-uri>http://cxan.org/website/filters/page.xsl</pkg:import-uri>

   <xsl:output method="xhtml"/>

   <xsl:param name="analytics-id" as="xs:string?" select="'UA-5463082-6'"/>

   <xsl:variable name="context-root" as="xs:string" select="
       doc('config-params.xml')/c:param-set/c:param[@name eq 'context-root']/@value"/>
   <!--xsl:variable name="context-root" select="''"/-->
   <!--xsl:param name="context-root" as="xs:string" required="yes"/-->

   <xsl:variable name="version"  select="'@@VERSION@@'"/>
   <xsl:variable name="revision" select="'@@REVISION@@'"/>

   <xsl:template match="/">
      <!-- DEBUG: Log the page doc and the result. -->
      <!--xsl:message>
         INPUT: <xsl:copy-of select="."/>
      </xsl:message>
      <xsl:message>
         RESULT: <xsl:apply-templates select="*"/>
      </xsl:message-->
      <xsl:apply-templates select="*"/>
   </xsl:template>

   <xsl:template match="/*" priority="-10">
      <xsl:message>
         ERROR - input: <xsl:copy-of select="."/>
      </xsl:message>
      <xsl:sequence select="error((), 'Unknown result document type.')"/>
   </xsl:template>

   <xsl:template match="h:*" xmlns:h="http://www.w3.org/1999/xhtml">
      <xsl:sequence select="."/>
   </xsl:template>

   <xsl:template match="/web:*">
      <xsl:sequence select="."/>
   </xsl:template>

   <xsl:template match="/page">
      <web:response status="{ (@http-code, '200')[1] }" message="{ (@http-message, 'Ok')[1] }">
         <web:body content-type="text/html">
            <html>
               <head>
                  <xsl:call-template name="head"/>
               </head>
               <body>
                  <xsl:call-template name="body"/>
               </body>
            </html>
         </web:body>
      </web:response>
   </xsl:template>

   <xsl:template name="head">
      <title>
         <xsl:value-of select="title"/>
      </title>
      <link rel="stylesheet"    type="text/css"  href="{ $context-root }/style/cxan.css"/>
      <link rel="stylesheet"    type="text/css"  href="{ $context-root }/style/serial.css"/>
      <link rel="shortcut icon" type="image/png" href="{ $context-root }/images/expath-icon.png"/>
   </xsl:template>

   <xsl:template name="body">
      <div id="upbg"/>
      <div id="outer">
         <div id="header">
            <div id="headercontent">
               <h1>CXAN</h1>
               <h2>(: <i>Organizing and Delivering XML Packages, Libraries and Applications</i> :)</h2>
            </div>
         </div>
         <form method="get" action="search">
            <div id="search">
               <input type="text" class="text" maxlength="64" name="q" value=""/>
               <input type="submit" class="submit" value="Search"/>
            </div>
         </form>
         <div id="headerpic"/>
         <div id="menu">
            <xsl:call-template name="menu">
               <xsl:with-param name="active" select="@menu"/>
            </xsl:call-template>
         </div>
         <div id="menubottom"/>
         <div id="content">
            <div class="normalcontent">
               <xsl:for-each-group select="*" group-starting-with="title|subtitle">
                  <xsl:apply-templates select="." mode="group"/>
               </xsl:for-each-group>
            </div>
         </div>
         <div id="footer">
            <div class="left">
               <a href="http://validator.w3.org/check?uri=referer">
                  <img src="{ $context-root }/images/valid-xhtml11.gif" alt="Valid XHTML 1.1" style="border: 0;"/>
               </a>
               <a href="http://jigsaw.w3.org/css-validator/check/referer">
                  <img src="{ $context-root }/images/valid-css.gif" alt="Valid CSS!" style="border: 0;"/>
               </a>
            </div>
            <div class="right">
               <xsl:text>CXAN website version </xsl:text>
               <xsl:value-of select="$version"/>
               <xsl:text> (revision #</xsl:text>
               <xsl:value-of select="$revision"/>
               <xsl:text>) - Hosted by </xsl:text>
               <a href="http://h2oconsulting.be/">H2O Consulting</a>
               <xsl:text> - Powered by </xsl:text>
               <a href="http://expath.org/">EXPath</a>
               <xsl:text> and </xsl:text>
               <a href="http://code.google.com/p/servlex/">Servlex</a>
            </div>
         </div>
      </div>
      <xsl:if test="exists($analytics-id)">
         <script type="text/javascript">
            var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
            document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
         </script>
         <script type="text/javascript">
            try {
               var pageTracker = _gat._getTracker("<xsl:value-of select="$analytics-id"/>");
               pageTracker._trackPageview();
            }
            catch(err) {
            }
         </script>
      </xsl:if>
   </xsl:template>

   <xsl:template match="title|subtitle" mode="group">
      <xsl:apply-templates select="."/>
      <div class="contentarea">
         <xsl:apply-templates select="current-group()[position() gt 1]"/>
      </div>
   </xsl:template>

   <xsl:template match="*" mode="group">
      <xsl:apply-templates select="current-group()"/>
   </xsl:template>

   <xsl:template name="menu">
      <xsl:param name="active" as="xs:string?"/>
      <xsl:variable name="items" as="element()+">
         <item name="home"   href="{ $context-root }/"       title="CXAN Home">Home</item>
         <item name="news"   href="{ $context-root }/news"   title="CXAN News">News</item>
         <item name="pkg"    href="{ $context-root }/pkg"    title="Packages by name">Packages</item>
         <item name="author" href="{ $context-root }/author" title="Packages by author">Authors</item>
         <item name="cat"    href="{ $context-root }/cat"    title="Packages by category">Categories</item>
         <item name="tag"    href="{ $context-root }/tag"    title="Packages by tag">Tags</item>
         <item name="faq"    href="{ $context-root }/faq"    title="CXAN FAQ">FAQ</item>
         <item name="about"  href="{ $context-root }/about"  title="About CXAN">About</item>
         <item name="upload" href="{ $context-root }/upload" title="Upload a new package">Upload</item>
      </xsl:variable>
      <ul>
         <xsl:for-each select="$items">
            <li>
               <xsl:if test="@name eq 'upload'">
                  <xsl:attribute name="class" select="'right'"/>
               </xsl:if>
               <a href="{ @href }" title="{ @title }">
                  <xsl:if test="$active eq @name">
                     <xsl:attribute name="class" select="'active'"/>
                  </xsl:if>
                  <xsl:value-of select="."/>
               </a>
            </li>
         </xsl:for-each>
      </ul>
   </xsl:template>

   <xsl:template match="*" priority="-1">
      <xsl:text>&lt;ERROR: Unkown element: </xsl:text>
      <code>
         <xsl:value-of select="name(.)"/>
      </code>
      <xsl:text>.&gt;</xsl:text>
   </xsl:template>

   <xsl:template match="title">
      <h3>
         <strong>
            <xsl:apply-templates/>
         </strong>
      </h3>
   </xsl:template>

   <xsl:template match="subtitle">
      <h4>
         <strong>
            <xsl:apply-templates/>
         </strong>
      </h4>
   </xsl:template>

   <xsl:template match="details">
      <div class="details">
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates/>
      </div>
   </xsl:template>

   <xsl:template match="image">
      <img class="left" src="{ @src }" alt="{ @alt }"/>
   </xsl:template>

   <xsl:template match="para">
      <p>
         <xsl:apply-templates/>
      </p>
   </xsl:template>

   <xsl:template match="bold">
      <b>
         <xsl:apply-templates/>
      </b>
   </xsl:template>

   <xsl:template match="italic">
      <em>
         <xsl:apply-templates/>
      </em>
   </xsl:template>

   <xsl:template match="list">
      <ul>
         <xsl:apply-templates/>
      </ul>
   </xsl:template>

   <xsl:template match="item">
      <li>
         <xsl:apply-templates/>
      </li>
   </xsl:template>

   <xsl:template match="link">
      <a>
         <xsl:attribute name="href" select="
             if ( @absolute/xs:boolean(.) ) then
               concat($context-root, @uri)
             else
               @uri"/>
         <xsl:apply-templates/>
      </a>
   </xsl:template>

   <xsl:template match="para/code" priority="2">
      <code>
         <xsl:copy-of select="node()"/>
      </code>
   </xsl:template>

   <xsl:template match="code">
      <pre>
         <xsl:copy-of select="node()"/>
      </pre>
   </xsl:template>

   <xsl:template match="table">
      <table border="1pt">
         <xsl:if test="exists(column)">
            <thead>
               <xsl:for-each select="column">
                  <td>
                     <xsl:apply-templates/>
                  </td>
               </xsl:for-each>
            </thead>
         </xsl:if>
         <xsl:for-each select="row">
            <tr>
               <xsl:for-each select="cell">
                  <td>
                     <xsl:apply-templates/>
                  </td>
               </xsl:for-each>
            </tr>
         </xsl:for-each>
      </table>
   </xsl:template>

   <xsl:template match="named-info">
      <table class="namedinfo">
         <xsl:for-each select="row">
            <tr>
               <td>
                  <xsl:if test="exists(name)">
                     <b>
                        <xsl:apply-templates select="name/node()"/>
                     </b>
                     <xsl:text>: </xsl:text>
                  </xsl:if>
               </td>
               <td>
                  <xsl:apply-templates select="info/node()"/>
               </td>
            </tr>
         </xsl:for-each>
      </table>
   </xsl:template>
   
</xsl:stylesheet>
