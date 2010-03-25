#
# Makefile for deltools/src/rm_pg subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c100

DEPLIBS	= /usr/lib/${TARGET}/libcurses.a

LDLIBS	= -lcurses

DIR	= ${PATH_TO_PRODS}/prod

INCDIRS	= -I ../

EXECS	= ${DIR}/rm_pg

SRCS_OBJS	= main.c rm_misc.c page_misc.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DSYSV -DSVR3

depend: ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}
	mcs -d ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS}

clear::
	rm -f ${EXECS}

clobber:: clean clear

${DIR}/rm_pg: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} ${LIBS} ${LDLIBS}
	@echo ""

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
