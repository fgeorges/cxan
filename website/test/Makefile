PIPXTEST=../../../../xproc/pipx/test
COMPILER=$(PIPXTEST)/compile-suite.xsl
FORMATER=$(PIPXTEST)/format-report.xsl
REPORTS=./reports

all: $(REPORTS)/data-access-report.html \
     $(REPORTS)/dir-repos-report.html

# TODO: How to define a macro for all 3 targets per test suite?
# Worse case scenario, put everything within one target for one
# report (compile, run, and format), and use GNU Make's 'define'.

#data access

$(REPORTS)/data-access-report.html: $(REPORTS)/data-access-report.xml
	echo '[**]' FORMAT REPORT $@
	saxon -s:$< -xsl:$(FORMATER) > $@

$(REPORTS)/data-access-report.xml: $(REPORTS)/data-access.xproc
	echo '[**]' RUN AND GENERATE REPORT $@
	calabash $< > $@

$(REPORTS)/data-access.xproc: data-access.xml
	echo '[**]' COMPILE SUITE $@
	saxon -s:$< -xsl:$(COMPILER) > $@

# dir repos

$(REPORTS)/dir-repos-report.html: $(REPORTS)/dir-repos-report.xml
	echo '[**]' FORMAT REPORT $@
	saxon -s:$< -xsl:$(FORMATER) > $@

$(REPORTS)/dir-repos-report.xml: $(REPORTS)/dir-repos.xproc
	echo '[**]' RUN AND GENERATE REPORT $@
	calabash $< > $@

$(REPORTS)/dir-repos.xproc: dir-repos.xml
	echo '[**]' COMPILE SUITE $@
	saxon -s:$< -xsl:$(COMPILER) > $@

clean:
	rm -f $(REPORTS)/data-access-report.html
	rm -f $(REPORTS)/data-access-report.xml
	rm -f $(REPORTS)/data-access.xproc
	rm -f $(REPORTS)/dir-repos-report.html
	rm -f $(REPORTS)/dir-repos-report.xml
	rm -f $(REPORTS)/dir-repos.xproc

.PHONY: clean
