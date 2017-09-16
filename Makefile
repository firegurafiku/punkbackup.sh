
SUBSCRIPTS = src/common.sh \
             src/options.sh \
             src/json.sh \
             src/main.sh \
             src/entrypoint.sh \
             src/localfs.sh

.phony: all

all: punkbackup.sh

punkbackup.sh: $(SUBSCRIPTS)
	cat $(^) > $(@)
	echo >> $(@)
	echo 'entrypoint "$$@"' >> $(@)
	chmod +x $(@)
