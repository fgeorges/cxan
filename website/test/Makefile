# TODO: The git-base parameter should be passed through the unit
# framework, somehow, so that we can run tests against different
# on-disk repositories.

# TODO: How to define a macro for all 3 targets per test suite?
# Worse case scenario, put everything within one target for one
# report (compile, run, and format), and use GNU Make's 'define'.

# variables

PIPXTEST=../../../../xproc/pipx/test
COMPILER=$(PIPXTEST)/compile-suite.xsl
FORMATER=$(PIPXTEST)/format-report.xsl
REPORTS=./reports

# the 'all' target' (must be the first one to be the default)

all: $(REPORTS)/data-access-report.html \
     $(REPORTS)/dir-repos-report.html

# data access

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

# misc

clean:
	rm -f $(REPORTS)/data-access-report.html
	rm -f $(REPORTS)/data-access-report.xml
	rm -f $(REPORTS)/data-access.xproc
	rm -f $(REPORTS)/dir-repos-report.html
	rm -f $(REPORTS)/dir-repos-report.xml
	rm -f $(REPORTS)/dir-repos.xproc

.PHONY: all clean
