#
# Makefile for deltools/src/cdprof subdir
# INTEL_SOLARIS target
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

DEPLIBS	= 

LDLIBS	= 

DIR	= ${PATH_TO_PRODS}/prod.isl

INCDIRS	= -I ../

EXECS	= ${DIR}/getcdkeys \
	  ${DIR}/interfaces

SRCS_OBJS	= get_prof.c keys.c
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

${DIR}/getcdkeys: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} ${LIBS} ${LDLIBS}
	@echo ""

${DIR}/interfaces: ../interfaces.isl
	@cp ../interfaces.isl $@

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
