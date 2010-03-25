#
# Makefile for deltools/src/showconfig subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c100

DEPLIBS	=

LDLIBS	=

DIR	= ${PATH_TO_PRODS}/prod

INCDIRS	= -I ../

FILES	= ${DIR}/showconfig.dat ${DIR}/netboards

EXECS	= ${DIR}/showconfig

SRCS_OBJS	= showconfig.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS} ${FILES}

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

${DIR}/showconfig: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} ${LIBS} ${LDLIBS}
	@echo ""

${DIR}/showconfig.dat: ../showconfig.dat
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/netboards: ../netboards
	@echo $@
	@rm -f $@
	@${CP} $? $@

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
