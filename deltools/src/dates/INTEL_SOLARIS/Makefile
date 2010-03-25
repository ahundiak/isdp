#
# Makefile for deltools/src/dates subdir
# INTEL_SOLARIS target
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

DEPLIBS	=

LDLIBS	=

DIR	= ${PATH_TO_PRODS}/prod.isl

INCDIRS	=

FILES	= ${DIR}/prodinfo ${DIR}/proddata

EXECS	= ${DIR}/dates

SRCS_OBJS	= dates.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS} ${FILES}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DSYSV -DSVR4 -DNEWDIRS -DL_ENDIAN

depend: ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS}

clear::
	rm -f ${EXECS} ${FILES}

clobber:: clean clear

${DIR}/dates: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} ${OBJS} ${LDLIBS}
	@echo ""

${DIR}/prodinfo: ${DIR}/dates
	@echo $@
	@rm -f $@
	@ln -f $? $@

${DIR}/proddata: ${DIR}/dates
	@echo $@
	@rm -f $@
	@ln -f $? $@

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
