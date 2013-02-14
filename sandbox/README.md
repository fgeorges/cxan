# README for `sandbox/`

This directory is a dedicated CXAN sandbox.  **Don't store anything
valuable in here.**

The sandbox can be deleted, restarted, or re-created at any time,
without notice.

This sandbox is local in nature, mainly for local testing during
development.

There is also a sub-directory `cxan-sandbox/`, which contains a
descriptor and a `Makefile` to build the sandbox at
[http://test.cxan.org]. (That’s another story, though.)

It must contain a sub-directory `apache-tomcat-7.0.27/`.  (It
shouldn’t be added to the Git repository though; please don’t add it
yourself!)

It should also contain the sub-directory `exist-2.0-tech-preview/`,
with eXist installed via the graphical installer (with the password
`admin` for `admin`).



## Tomcat config


### `conf/catalina.properties`

Added the prop `org.expath.servlex.repo.dir`:

    org.expath.servlex.repo.dir=/absolute/dir/to/cxan/sandbox/repo


### `conf/server.xml`

I've made the following changes to ports:

- `8005` → `9075`
- `8080` → `9070`
- `8443` → `9473`
- `8009` → `9079`

```
       @@ -21,7 +21,7 @@
         -->
       -<Server port="8005" shutdown="SHUTDOWN">
       +<Server port="9075" shutdown="SHUTDOWN">
          <!-- Security listener. Documentation at /docs/config/listeners.html
       @@ -69,9 +69,9 @@
            -->
       -    <Connector port="8080" protocol="HTTP/1.1" 
       +    <Connector port="9070" protocol="HTTP/1.1" 
                       connectionTimeout="20000" 
       -               redirectPort="8443" />
       +               redirectPort="9473" />
            <!-- A "Connector" using the shared thread pool-->
       @@ -90,7 +90,7 @@
            <!-- Define an AJP 1.3 Connector on port 8009 -->
       -    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
       +    <Connector port="9079" protocol="AJP/1.3" redirectPort="9473" />
```


### `conf/tomcat-users.xml`

I've added the config for the user `admin` with password `admin`:

```xml
    <role rolename="admin-gui"/>
    <role rolename="admin-script"/>
    <role rolename="manager-gui"/>
    <role rolename="manager-script"/>
    <user username="admin" password="admin"
          roles="admin-gui,admin-script,manager-gui,manager-script"/>
```


## eXist config

I've made the following changes to ports in the Jetty config 
(`tools/jetty/etc/jetty.xml`):

- `8080` → `7070`
- `8443` → `7473`

Next: 

- goto the user manager from the dashboard
- add the group `cxan`
- add the user `cxan` with password `cxan` (in the `cxan` group, 
  without any home collection)

Good!  

Let’s continue:

- In `client.properties`, change the `uri` property from port 
  `8080` → `7070`
- For `shutdown.sh`, you’ll need to specify a password (using `-p`) 
- Create the collection `/db/cxan/`
 - owner: `cxan` 
 - group: `cxan`
 - user: `cxan` (with write access)
- Add the documents under `misc/db/` to `/db/cxan/` 
  (i.e. the empty `packages.xml` and `categories.xml`, 
  with the tree of categories).
