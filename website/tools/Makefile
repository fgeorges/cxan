# TODO: Integrate the backup target in the client?
#   Or in a website-dedicated tool script?
# TODO: As a double security, use the eXist backup scripts to make a full-fledged
#   backup of the CXAN eXist database in addition...
# TODO: An option of wget to create intermediate dirs for output file if necessary?
#   (instead of explicit mkdir or dirname)

EXIST=/Users/fgeorges/projects/xquery/exist-trunk/eXist/

xproc:
	for f in `calabash backup.xproc | egrep -v '^</?files'`; do mkdir -p `dirname files/$$f`; wget -O files/$$f "http://cxan.org/file/$$f"; done

# TODO: NPE?!? Report it!
client:
	$(EXIST)/bin/backup.sh -u admin -p "" -b /db -d client-bck \
	    -ouri=xmldb:exist://localhost:8080/exist/xmlrpc
