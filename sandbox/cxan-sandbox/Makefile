WAR=../../../../servlex/servlex/dist/servlex.war
CTXT=META-INF/context.xml

# This gets the standard Servlex WAR, and add a Tomcat context file
# with alternate context root and alternate repo dir...  The resulting
# WAR is then ready to be deployed on http://test.cxan.org/ using the
# Tomcat manager UI.
cxan-sandbox.war: $(CTXT) $(WAR)
	cp $(WAR) cxan-sandbox.war
	zip cxan-sandbox.war $(CTXT)
