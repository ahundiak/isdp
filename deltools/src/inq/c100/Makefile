#
# Makefile for deltools/src/inq subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c100

DEPLIBS	= /usr/lib/${TARGET}/libix.a \
	/usr/lib/${TARGET}/libprot.a \
	/usr/lib/${TARGET}/libnsl_s.a \
	/usr/lib/${TARGET}/libc_s.a

LDLIBS	= -lix -lprot -lnsl_s -lc_s

DIR	= ${PATH_TO_PRODS}/prod

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
# DO NOT DELETE THIS LINE -- make depends on it. 

inq.o:  /usr/include/_int_sarg.h
inq.o:  /usr/include/fcntl.h
inq.o:  /usr/include/inc.h
inq.o:  /usr/include/signal.h
inq.o:  /usr/include/standards.h
inq.o:  /usr/include/stdio.h
inq.o:  /usr/include/stdlib.h
inq.o:  /usr/include/sys/_int_sarg.h
inq.o:  /usr/include/sys/cammu_C1.h
inq.o:  /usr/include/sys/dir.h
inq.o:  /usr/include/sys/fcntl.h
inq.o:  /usr/include/sys/fs/s5dir.h
inq.o:  /usr/include/sys/fs/s5param.h
inq.o:  /usr/include/sys/immu.h
inq.o:  /usr/include/sys/param.h
inq.o:  /usr/include/sys/pinfo.h
inq.o:  /usr/include/sys/signal.h
inq.o:  /usr/include/sys/sr.h
inq.o:  /usr/include/sys/stat.h
inq.o:  /usr/include/sys/swap.h
inq.o:  /usr/include/sys/sysclip.h
inq.o:  /usr/include/sys/sysinfo.h
inq.o:  /usr/include/sys/sysingr.h
inq.o:  /usr/include/sys/types.h
inq.o:  /usr/include/sys/user.h
inq.o:  inq.c
inqscsi.o:  /usr/include/_int_sarg.h
inqscsi.o:  /usr/include/errno.h
inqscsi.o:  /usr/include/fcntl.h
inqscsi.o:  /usr/include/standards.h
inqscsi.o:  /usr/include/stdio.h
inqscsi.o:  /usr/include/stdlib.h
inqscsi.o:  /usr/include/sys/_int_sarg.h
inqscsi.o:  /usr/include/sys/buf.h
inqscsi.o:  /usr/include/sys/errno.h
inqscsi.o:  /usr/include/sys/fcntl.h
inqscsi.o:  /usr/include/sys/gs.h
inqscsi.o:  /usr/include/sys/types.h
inqscsi.o:  inqscsi.c
