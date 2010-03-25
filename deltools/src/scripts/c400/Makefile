#
# Makefile for deltools/src/scripts subdir
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	= c400
C4FLAGS	= -D__cpu_c400__

DEPLIBS	=

LDLIBS	=

DIR	= ${PATH_TO_PRODS}/prod.c4

INCDIRS	= -I ../

FILES	= ${DIR}/Ingrinit ${DIR}/getmenus ${DIR}/inqlgexist \
	${DIR}/inqnativex ${DIR}/runcd

TARG	= ${FILES}

include ${PATH_TO_SRC}/Makerules

depend:

strip:

clean::

clear::
	rm -f ${FILES}

clobber:: clean clear

${DIR}/Ingrinit: ../Ingrinit
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/getmenus: ../getmenus
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/inqlgexist: ../inqlgexist
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/inqnativex: ../inqnativex
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/runcd: ../runcd
	@echo $@
	@rm -f $@
	@${CP} $? $@
