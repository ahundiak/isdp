#
# Makefile for deltools/src/getanswer subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c100

DEPLIBS	= /usr/lib/${TARGET}/libPW.a

LDLIBS	= -lPW

DIR	= ${PATH_TO_PRODS}/prod

INCDIRS	= -I ../

EXECS	= ${DIR}/getanswer

SRCS_OBJS	= getanswer.c
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
# DO NOT DELETE THIS LINE -- make depends on it. 

getanswer.o:  /usr/include/_int_sarg.h
getanswer.o:  /usr/include/memory.h
getanswer.o:  /usr/include/standards.h
getanswer.o:  /usr/include/stdio.h
getanswer.o:  /usr/include/stdlib.h
getanswer.o:  /usr/include/string.h
getanswer.o:  /usr/include/sys/_int_sarg.h
getanswer.o:  /usr/include/sys/signal.h
getanswer.o:  /usr/include/sys/stat.h
getanswer.o:  /usr/include/sys/termio.h
getanswer.o:  /usr/include/sys/termios.h
getanswer.o:  /usr/include/sys/types.h
getanswer.o:  getanswer.c
