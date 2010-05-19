# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdrecluster/ppl/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:06  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:42:08  pinnacle
# rep bin w/txt
#
# Revision 1.2  1995/12/06  23:40:32  pinnacle
# Replaced: vdrecluster/ppl/makefile for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/12/06  15:53:24  pinnacle
# Created: vdrecluster/ppl/makefile by jwfrosch for vds.240
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: $(VDS)/ppl/bin/Rebldlib.e

$(VDS)/ppl/bin/Rebldlib.e : Rebldlib.u
	@/bin/echo "\t remaking Rebldlib.e\n"
	$(GRNUC)/bin/cci -m -q -s -p$(EXNUC)/bin/omcpp	\
	-I$(GRNUC)/unix_include/$(CPUTYPE)		\
	-I$(BS)/include			\
	-I$(EXNUC)/include		\
	-I$(GRNUC)/include		\
	-I$(PDU)/include		\
	-I$(MODEL)/include		\
	-I$(VDS)/vdinclude		\
	-I$(VDS)/include		Rebldlib.u
	mv Rebldlib.e $(VDS)/ppl/bin/Rebldlib.e
