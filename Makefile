
ENTRYPOINT = src/entrypoint.sh

SUBSCRIPTS = \
	src/options.sh                 \
	src/common.sh                  \
	src/json.sh                    \
	src/main.sh                    \
	src/targets/_generic_target.sh \
	src/targets/file.sh            \
	src/drivers/btrfs.sh           \
	src/drivers/_generic_driver.sh

TESTSCRIPTS = \
	test/test-json.sh

.phony: all test

all: punkbackup.sh

test: all $(TESTSCRIPTS)
	@ success="y"; \
	  for test in $(TESTSCRIPTS); do $$test || success="n"; done; \
	  [ "$$success" = "y" ]

punkbackup.sh: $(ENTRYPOINT) $(SUBSCRIPTS)
	@ cat $(ENTRYPOINT) > $(@)
	@ cat $(SUBSCRIPTS) >> $(@)
	@ echo >> $(@)
	@ echo 'entrypoint "$$@"' >> $(@)
	@ chmod +x $(@)
