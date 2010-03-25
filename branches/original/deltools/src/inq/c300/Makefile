#
# Makefile for deltools/src/inq subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c300

DEPLIBS	= /usr/lib/${TARGET}/libix.a \
	/usr/lib/${TARGET}/libprot.a \
	/usr/lib/${TARGET}/libnsl_s.a \
	/usr/lib/${TARGET}/libc_s.a

LDLIBS	= -lix -lprot -lnsl_s -lc_s

DIR	= ${PATH_TO_PRODS}/prod.c3

INCDIRS	=

FILES	= ${DIR}/inqrop ${DIR}/inqfpeg ${DIR}/inqfpen ${DIR}/inqifb \
	${DIR}/inqifbtype ${DIR}/inqiop ${DIR}/inqmemory ${DIR}/inqscreens \
	${DIR}/inqswap ${DIR}/inqcpuid ${DIR}/inqzbuf ${DIR}/inqcptype \
	${DIR}/inqdiskless ${DIR}/inqsecure

EXECS	= ${DIR}/inqgra ${DIR}/inqscsi

SRCS_OBJS	= inqscsi.c inq.c
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
	rm -f ${EXECS} ${FILES}

clobber:: clean clear

${DIR}/inqgra: inq.o ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ inq.o ${LIBS} ${LDLIBS}
	@echo ""

${DIR}/inqscsi: inqscsi.o
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ inqscsi.o
	@echo ""

${FILES}: ${DIR}/inqgra
	@echo $@
	@rm -f $@
	@ln -f $? $@

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
