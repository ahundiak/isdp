#
# Makefile for deltools/src/remove subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c400
C4FLAGS	= -D__cpu_c400__

DEPLIBS	=

LDLIBS	=

DIR	= ${PATH_TO_PRODS}/prod.c4
RDIR	= ${DIR}/.remove

INCDIRS	= -I ../

RFILES	= ${RDIR}/Menu.rm ${RDIR}/confirm.0m ${RDIR}/dates.0t \
	${RDIR}/diskusage.0t ${RDIR}/doit.sh ${RDIR}/fs.sh \
	${RDIR}/help.0t ${RDIR}/helptxt.db ${RDIR}/ldoit.sh \
	${RDIR}/mk_conf.sh ${RDIR}/products.0m ${RDIR}/products.sh \
	${RDIR}/qmk_conf.sh ${RDIR}/qprods.0m ${RDIR}/rm.0c ${RDIR}/rm.0i \
	${RDIR}/xdoit.sh

FILES	= ${DIR}/remove

EXECS	= ${RDIR}/gethelp

SRCS_OBJS	= gethelp.c
OBJECTS	= ${SRCS_OBJS:.c=.o}

TARG	= ${DIR}/.remove ${EXECS} ${FILES} ${RFILES}

include ${PATH_TO_SRC}/Makerules

CDEFS	= -DSYSV -DSVR3

depend: ${SRCS_OBJS} depend_strip depend_objs

strip:
	strip ${EXECS}
	mcs -d ${EXECS}

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_OBJS}

clear::
	rm -f ${EXECS} ${FILES} ${RFILES}

clobber:: clean clear

${DIR}/.remove:
	@if [ ! -d ${DIR}/.remove ]; \
	then \
		mkdir -p ${DIR}/.remove; \
	fi

${RDIR}/gethelp: ${OBJECTS} ${LIBS} ${DEPLIBS}
	@if [ "${RELEASE}" = "y" ]; \
	then \
		echo "\tremaking $@ because of : $? \n"; \
	fi
	${CC} ${LDOPT} ${AOPTS} -o $@ ${OBJECTS} ${LIBS} ${LDLIBS}
	@echo ""

${DIR}/remove: ../remove
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/Menu.rm: ../.remove/Menu.rm
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/confirm.0m: ../.remove/confirm.0m
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/dates.0t: ../.remove/dates.0t
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/diskusage.0t: ../.remove/diskusage.0t
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/doit.sh: ../.remove/doit.sh
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/fs.sh: ../.remove/fs.sh
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/help.0t: ../.remove/help.0t
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/helptxt.db: ../.remove/helptxt.db
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/ldoit.sh: ../.remove/ldoit.sh
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/mk_conf.sh: ../.remove/mk_conf.sh
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/products.0m: ../.remove//products.0m
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/products.sh: ../.remove/products.sh
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/qmk_conf.sh: ../.remove/qmk_conf.sh
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/qprods.0m: ../.remove/qprods.0m
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/rm.0c: ../.remove/rm.0c
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/rm.0i: ../.remove/rm.0i
	@echo $@
	@rm -f $@
	@${CP} $? $@

${RDIR}/xdoit.sh: ../.remove/xdoit.sh
	@echo $@
	@rm -f $@
	@${CP} $? $@

${SRCS_OBJS}:
	@rm -f $@
	@ln -f ../$@ .
