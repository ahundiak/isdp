#
# Makefile for deltools/src/getanswer subdir
# INTEL_SOLARIS target
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

DEPLIBS	= /usr/ccs/lib/libgen.a

LDLIBS	= -lgen

DIR	= ${PATH_TO_PRODS}/prod.isl

INCDIRS	= -I ../

EXECS	= ${DIR}/getanswer

SRCS_OBJS	= getanswer.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DSYSV -DSVR4 -DNEWDIRS -DL_ENDIAN

depend: ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS}

clear::
	rm -f ${EXECS}

clobber:: clean clear

${DIR}/getanswer: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} ${LIBS} ${LDLIBS}
	@echo ""

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
