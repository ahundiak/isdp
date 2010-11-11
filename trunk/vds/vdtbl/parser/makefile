# $Id: make_PLOAD,v 1.1 2001/07/27 22:30:07 ylong Exp $

#**********************************************************************
# I/VDS
#
# File:	 vdtbl/parser /makefile
#
# Description:
#	makefile
#
# Dependencies:
#
# Revision History:
#	$Log: make_PLOAD,v $
#	Revision 1.1  2001/07/27 22:30:07  ylong
#	TR5473
#	
#	Revision 1.3  2001/01/30 21:13:15  ad
#	*** empty log message ***
#	
#	Revision 1.2  2001/01/08 19:08:16  art
#	ah
#	
# Revision 1.1  1997/05/08  15:45:06  pinnacle
# rep bin w/txt
#
# Revision 1.8  1996/06/19  22:27:12  pinnacle
# Replaced: vdtbl/parser/makefile for:  by v240_int for vds.240
#
# Revision 1.7  1996/06/10  17:47:28  pinnacle
# Replaced: vdtbl/parser/makefile for:  by tlbriggs for vds.240
#
# Revision 1.6  1996/06/08  00:12:22  pinnacle
# Replaced: vdtbl/parser/makefile for:  by tlbriggs for vds.240
#
# Revision 1.5  1996/06/07  23:47:06  pinnacle
# Replaced: vdtbl/parser/makefile for:  by tlbriggs for vds.240
#
# Revision 1.4  1995/11/22  23:51:38  pinnacle
# Replaced: ./vdtbl/parser/makefile for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/21  18:53:52  pinnacle
# Replaced: vdtbl/parser/makefile for:  by tlbriggs for vds.240
#
# Revision 1.2  1995/07/27  23:34:22  pinnacle
# Replaced: vdtbl/parser/makefile for:  by tlbriggs for vds.240
#
# Revision 1.1  1995/07/21  21:06:26  pinnacle
# Created: vdtbl/parser/makefile by tlbriggs for vds.240
#
#
#
# History:
#	06/29/95	tlb		create
#	07/25/95	tlb		modify exp linkage
#	08/19/95	tlb		modify rxp linkage
#	06/07/96	tlb		Fix exp compilation
#	06/10/96	tlb		Fix startup problem with header
#	06/19/96	tlb		Restore -d option to yacc
#	01/04/01	ah		Use yacc3.0 and lex3.0
#	01/30/01	ylong		TR4453, replace BUFSIZ with 2000
#**********************************************************************

#----------------------------------------------------
# Special parser rules

.SUFFIXES:  .l .y .C

PackageTag = VDyyexp

.y.C:
	@echo "\t$< -> y.tab.c <yacc>"
	@yacc30 $(YFLAGS) $*.y
	@echo "\ty.tab.c -> $*.C <sed>"
	@sed "s/yy/$(PackageTag)/g" y.tab.c | sed "s/YY/$(PackageTag)/g" > $*.C
	@echo "\ty.tab.h -> $*.h <sed>"
	@sed "s/yy/$(PackageTag)/g" y.tab.h | sed "s/YY/$(PackageTag)/g" > $*.h1
	echo "}" >> $*.C # Terminate additional "{" put to yyparse()
	@rm y.tab.c

.l.C:
	@echo "\t$< -> lex.yy.c <lex>"
	@lex30  $*.l
	@echo "\tlex.yy.c -> $*.C <sed>"
	@sed "s/yy/$(PackageTag)/g" lex.yy.c | sed "s/YY/$(PackageTag)/g" > $*.A
	@sed "s/BUFSIZ/2000/g" $*.A > $*.C
	@rm lex.yy.c $*.A 

#----------------------------------------------------
# make options
YFLAGS = -d 
#YFLAGS = -d -v
#MK_OPT = -DEBUG VERBOSE_RULES=yes
#MK_OPT = -DEBUG
#MKMK_OPT = -DEBUG -v

HDR	= 	${VDS}/vdinclude/VDexpdef.h \
		${VDS}/include/prototypes/VDexpproto.h

OBJ	= 	VDexpError.o VDexpFunc.o VDexpLex.o VDexpOp.o \
		VDexpParser.o VDexpPrint.o VDexpMisc.o VDexpKeyWord.o

MISC_OBJ = ../../vdmisc/VDsloprtn.o ../../vddraw/drw/VDdrwverbose.o	\
	   ../../vddraw/drw/VDdrwfprintf.o ../../vddraw/drw/VDdrwfcncall.o \
	   ../../vdmisc/VDstringUtil.o 

#----------------------------------------------------

target:	mkfile VDexpParser.C VDexpLex.C
#	export MKDOPT="$${MKDOPT} -DGRAMMAR "
	${GRNUC}/bin/grmake ${MK_OPT} -r -k -f mkfile

VDexpParser.y:	${HDR}
VDexpLex.l:	${HDR} VDexpParser.h

VDexpParser.C : VDexpParser.y
VDexpLex.C : 	VDexpLex.l

VDexpParser.h: 	VDexpParser.h1
	-cmp -s VDexpParser.h  VDexpParser.h1 || cp VDexpParser.h1 VDexpParser.h

VDexpParser.h1: VDexpParser.C
	touch VDexpParser.y
	make VDexpParser.C

mkfile:	vdtblpar.m makefile VDexpParser.C VDexpLex.C
	grmakemake ${MKMK_OPT} vdtblpar.m mkfile

exp.o:	exp.C ${VDS}/include/VDattrexp.h 
	${GRNUC}/bin/grmake ${MK_OPT} -r -k -f mkfile exp.o

exp:	target exp.o ${OBJ}
	acc -o exp exp.o ${OBJ} ${MISC_OBJ} -lm -lbsd

clean:
	@rm -f mkfile *.o *.c

