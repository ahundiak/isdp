#
# Makefile for deltools/src/nabdr subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c400
C4FLAGS	= -D__cpu_c400__

DEPLIBS	= /usr/lib/${TARGET}/libix.a

LDLIBS	= -lix

DIR	= ${PATH_TO_PRODS}/prod.c4

INCDIRS	= -I ../

EXECS	= ${DIR}/.cmsdr.

SRCS_OBJS	= cmsdr.c a2b32.c a2b64.c esne.c msne.c snerr.c \
		  crc32.c esapi.c msapi.c myctype.c wsapi.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS}

include ${PATH_TO_SRC}/Makerules

COPT	= -O0
CDEFS	= -DSVR3 -Dclipper -D_SYSV_ -D_MSNE_DECONLY_ -D_A2B64_DECONLY_ \
	  -D_ESNE_DECONLY_ -D_A2B32_DECONLY_ 

depend: ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}
	mcs -d ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS}

clear::
	rm -f ${EXECS}

clobber:: clean clear

${DIR}/.cmsdr.: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} ${LIBS} ${LDLIBS}
	@echo ""

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
