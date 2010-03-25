#
# Makefile for deltools/src/dates subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c400
C4FLAGS	= -D__cpu_c400__

DEPLIBS	=

LDLIBS	=

DIR	= ${PATH_TO_PRODS}/prod.c4

INCDIRS	=

FILES	= ${DIR}/prodinfo ${DIR}/proddata

EXECS	= ${DIR}/dates

SRCS_OBJS	= dates.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS} ${FILES}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DSVR3

depend: ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}
	mcs -d ${EXECS}

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
