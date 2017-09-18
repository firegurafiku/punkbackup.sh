
SUBSCRIPTS = src/common.sh \
             src/options.sh \
             src/json.sh \
             src/main.sh \
             src/entrypoint.sh \
             src/localfs.sh

TESTSCRIPTS = test/test-json.sh

.phony: all test

all: punkbackup.sh

test: all $(TESTSCRIPTS)
	@ success="y"; \
	  for test in $(TESTSCRIPTS); do $$test || success="n"; done; \
	  [ "$$success" = "y" ]

punkbackup.sh: $(SUBSCRIPTS)
	cat $(^) > $(@)
	echo >> $(@)
	echo 'entrypoint "$$@"' >> $(@)
	chmod +x $(@)
