#
# Makefile for deltools/src/xvprod subdir
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
	/usr/lib/${TARGET}/libXFI_s.a \
	/usr/lib/${TARGET}/libXFS_s.a \
	/usr/lib/${TARGET}/libX11_s.a

LDLIBS	= -lXFI_s -lXFS_s -lX11_s -lm -lmalloc -linc -lbsd -lnsl -lgen \
	-lPW -lc_s

LIBS	=

DIR	= ${PATH_TO_PRODS}/prod

INCDIRS	= -I ../ -I ../../libmyemt/hfiles

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

FILES	= ${DIR}/vprod/runit.sh
EXECS	= ${DIR}/vprod/xvprod

SRCS_OBJS	= main.c notify.c errors.c misc.c prodlist.c connect.c \
	net.c tape.c proddate.c fsys.c keyfile.c lk.c moveprod.c walk.c \
	sh.c install.c def.c df.c prod_form.c pack_misc.c group_misc.c \
	class_form.c rm_misc.c tnote.c time_misc.c factor.c infp.c expand.c \
	multname.c fslist.c lostpeer.c xrunsh.c lex.yy.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${DIR}/vprod ${EXECS} ${FILES} ${FORMS}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DXVPROD -DVPROD -DXFORMS -DNEW_ARCHITECTURES -DSYSV -DSVR3 \
	-DXNS_NET -DL_ENDIAN

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

${DIR}/vprod/xvprod: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	@sh -c '${CC} ${AOPTS} ${CFLAGS} -c version.c -DVVERSION="\"`cat ../../../.version`\""'
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} version.o ${LIBS} ${LDLIBS}
	@echo ""

${DIR}/vprod/runit.sh: ../runit.sh
	@echo $@
	@rm -f $@
	@${CP} $? $@

${SRCS_OBJS} version.c:
	@rm -f $@
	@ln -f ../$@ .

../lex.yy.c: ../../newprod/addr.lex
	lex -t ../../newprod/addr.lex > ../lex.yy.c

${DIR}/vprod/classes.form: ../../vprod/forms/classes.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/connect.form: ../../vprod/forms/connect.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/deliver.form: ../../vprod/forms/deliver.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/forms.sym: ../../vprod/forms/forms.sym
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/fsavail.form: ../../vprod/forms/fsavail.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/group.form: ../../vprod/forms/group.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/help: ../../vprod/forms/help
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/help.hp: ../../vprod/forms/help.hp
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/help.hpInitHel: ../../vprod/forms/help.hpInitHel
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/load.form: ../../vprod/forms/load.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/loadkey.form: ../../vprod/forms/loadkey.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/lpeer.form: ../../vprod/forms/lpeer.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/multname.form: ../../vprod/forms/multname.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/new_view.form: ../../vprod/forms/new_view.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/pack.form: ../../vprod/forms/pack.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/prod_a.form: ../../vprod/forms/prod_a.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/prompt.form: ../../vprod/forms/prompt.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/rem_del.form: ../../vprod/forms/rem_del.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/rem_info.form: ../../vprod/forms/rem_info.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/rem_mach.form: ../../vprod/forms/rem_mach.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/setup.form: ../../vprod/forms/setup.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/show_prod.form: ../../vprod/forms/show_prod.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/show_sel.form: ../../vprod/forms/show_sel.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/stat.form: ../../vprod/forms/stat.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/time.form: ../../vprod/forms/time.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/vprod.14: ../../vprod/forms/vprod.14
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/vprod.form: ../../vprod/forms/vprod.form
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/vprod/vprod.sym: ../../vprod/forms/vprod.sym
	@echo $@
	@rm -f $@
	@${CP} $? $@
