#
# Makefile for deltools/src/vprod subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c100

DEPLIBS	= /usr/lib/${TARGET}/libinc.a \
	/usr/lib/${TARGET}/libnsl.a \
	/usr/lib/${TARGET}/libm.a \
	/usr/lib/${TARGET}/libbsd.a \
	/usr/lib/${TARGET}/libmalloc.a \
	/usr/lib/${TARGET}/libgen.a \
	/usr/lib/${TARGET}/libPW.a \
	/usr/lib/${TARGET}/libc_s.a \
	/usr/lib/${TARGET}/libforms_s.a \
	/usr/lib/${TARGET}/libitems_s.a \
	/usr/lib/${TARGET}/libtools_s.a \
	/usr/lib/${TARGET}/libhelp.a

LDLIBS	= -lforms_s -litems_s -ltools_s -lhelp -lm -lmalloc \
	-linc -lbsd -lnsl -lgen -lPW -lc_s

LIBS	= ../libmyemt/${TARGET}/libmyemt.a

DIR	= ${PATH_TO_PRODS}/prod

INCDIRS	= -I .. -I ../libmyemt/hfiles

FDIR	= ${DIR}/vprod
FORMS	= ${FDIR}/classes.form \
	${FDIR}/connect.form \
	${FDIR}/deliver.form \
	${FDIR}/forms.sym \
	${FDIR}/fsavail.form \
	${FDIR}/group.form \
	${FDIR}/help \
	${FDIR}/help.hp \
	${FDIR}/help.hpInitHel \
	${FDIR}/load.form \
	${FDIR}/loadkey.form \
	${FDIR}/lpeer.form \
	${FDIR}/multname.form \
	${FDIR}/new_view.form \
	${FDIR}/pack.form \
	${FDIR}/prod_a.form \
	${FDIR}/prompt.form \
	${FDIR}/rem_del.form \
	${FDIR}/rem_info.form \
	${FDIR}/rem_mach.form \
	${FDIR}/setup.form \
	${FDIR}/show_prod.form \
	${FDIR}/show_sel.form \
	${FDIR}/stat.form \
	${FDIR}/time.form \
	${FDIR}/vprod.14 \
	${FDIR}/vprod.form \
	${FDIR}/vprod.sym

EXECS	= ${DIR}/vprod/vprod

SRCS_OBJS	= main.c notify.c errors.c misc.c prodlist.c connect.c \
	net.c tape.c proddate.c fsys.c keyfile.c lk.c moveprod.c walk.c \
	sh.c install.c def.c df.c prod_form.c spawn.c runsh.c pack_misc.c \
	group_misc.c class_form.c rm_misc.c tnote.c time_misc.c factor.c \
	infp.c expand.c multname.c fslist.c lostpeer.c lex.yy.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${DIR}/vprod ${EXECS} ${FORMS}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DVPROD -DSYSV -DSVR3 -DNEW_ARCHITECTURES -DL_ENDIAN -DXNS_NET

depend: ../lex.yy.c ${SRCS_OBJS} version.c depend_strip depend_objs

strip:
	strip ${EXECS}
	mcs -d ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS} version.c

clear::
	rm -f ${EXECS} ../lex.yy.c

clobber:: clean clear

${DIR}/vprod:
	@if [ ! -d $@ ]; \
	then \
		mkdir -p $@; \
	fi

${DIR}/vprod/vprod: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	@ksh -c '${CC} ${AOPTS} ${CFLAGS} -c version.c -DVVERSION="\"`cat ../../../.version`\""'
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} version.o ${LIBS} ${LDLIBS}
	@echo ""

${SRCS_OBJS} version.c:
	@rm -f $@
	@ln -f ../$@ .

../lex.yy.c: ../../newprod/addr.lex
	lex -t ../../newprod/addr.lex > ../lex.yy.c

${DIR}/vprod/classes.form: ../forms/classes.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/connect.form: ../forms/connect.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/deliver.form: ../forms/deliver.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/forms.sym: ../forms/forms.sym
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/fsavail.form: ../forms/fsavail.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/group.form: ../forms/group.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/help: ../forms/help
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/help.hp: ../forms/help.hp
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/help.hpInitHel: ../forms/help.hpInitHel
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/load.form: ../forms/load.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/loadkey.form: ../forms/loadkey.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/lpeer.form: ../forms/lpeer.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/multname.form: ../forms/multname.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/new_view.form: ../forms/new_view.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/pack.form: ../forms/pack.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/prod_a.form: ../forms/prod_a.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/prompt.form: ../forms/prompt.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/rem_del.form: ../forms/rem_del.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/rem_info.form: ../forms/rem_info.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/rem_mach.form: ../forms/rem_mach.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/setup.form: ../forms/setup.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/show_prod.form: ../forms/show_prod.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/show_sel.form: ../forms/show_sel.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/stat.form: ../forms/stat.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/time.form: ../forms/time.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/vprod.14: ../forms/vprod.14
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/vprod.form: ../forms/vprod.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/vprod.sym: ../forms/vprod.sym
	@echo $@
	@rm -f $@
	@${CP} $? $@
