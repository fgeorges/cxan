PIPXTEST=../../../../xproc/pipx/test
COMPILER=$(PIPXTEST)/compile-suite.xsl
FORMATER=$(PIPXTEST)/format-report.xsl
REPORTS=./reports

$(REPORTS)/dir-repos-report.html: $(REPORTS)/dir-repos-report.xml
	saxon -s:$< -xsl:$(FORMATER) > $@

$(REPORTS)/dir-repos-report.xml: $(REPORTS)/dir-repos.xproc
	calabash $< > $@

$(REPORTS)/dir-repos.xproc: dir-repos.xml
	saxon -s:$< -xsl:$(COMPILER) > $@

clean:
	rm -f $(REPORTS)/dir-repos-report.html
	rm -f $(REPORTS)/dir-repos-report.xml
	rm -f $(REPORTS)/dir-repos.xproc

.PHONY: clean
