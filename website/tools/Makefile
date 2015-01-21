# TODO: Integrate the backup target in the client?
#   Or in a website-dedicated tool script?
# TODO: As a double security, use the eXist backup scripts to make a full-fledged
#   backup of the CXAN eXist database in addition...
# TODO: An option of wget to create intermediate dirs for output file if necessary?
#   (instead of explicit mkdir or dirname)

# eXist's home dir, to find bin/backup.sh
EXIST_DIR=/Users/fgeorges/projects/xquery/exist-trunk

# CXAN
#DOMAIN=cxan.org
#EXIST_PORT=8020
#FILES_DIR=/usr/local/cxan/files
# CXAN Sandbox
DOMAIN=test.cxan.org
EXIST_PORT=8099
FILES_DIR=/usr/local/cxan-sandbox/files

# eXist password - DO NOT COMMIT IN GIT!
EXIST_PWD=xxx
# where to backup?
BCK_DIR=client-bck

cxan-website-tools-0.7.0.zip: check-sanity.xproc \
                              denorm-authors.xproc \
                              denorm-repos.xproc \
                              repo.xsd \
                              calabash.sh \
                              update-repos.sh
	zip $@ $^

client:
	rm -rf $(BCK_DIR).OLD
	mv $(BCK_DIR) $(BCK_DIR).OLD
	mkdir $(BCK_DIR)
	mkdir $(BCK_DIR)/db
	mkdir $(BCK_DIR)/db/cxan
	$(EXIST_DIR)/bin/backup.sh -u cxan -p $(EXIST_PWD) -b /db/cxan -d $(BCK_DIR) \
	    -ouri=xmldb:exist://$(DOMAIN):$(EXIST_PORT)/exist/xmlrpc
	scp -r $(DOMAIN):$(FILES_DIR) $(BCK_DIR)/files
