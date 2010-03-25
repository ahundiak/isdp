#
# Makefile for deltools/src/dates subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c100

DEPLIBS	=

LDLIBS	=

DIR	= ${PATH_TO_PRODS}/prod

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
# DO NOT DELETE THIS LINE -- make depends on it. 

dates.o:  /usr/include/_int_sarg.h
dates.o:  /usr/include/ctype.h
dates.o:  /usr/include/memory.h
dates.o:  /usr/include/signal.h
dates.o:  /usr/include/standards.h
dates.o:  /usr/include/stdio.h
dates.o:  /usr/include/stdlib.h
dates.o:  /usr/include/string.h
dates.o:  /usr/include/sys/_int_sarg.h
dates.o:  /usr/include/sys/signal.h
dates.o:  /usr/include/sys/types.h
dates.o:  dates.c
