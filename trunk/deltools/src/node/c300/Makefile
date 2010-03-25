#
# Makefile for deltools/src/node subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c300

DEPLIBS	= /usr/lib/${TARGET}/libinc.a \
	/usr/lib/${TARGET}/libix.a \
	/usr/lib/${TARGET}/libbsd.a \
	/usr/lib/${TARGET}/libgen.a \
	/usr/lib/${TARGET}/libmalloc.a \
	/usr/lib/${TARGET}/libnsl_s.a

LDLIBS	= -linc -lix -lbsd -lgen -lmalloc -lnsl_s

DIR	= ${PATH_TO_PRODS}/prod.c3/node

INCDIRS	= -I ../ -I ../../newprod

FILES	= ${DIR}/Initial ${DIR}/Info ${DIR}/r_newprod.dat \
	${DIR}/r_newprod.doc ${DIR}/README

EXECS	= ${DIR}/remote_newprod

SRCS_OBJS	= r_newprod.c infp.c factor.c lex.yy.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${EXECS} ${FILES}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DSYSV -DSVR3 -DXNS_NET -DL_ENDIAN

depend: ../lex.yy.c version.c ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}
	mcs -d ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS}

clear::
	rm -f ${EXECS} ${FILES}

clobber:: clean clear

${DIR}/remote_newprod: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	sh -c '${CC} $(CFLAGS) $(DEFS) -c version.c -DVERSION="\"`ksh ../../../deliv/version`\""'
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} version.o ${LIBS} ${LDLIBS}
	@echo ""

${SRCS_OBJS} version.c:
	@rm -f $@
	@ln -f ../$@ .

${DIR}/Initial: ../Initial
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/Info: ../Info
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/r_newprod.dat: ../r_newprod.dat
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/r_newprod.doc: ../r_newprod.doc
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/README: ../README
	@echo $@
	@rm -f $@
	@${CP} $? $@

../lex.yy.c: ../../newprod/addr.lex
	lex -t ../../newprod/addr.lex > ../lex.yy.c
