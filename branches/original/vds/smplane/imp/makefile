# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smplane/imp/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:07:52  pinnacle
# rep bin w/txt
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
#
# History:
#	MM/DD/YY	AUTHOR		DESCRIPTION
#
# -------------------------------------------------------------------

target: $(VDS)/ppl/bin/SMInfPlane.e \
	mkfile 
	grmake -r -f mkfile


mkfile : smplaneimp.m
	grmakemake smplaneimp.m mkfile

$(VDS)/ppl/bin/SMInfPlane.e : SMInfPlane.u
	@/bin/echo "\t remaking SMInfPlane.e\n"
	$(GRNUC)/bin/cci -q -s -p$(EXNUC)/bin/omcpp \
        -I$(BS)/include                 \
        -I$(EXNUC)/include              \
        -I$(GRNUC)/include              \
        -I$(PDU)/include                \
        -I$(MODEL)/include              \
        -I$(VDS)/include			SMInfPlane.u
	mv SMInfPlane.e $(VDS)/ppl/bin/SMInfPlane.e
