CC = acc

${MDTARG}/bin/graph: graph.o graphics.o
	@echo
	ld -o ${MDTARG}/bin/graph graph.o graphics.o \
	/lib/crt1.o \
	-ltools_s -lm -lc_s -lc \
	/lib/crtn.o
	@strip ${MDTARG}/bin/graph

.c.o:
	@echo "    $*.c -> $@"
	@if test "${DEBUG}" != "yes"; \
	then ${CC} -knr -c -ga ${COPT} $<; \
	else ${CC} -knr -c -g -DDEBUG=1 ${COPT} $<; fi
	@if test "${DEBUG}" = "yes"; \
	then echo "    debug version of $*.c compiled"; fi

