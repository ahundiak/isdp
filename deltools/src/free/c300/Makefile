#
# Makefile for deltools/src/free subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c300

DEPLIBS	= /usr/lib/${TARGET}/libcmd.a \
	/usr/lib/${TARGET}/libaudit.a \
	/usr/lib/${TARGET}/libprot.a

LDLIBS	= -lcmd -laudit -lprot

DIR	= ${PATH_TO_PRODS}/prod.c3

INCDIRS	= -I ../

EXECS	= ${DIR}/Free

SRCS_OBJS	= free.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DSYSV -DSVR3 -DSecureWare -DSYSV_3 -DBT

depend: ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}
	mcs -d ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS}

clear::
	rm -f ${EXECS}

clobber:: clean clear

${DIR}/Free: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} ${LIBS} ${LDLIBS}
	@echo ""

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
