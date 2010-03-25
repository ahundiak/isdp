#
# Makefile for deltools/src/newprod subdir
# INTEL SOLARIS target
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

DEPLIBS 	= /usr/ccs/lib/libcurses.a \
	/usr/lib/libsocket.a \
	/usr/lib/libnsl.a \
	/usr/ccs/lib/libgen.a 

LDLIBS	= -lcurses -lsocket -lnsl -lgen

DIR	= ${PATH_TO_PRODS}/prod.isl

INCDIRS	= -I ../

EXECS	= ${DIR}/newprod ${DIR}/delserve

SRCS_OBJS	= main.c proddate.c menu.c tape.c getfile.c fsys.c \
	install.c prompt.c net.c cksum.c moveprod.c sh.c lk.c pgmenu.c \
	version.c keyfile.c walk.c fslist.c delserve.c access.c lex.yy.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS}

include	${PATH_TO_SRC}/Makerules

CDEFS	= -DSYSV -DSVR4 -DHOSTS_ACCESS -DNEW_ARCHITECTURES -DNEWDIRS \
	-DKEEP_USR_CLEAN -DDONT_SYMLINK -DL_ENDIAN


depend:	../lex.yy.c ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS}

clear::
	rm -f ${EXECS} ../lex.yy.c

clobber:: clean clear

NOBJECTS	= main.o proddate.o menu.o tape.o getfile.o fsys.o install.o \
	prompt.o net.o cksum.o moveprod.o sh.o lk.o pgmenu.o keyfile.o \
	walk.o fslist.o lex.yy.o
	

${DIR}/newprod: ${NOBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	@ksh -c '${CC} ${AOPTS} ${CFLAGS} -c ../version.c -DVERSION="\"`ksh version`\""'
	${CC} ${LDOPT} ${AOPTS} -o $@ ${NOBJECTS} version.o ${LIBS} ${LDLIBS}
	@echo ""


DOBJECTS	=  delserve.o cksum.o version.o keyfile.o access.o lex.yy.o

${DIR}/delserve: ${DOBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	@ksh -c '${CC} ${AOPTS} ${CFLAGS} -c version.c -DVERSION="\"`ksh version`\""'
	${CC} ${LDOPT} ${AOPTS} -o $@ ${DOBJECTS} version.o ${LIBS} ${LDLIBS}
	@echo ""


${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../@ .

../lex.yy.c:	../addr.lex
	lex -t ../addr.lex > ../lex.yy.c

