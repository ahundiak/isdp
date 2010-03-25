#
# Makefile for deltools/src/nabdr subdir
# INTEL_SOLARIS target
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

DEPLIBS	=

LDLIBS	=

DIR	= ${PATH_TO_PRODS}/prod.isl

INCDIRS	= -I ../

EXECS	= ${DIR}/.cmsdr.

SRCS_OBJS	= cmsdr.c a2b32.c a2b64.c esne.c msne.c snerr.c \
		  crc32.c esapi.c msapi.c myctype.c wsapi.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS}

include ${PATH_TO_SRC}/Makerules

COPT	= -xO2
CDEFS	= -DSYSV -DSVR4 -DNEWDIRS -DL_ENDIAN -D_SYSV_ -D_STD_C_ \
	  -D_MSNE_DECONLY_ -D_A2B64_DECONLY_ -D_ESNE_DECONLY_ -D_A2B32_DECONLY_ 

depend: ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}

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
