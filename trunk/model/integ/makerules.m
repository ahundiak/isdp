#   HISTORY
#
#   03/21/92    DLB Removed running sed -f acc.sed since no longer problem.
#   ?? ??? 198? jBk Genesis.

CB = ${model_etc}/bin/cb4.2BSD
TOUCH = ${model_etc}/bin/${touchdir}/touch
TOUCHS = ${model_etc}/bin/${touchdir}/touchs
BREAK = ${model_etc}/lib/break.awk
DTAB = ${model_etc}/bin/detab 4
PCB = ${model_etc}/bin/chop
DOLLAR = ${model_etc}/bin/dollar
LONGFLOAT = ${model_etc}/bin/longfloat
LINT = lint
CCFILTER =

lint:
	@make -${MAKEFLAGS} suffix=ln lint_all_objects

lint_all_objects: ${objects}

.S.o :
	@echo "    $< -> $*.c"
	@${opp} ${DOPT} ${PPOPT} ${OPPOPT} ${OPPFLAGS} $<
	@if test "${JUNK_C}" = "yes" -o "${COPT}" = "-g"; then \
	   ${CB} < $*.c | ${DTAB} | ${PCB} > $*.b; rm $*.c; mv $*.b $*.c; fi
	@echo "    $*.c -> $@"
	@${CC} -c -ga ${COPT} ${DOPT} -I${EXNUC}/include $*.c
	@if test "${COPT}" != "-g" -a "${JUNK_C}" != "yes"; \
	then rm $*.c; echo "    removing $*.c"; \
	else echo "    debug version $*.c left"; fi
#	@echo $* > $@

.I.ln:
	@echo "    $< -> $*.c"
	@${opp} -l ${DOPT} ${PPOPT} ${OPPOPT} ${OPPFLAGS} $< ; \
   ${DOLLAR} < $*.c | ${LONGFLOAT} | ${CB} | ${DTAB} | ${PCB} > $*.b; \
   rm $*.c; mv $*.b $*.c; \
	@echo "    $*.c -> $@"
	@${LINT} -c ${COPT} $*.c


.I.o :
	@echo "    $< -> $*.c"
	@if test "${DEBUG}" != "yes"; \
	then ${opp} ${DOPT} ${PPOPT} ${OPPOPT} ${OPPFLAGS} $< ; \
	else ${opp} -l ${DOPT} -DDEBUG=1 ${PPOPT} ${OPPOPT} ${OPPFLAGS} $< ; fi
	@if test "${JUNK_C}" = "yes" -o "${DEBUG}" = "yes"; then \
	   ${CB} < $*.c | ${DTAB} | ${PCB} > $*.b; rm $*.c; mv $*.b $*.c; fi
	@echo "    $*.c -> $@"
	@if test "${DEBUG}" != "yes"; \
	then ${CC} -c -ga ${ASOPTS} ${COPT} ${DOPT} $*.c ${CCFILTER}; \
	else ${CC} -c -g ${ASOPTS} ${COPT} ${DOPT} $*.c ${CCFILTER}; fi
	@if test "${JUNK_C}" != "yes" -a "${DEBUG}" != "yes"; \
	then rm $*.c; echo "    removing $*.c"; \
	else echo "    debug version $*.c left"; fi
	@if test "${JUNK_C}" = "yes"; \
	then echo c_stripping $*.c; c_strip $*.c; fi

.C.ln:
	@echo "    $< -> $*.c"
	@${omcpp} -l ${PPOPT} ${OPPOPT} ${OPPFLAGS} $< $*.c; \
   ${DOLLAR} < $*.c | ${LONGFLOAT} | ${CB} | ${DTAB} | ${PCB} > $*.b; \
   rm $*.c; mv $*.b $*.c; \
	@echo "    $*.c -> $@"
	@${LINT} -c ${COPT} $*.c

.C.o :
	@echo "    $< -> $*.c"
	@if test "${DEBUG}" != "yes"; \
	then ${omcpp} ${DOPT} ${PPOPT} ${OMCPPOPT} ${OPPFLAGS} $< $*.c; \
	else ${omcpp} -l ${DOPT} -DDEBUG=1 ${PPOPT} ${OMCPPOPT} ${OPPFLAGS} $< $*.c; fi
	@if test "${JUNK_C}" = "yes" -o "${DEBUG}" = "yes"; then \
	   ${CB} < $*.c | ${DTAB} | ${PCB} > $*.b; rm $*.c; mv $*.b $*.c; fi
	@echo "    $*.c -> $@"
	@if test "${DEBUG}" != "yes"; \
	then ${CC} -c -ga ${ASOPTS} ${COPT} ${DOPT} $*.c ${CCFILTER}; \
	else ${CC} -c -g ${ASOPTS} ${COPT} ${DOPT} $*.c ${CCFILTER}; fi
	@if test "${JUNK_C}" != "yes" -a "${DEBUG}" != "yes"; \
	then rm $*.c; echo "    removing $*.c"; \
	else echo "    debug version $*.c left"; fi

.c.ln :
	@echo "    $*.c -> $@"
	@${LINT} -c ${PPOPT} ${COPT} ${IPATH} $<

.c.o :
	@echo "    $*.c -> $@"
	@if test "${DEBUG}" != "yes"; \
	then ${CC} -c -ga ${ASOPTS} ${PPOPT} ${COPT} ${DOPT} ${IPATH} $< ; \
	else ${CC} -c -g -DDEBUG=1 ${ASOPTS} ${PPOPT} ${COPT} ${DOPT} ${IPATH} $< ; fi
	@if test "${DEBUG}" = "yes"; \
	then echo "    debug version of $*.c compiled"; fi
#	@echo $* > $@
