# $Id: makefile,v 1.1 2002/05/02 18:15:59 ahundiak Exp $
#***********************************************************************
# I/AIM
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
#	Revision 1.1  2002/05/02 18:15:59  ahundiak
#	*** empty log message ***
#	
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
#***********************************************************************

.SUFFIXES: .cmd .cmp

CPP	= $(CPP_COMP)
CPPOPT	= -P -I$(AIM)/include -I$(VDS)/include -I$(MODEL)/include -I$(GRNUC)/include -I$(EXNUC)/include

ALL:	aimsir.cmp

aimsir.cmd:
	cp aimempty.cmd aimsir.cmd

.cmd.cmp:
	@echo "\n\t$? -> $@"
	$(CPP_COMP) $(CPPOPT) $? | \
	awk '{ if ($$0 != "") print $$0 }' >$@
