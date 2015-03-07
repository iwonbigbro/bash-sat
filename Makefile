# Copyright (C) 2015 Craig Phillips.  All rights reserved.

all:
	@true

verbose:
	@true

debug:
	@true

export BUILDROOT:= $(shell readlink -m BUILDROOT)
export PATH:= $(shell readlink -f bin):$(PATH)

SILENT:= $(if $(filter verbose,$(MAKECMDGOALS)),,@)
DEBUG:= $(if $(filter debug,$(MAKECMDGOALS)),1,)

ifneq (,$(SILENT))
define fn_silent
	( t=`mktemp` ; \
	e=0 ; \
	if ! ( $1 ) 1>$$t.out 2>$$t.err ; then \
		e=1 ; \
		cat $$t.err ; \
	fi ; \
	rm -f $$t.* ; \
	exit $$e ; )
endef
else
define fn_silent
	( t=`mktemp` ; \
	e=0 ; \
	( $1 ) 1>$$t.out 2>&1 || e=$$? ; \
	cat $$t.out ; \
	rm -f $$t.* ; \
	exit $$e ; )
endef
endif

V:= $(if $(SILENT),,-v)

tests:= $(wildcard tests/*/test.sh)
run_test_targets:= $(tests:tests/%/test.sh=run_test_%)

run_tests: $(run_test_targets)

junit.xml: $(BUILDROOT)/junit.xml $(if $(CIRCLE_TEST_REPORTS),$(CIRCLE_TEST_REPORTS)/junit.xml)

$(CIRCLE_TEST_REPORTS)/junit.xml: $(BUILDROOT)/junit.xml
	@rm -f $@
	@cp $V $< $@

$(BUILDROOT)/junit.xml: $(run_test_targets)
	@rm -f $@
	@bash tests/generate_junit.sh >$@

clean_pyc:
	@find bin lib -name '*.pyc' -exec rm $V -f {} \;

clean: clean_pyc
	@rm $V -rf $(BUILDROOT)

$(run_test_targets): run_test_% : tests/%/test.sh
	@$(call fn_silent,echo "Running test $*")
	@rm $V -rf $(BUILDROOT)/$*
	@TEST_DEBUG=$(DEBUG) bash tests/run_test.sh $*
