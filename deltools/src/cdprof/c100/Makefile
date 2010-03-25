#
# Makefile for deltools/src/cdprof subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c100

DEPLIBS	= /usr/lib/${TARGET}/libix.a

LDLIBS	= -lix

DIR	= ${PATH_TO_PRODS}/prod

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
# DO NOT DELETE THIS LINE -- make depends on it. 

get_prof.o:  ../main.h
get_prof.o:  /usr/include/_int_sarg.h
get_prof.o:  /usr/include/fcntl.h
get_prof.o:  /usr/include/standards.h
get_prof.o:  /usr/include/stdio.h
get_prof.o:  /usr/include/stdlib.h
get_prof.o:  /usr/include/sys/_int_sarg.h
get_prof.o:  /usr/include/sys/fcntl.h
get_prof.o:  /usr/include/sys/types.h
get_prof.o:  get_prof.c
keys.o:  /usr/include/_int_sarg.h
keys.o:  /usr/include/dirent.h
keys.o:  /usr/include/errno.h
keys.o:  /usr/include/fcntl.h
keys.o:  /usr/include/ftw.h
keys.o:  /usr/include/memory.h
keys.o:  /usr/include/search.h
keys.o:  /usr/include/standards.h
keys.o:  /usr/include/stdio.h
keys.o:  /usr/include/stdlib.h
keys.o:  /usr/include/string.h
keys.o:  /usr/include/sys/_int_sarg.h
keys.o:  /usr/include/sys/dirent.h
keys.o:  /usr/include/sys/errno.h
keys.o:  /usr/include/sys/fcntl.h
keys.o:  /usr/include/sys/fs/s5dir.h
keys.o:  /usr/include/sys/fs/s5param.h
keys.o:  /usr/include/sys/fstyp.h
keys.o:  /usr/include/sys/param.h
keys.o:  /usr/include/sys/pinfo.h
keys.o:  /usr/include/sys/signal.h
keys.o:  /usr/include/sys/stat.h
keys.o:  /usr/include/sys/statfs.h
keys.o:  /usr/include/sys/sysclip.h
keys.o:  /usr/include/sys/sysinfo.h
keys.o:  /usr/include/sys/types.h
keys.o:  /usr/include/sys/user.h
keys.o:  /usr/include/unistd.h
keys.o:  keys.c
