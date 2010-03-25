#
# Makefile for deltools/src/newprod subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c100

DDEPLIBS	= /usr/lib/${TARGET}/libcmd.a \
	/usr/lib/${TARGET}/libprot.a \
	/usr/lib/${TARGET}/libaudit.a \
	/usr/lib/${TARGET}/libcrypt.a \
	/usr/lib/${TARGET}/libinc.a \
	/usr/lib/${TARGET}/libnsl.a \
	/usr/lib/${TARGET}/libix.a \
	/usr/lib/${TARGET}/libbsd.a \
	/usr/lib/${TARGET}/libcurses.a \
	/usr/lib/${TARGET}/libmalloc.a \
	/usr/lib/${TARGET}/libgen.a \
	/usr/lib/${TARGET}/libPW.a \
	/usr/lib/${TARGET}/libc.a

DLDLIBS	= -lcmd -lprot -laudit -lcrypt -linc -lnsl -lix -lbsd \
	-lcurses -lmalloc -lgen -lPW -lc

DEPLIBS	= /usr/lib/${TARGET}/libinc.a \
	/usr/lib/${TARGET}/libnsl.a \
	/usr/lib/${TARGET}/libix.a \
	/usr/lib/${TARGET}/libbsd.a \
	/usr/lib/${TARGET}/libcurses.a \
	/usr/lib/${TARGET}/libmalloc.a \
	/usr/lib/${TARGET}/libgen.a \
	/usr/lib/${TARGET}/libPW.a \
	/usr/lib/${TARGET}/libc.a

LDLIBS	= -linc -lnsl -lix -lbsd -lcurses -lmalloc -lgen -lPW -lc

DIR	= ${PATH_TO_PRODS}/prod

INCDIRS	= -I ../

EXECS	= ${DIR}/newprod ${DIR}/delserve

SRCS_OBJS	= main.c proddate.c menu.c tape.c getfile.c fsys.c \
	install.c prompt.c net.c cksum.c moveprod.c sh.c lk.c pgmenu.c \
	version.c keyfile.c walk.c fslist.c delserve.c access.c \
	fakesyslog.c check_sec.c lex.yy.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DSYSV -DSVR3 -DNEW_ARCHITECTURES -DL_ENDIAN -DXNS_NET \
	-DHOSTS_ACCESS -DFAKESYSLOG -DSecureWare -DSYSV_3 -DBT -DSEC_NET_TTY

depend: ../lex.yy.c ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}
	mcs -d ${EXECS}

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
	@ksh -c '${CC} ${AOPTS} ${CFLAGS} -c version.c -DVERSION="\"`ksh version`\""'
	${CC} ${LDOPT} ${AOPTS} -o $@ ${NOBJECTS} version.o ${LIBS} ${LDLIBS}
	@echo ""

DOBJECTS	= delserve.o cksum.o keyfile.o access.o fakesyslog.o \
	check_sec.o lex.yy.o

${DIR}/delserve: ${DOBJECTS} ${DLIBS} ${DDEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	@ksh -c '${CC} ${AOPTS} ${CFLAGS} -c version.c -DVERSION="\"`ksh version`\""'
	${CC} ${LDOPT} ${AOPTS} -o $@ ${DOBJECTS} version.o ${DLIBS} ${DLDLIBS}
	@echo ""

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .

../lex.yy.c: ../addr.lex
	lex -t ../addr.lex > ../lex.yy.c
