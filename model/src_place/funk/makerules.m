#   HISTORY
#
#   07 Feb 1989 jBk The addition of the usage of BREAK left
#                   blank .I files which were not really methods.
#                   This includes a fix for that problem.
#   02 Feb 1989 jBk Added definitions of TOUCHS and BREAK and use
#                   thereof in blanking all the lines before the
#                   function call in methods.
#   21 Sep 1988 jBk Added targets for shared libraries.
#   27 Jul 1988 jBk Eliminated removal of .c files in lint cases.
#                   I know not how that crept in here.
#   07 Apr 1988 jBk Additions and modifications to allow linting
#                   of files. 
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

lint:
	@make -${MAKEFLAGS} suffix=ln lint_all_objects

lint_all_objects: ${objects}

.S.o :
	@echo "    $< -> $*.c"
	@${opp} ${PPOPT} ${OPPOPT} ${OPPFLAGS} $<
	@if test "${JUNK_C}" = "yes" -o "${COPT}" = "-g"; then \
	   ${CB} < $*.c | ${DTAB} | ${PCB} > $*.b; rm $*.c; mv $*.b $*.c; fi
	@echo "    $*.c -> $@"
	@${CC} -c -ga ${COPT} -I${EXNUC}/include $*.c
	@if test "${COPT}" != "-g" -a "${JUNK_C}" != "yes"; \
	then rm $*.c; echo "    removing $*.c"; \
	else echo "    debug version $*.c left"; fi
	@if test "{JUNK_C}" = "yes" -o "${COPT}" = "-g"; \
	then ${TOUCHN} $*.c $?; fi
	@${TOUCHN} $@ $?
	@if test -f "${whlibname}"; \
	then ${TOUCH} 0101000070 "${whlibname}"; true; fi
#	@echo $* > $@

.I.ln:
	@echo "    $< -> $*.c"
	@${opp} -l ${PPOPT} ${OPPOPT} ${OPPFLAGS} $< ; \
   ${DOLLAR} < $*.c | ${LONGFLOAT} | ${CB} | ${DTAB} | ${PCB} > $*.b; \
   rm $*.c; mv $*.b $*.c; \
   ${TOUCHN} $*.c $?
	@echo "    $*.c -> $@"
	@${LINT} -c ${COPT} $*.c
	@${TOUCHN} $@ $?

.I.o :
	@echo "    $< -> $*.c"
	@if test "${DEBUG}" != "yes"; \
	then ${opp} ${PPOPT} ${OPPOPT} ${OPPFLAGS} $< ; \
	else ${opp} -l -DDEBUG=1 ${PPOPT} ${OPPOPT} ${OPPFLAGS} $< ; fi
	@if test "${JUNK_C}" = "yes" -o "${DEBUG}" = "yes"; then \
	   ${CB} < $*.c | ${DTAB} | ${PCB} > $*.b; rm $*.c; mv $*.b $*.c; fi
	@echo "    $*.c -> $@"
	@if test "${DEBUG}" != "yes"; \
	then ${CC} -c -ga ${ASOPTS} ${COPT} $*.c; \
	else ${CC} -c -g ${ASOPTS} ${COPT} $*.c; fi
	@if test "${JUNK_C}" != "yes" -a "${DEBUG}" != "yes"; \
	then rm $*.c; echo "    removing $*.c"; \
	else echo "    debug version $*.c left"; fi
	@if test "${JUNK_C}" = "yes"; \
	then echo c_stripping $*.c; c_strip $*.c; fi
	@if test "${JUNK_C}" = "yes" -o "${DEBUG}" = "yes"; \
	then \
	   ${TOUCHN} $*.c $?; \
	   if fgrep -l '_method(' $*.c > /dev/null ; \
	   then \
	       awk -f ${BREAK} < $*.c > /tmp/$*.c; \
	       ${TOUCHS} $*.c /tmp/$*.c; \
	       mv /tmp/$*.c $*.c; \
	   fi ; \
	fi
	@${TOUCHN} $@ $?
	@if test -f "${whlibname}"; \
	then ${TOUCH} 0101000070 "${whlibname}"; true; fi

.C.ln:
	@echo "    $< -> $*.c"
	@${omcpp} -l ${PPOPT} ${OPPOPT} ${OPPFLAGS} $< $*.c; \
   ${DOLLAR} < $*.c | ${LONGFLOAT} | ${CB} | ${DTAB} | ${PCB} > $*.b; \
   rm $*.c; mv $*.b $*.c; \
   ${TOUCHN} $*.c $?
	@echo "    $*.c -> $@"
	@${LINT} -c ${COPT} $*.c
	@${TOUCHN} $@ $?

.C.o :
	@echo "    $< -> $*.c"
	@if test "${DEBUG}" != "yes"; \
	then ${omcpp} ${PPOPT} ${OMCPPOPT} ${OPPFLAGS} $< $*.c; \
	else ${omcpp} -l -DDEBUG=1 ${PPOPT} ${OMCPPOPT} ${OPPFLAGS} $< $*.c; fi
	@if test "${JUNK_C}" = "yes" -o "${DEBUG}" = "yes"; then \
	   ${CB} < $*.c | ${DTAB} | ${PCB} > $*.b; rm $*.c; mv $*.b $*.c; fi
	@echo "    $*.c -> $@"
	@if test "${DEBUG}" != "yes"; \
	then ${CC} -c -ga ${ASOPTS} ${COPT} $*.c; \
	else ${CC} -c -g ${ASOPTS} ${COPT} $*.c; fi
	@if test "${JUNK_C}" != "yes" -a "${DEBUG}" != "yes"; \
	then rm $*.c; echo "    removing $*.c"; \
	else echo "    debug version $*.c left"; fi
	@if test "${JUNK_C}" = "yes" -o "${DEBUG}" = "yes"; \
	then ${TOUCHN} $*.c $?; fi
	@${TOUCHN} $@ $?
	@if test -f "${whlibname}"; \
	then ${TOUCH} 0101000070 "${whlibname}"; true; fi

.c.ln :
	@echo "    $*.c -> $@"
	@${LINT} -c ${PPOPT} ${COPT} ${IPATH} $<
	@${TOUCHN} $@ $?

.c.o :
	@echo "    $*.c -> $@"
	@if test "${DEBUG}" != "yes"; \
	then ${CC} -c -ga ${ASOPTS} ${PPOPT} ${COPT} ${IPATH} $<; \
	else ${CC} -c -g -DDEBUG=1 ${ASOPTS} ${PPOPT} ${COPT} ${IPATH} $<; fi
	@if test "${DEBUG}" = "yes"; \
	then echo "    debug version of $*.c compiled"; fi
	@${TOUCHN} $@ $?
	@if test -f "${whlibname}"; \
	then ${TOUCH} 0101000070 "${whlibname}"; true; fi
#	@echo $* > $@
