#!/bin/ksh
# $Id: makefile,v 1.1.1.1 2001/01/04 21:12:01 cvs Exp $

#**********************************************************************
# I/ROUTE
#
# File:		config/makfile
#
# Description:
#	makefile to create route.cmp from route.cmd
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:12:01  cvs
#	Initial import to CVS
#	
# Revision 1.5  1995/12/08  23:40:12  pinnacle
# Replaced: config/makefile for:  by r240_int for route240
#
# Revision 1.4  1995/12/08  21:31:36  pinnacle
# Replaced: config/makefile for:  by r240_int for route240
#
#
# History:
#	12/06/95	tlb	Modified to use CPP_COMP from environemnt
#	12/08/95	tlb	Modified to use empty.cmd
#
#
#**********************************************************************
.SUFFIXES: .cmd .cmp

CPPOPT	= -P -I$(ROUTE)/vrinclude -I$(ROUTE)/vcinclude

#-------------------
ALL:	cable.cmp route.cmp

route.cmp:

route.cmd:
	cp empty.cmd route.cmd

cable.cmp:

cable.cmd:
	cp c_empty.cmd cable.cmd

.cmd.cmp:
	@echo "\n\t$? -> $@"
	$(CPP_COMP) $(CPPOPT) $? | \
	awk '{ if ($$0 != "") print $$0 }' >$@
