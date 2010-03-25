#
# Makefile for deltools/src/scripts subdir
# INTEL_SOLARIS target
#

PATH_TO_PRODS	= ../../..
PATH_TO_SRC	= ../..

TARGET	=

DEPLIBS	=

LDLIBS	=

DIR	= ${PATH_TO_PRODS}/prod.isl

INCDIRS	= -I ../

FILES	= ${DIR}/Ingrinit ${DIR}/inqlgexist ${DIR}/runcd

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

${DIR}/inqlgexist: ../inqlgexist
	@echo $@
	@rm -f $@
	@${CP} $? $@

${DIR}/runcd: ../runcd
	@echo $@
	@rm -f $@
	@${CP} $? $@
