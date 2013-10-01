<p:pipeline xmlns:p="http://www.w3.org/ns/xproc"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            xmlns:pkg="http://expath.org/ns/pkg"
            xmlns:web="http://expath.org/ns/webapp"
            xmlns:app="http://cxan.org/ns/website"
            pkg:import-uri="http://cxan.org/website/pages/admin/console.xproc"
            name="pipeline"
            version="1.0">

   <p:import href="../../tools.xpl"/>

   <app:ensure-method accepted="get"/>
   <p:sink/>

   <p:identity>
      <p:input port="source">
         <p:inline>
            <page menu="admin">
               <title>Admin console</title>
               <subtitle>Export</subtitle>
               <para>To export the database, <link uri="export">click here</link>.</para>
               <subtitle>Import</subtitle>
               <para>To import an earlier backup into the database, choose the backup to restore
                  and click on "restore":</para>
               <form xmlns="http://www.w3.org/1999/xhtml"
                     method="post" enctype="multipart/form-data" action="import">
                  <fieldset>
                     <input type="file" size="64" name="backup"/>
                     <input style="margin-left: 20px" type="submit" class="submit" value="Restore"/>
                  </fieldset>
               </form>
               <subtitle>Check</subtitle>
               <para>To perform a consistency check on the database,
                  <link uri="check">click here</link>.</para>
            </page>
         </p:inline>
      </p:input>
   </p:identity>

</p:pipeline>
