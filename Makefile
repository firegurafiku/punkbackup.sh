
SUBSCRIPTS = src/common.sh \
             src/options.sh \
             src/json.sh \
             src/main.sh \
             src/localfs.sh

.phony: all

all: punkbackup.sh

punkbackup.sh: $(SUBSCRIPTS)
	cat $(^) > $(@)
	echo >> $(@)
	echo 'main:entrypoint "$$@"' >> $(@)
	chmod +x $(@)
