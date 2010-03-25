#
# Makefile for deltools/src/cdprof subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c400
C4FLAGS	= -D__cpu_c400__

DEPLIBS	= /usr/lib/${TARGET}/libix.a

LDLIBS	= -lix

DIR	= ${PATH_TO_PRODS}/prod.c4

INCDIRS	= -I ../

EXECS	= ${DIR}/getcdkeys

SRCS_OBJS	= get_prof.c keys.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DSYSV -DSVR3 -DL_ENDIAN

depend: ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}
	mcs -d ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS}

clear::
	rm -f ${EXECS}

clobber:: clean clear

${DIR}/getcdkeys: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} ${LIBS} ${LDLIBS}
	@echo ""

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
