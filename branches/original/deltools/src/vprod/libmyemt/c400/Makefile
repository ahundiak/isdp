#
# Makefile for deltools/src/libmyemt subdir
#

PATH_TO_PRODS	= ../../../..
PATH_TO_SRC	= ../../..

TARGET	= c400
C4FLAGS	= -D__cpu_c400__

INCDIRS	= -I .

DIR	= .
LIB	= ${DIR}/libmyemt.a

SRCS_LIBS	= EMActive.c EMBracket.c EMClose.c EMCreate.c \
	EMCtrlChar.c EMDevice.c EMDisSetup.c EMDisplay.c EMEdit.c \
	EMErase.c EMEscape.c EMGenSetup.c EMInitGlob.c EMInitTCB.c \
	EMKeySetup.c EMMacSetup.c EMMisc.c EMModes.c EMParam.c \
	EMPosition.c EMPriSetup.c EMPrinter.c EMRegis.c EMReport.c \
	EMScroll.c EMSelect.c EMSetup.c EMState.c EMTabSetup.c EMText.c \
	EMTrans.c EMUpdate.c EMWrite.c
OBJECTS	= ${SRCS_LIBS:.c=.o}

TARG	= ${LIB}

include ${PATH_TO_SRC}/Makerules

depend: ${SRCS_LIBS} depend_strip depend_libs

strip:

clean::
	rm -f *.dbg core ${OBJECTS} ${SRCS_LIBS} 

clear::
	rm -f ${LIB}

clobber:: clean clear

${SRCS_LIBS}:
	@rm -f $@
	@ln -f ../$@ .
