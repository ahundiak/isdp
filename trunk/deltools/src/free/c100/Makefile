#
# Makefile for deltools/src/free subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c100

DEPLIBS	= /usr/lib/${TARGET}/libcmd.a \
	/usr/lib/${TARGET}/libaudit.a \
	/usr/lib/${TARGET}/libprot.a

LDLIBS	= -lcmd -laudit -lprot

DIR	= ${PATH_TO_PRODS}/prod

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
# DO NOT DELETE THIS LINE -- make depends on it. 

free.o:  /usr/include/_int_sarg.h
free.o:  /usr/include/errno.h
free.o:  /usr/include/memory.h
free.o:  /usr/include/mnttab.h
free.o:  /usr/include/standards.h
free.o:  /usr/include/stdio.h
free.o:  /usr/include/stdlib.h
free.o:  /usr/include/string.h
free.o:  /usr/include/sys/_int_sarg.h
free.o:  /usr/include/sys/cammu_C1.h
free.o:  /usr/include/sys/errno.h
free.o:  /usr/include/sys/fs/s5param.h
free.o:  /usr/include/sys/fsid.h
free.o:  /usr/include/sys/fstyp.h
free.o:  /usr/include/sys/immu.h
free.o:  /usr/include/sys/inode.h
free.o:  /usr/include/sys/param.h
free.o:  /usr/include/sys/proc.h
free.o:  /usr/include/sys/region.h
free.o:  /usr/include/sys/sec/audit.h
free.o:  /usr/include/sys/sec/auditsysc.h
free.o:  /usr/include/sys/sec/sectypes.h
free.o:  /usr/include/sys/sec/security.h
free.o:  /usr/include/sys/stat.h
free.o:  /usr/include/sys/statfs.h
free.o:  /usr/include/sys/types.h
free.o:  free.c
