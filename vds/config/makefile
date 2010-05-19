# $Id: makefile,v 1.4 2002/03/30 15:45:31 ad Exp $
#***********************************************************************
# I/VDS
#
# File:		config/makefile
#
# Description:
#		Makefile for creation of .cmp file
#
# Dependencies:
#		Local .cmd files.
# Revision History
#	$Log: makefile,v $
#	Revision 1.4  2002/03/30 15:45:31  ad
#	*** empty log message ***
#	
#	Revision 1.3  2002/03/30 15:41:40  ad
#	*** empty log message ***
#	
#	Revision 1.2  2001/04/20 13:40:03  ylong
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:07:23  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  14:49:28  pinnacle
# rep bin w/txt
#
# Revision 1.8  1996/02/08  20:09:00  pinnacle
# Replaced: config/makefile for:  by azuurhou for vds.240
#
# Revision 1.7  1996/02/04  15:34:36  pinnacle
# Replaced: config/makefile for:  by azuurhou for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#	02/04/96	adz		adapt for hidden command list.
#
#***********************************************************************
# CMDS	= sman.cmd vds.cmd hrd.cmd hidden.cmd
# CMPS	= sman.cmp vds.cmp hrd.cmp
# .SUFFIXES: .cmd .cmp

CPP	= $(CPP_COMP)
CPPOPT	= -P -I$(VDS)/include -I$(MODEL)/include -I$(GRNUC)/include -I$(EXNUC)/include

target:	vds.cmp sman.cmp hrd.cmp

sman.cmp: sman.cmd
	@echo "\n\tsman.cmd -> sman.cmp"
	$(CPP) $(CPPOPT) ${VDS}/config/sman.cmd | \
		awk '{ if ($$0 != "") print $$0 }' > sman.cmp1
	replace "	" "" sman.cmp1
	awk -f hidden.cmd < sman.cmp1 > sman.cmp
	rm -f sman.cmp1

vds.cmp: vds.cmd
	@echo "\n\tvds.cmd -> vds.cmp"
	$(CPP) $(CPPOPT) ${VDS}/config/vds.cmd | \
		awk '{ if ($$0 != "") print $$0 }' > vds.cmp1
	replace "	" "" vds.cmp1
	awk -f hidden.cmd < vds.cmp1 > vds.cmp
	rm -f vds.cmp1

hrd.cmp: hrd.cmd
	@echo "\n\thrd.cmd -> hrd.cmp"
	$(CPP) $(CPPOPT) ${VDS}/config/hrd.cmd | \
		awk '{ if ($$0 != "") print $$0 }' > hrd.cmp1
	replace "	" "" hrd.cmp1
	awk -f hidden.cmd < hrd.cmp1 > hrd.cmp
	rm -f hrd.cmp1
