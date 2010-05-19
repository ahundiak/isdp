# $Id: makefile,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smframe/imp/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:06:52  pinnacle
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

target: $(VDS)/ppl/bin/SMFrPln.e \
	$(VDS)/ppl/bin/VDFrPln.e \
	mkfile 
	grmake -r -f mkfile


mkfile : smframeimp.m
	grmakemake smframeimp.m mkfile

$(VDS)/ppl/bin/SMFrPln.e : SMFrPln.u
	@/bin/echo "\t remaking SMFrPln.e\n"
	$(GRNUC)/bin/cci -q -s -p$(EXNUC)/bin/omcpp \
        -I$(BS)/include                 \
        -I$(EXNUC)/include              \
        -I$(GRNUC)/include              \
        -I$(GRNUC)/src/assoc/include_priv \
        -I$(MODEL)/include              \
	-I$(VDS)/vdinclude		\
        -I$(VDS)/include			SMFrPln.u
	mv SMFrPln.e $(VDS)/ppl/bin/SMFrPln.e

$(VDS)/ppl/bin/VDFrPln.e : VDFrPln.u
	@/bin/echo "\t remaking VDFrPln.e\n"
	$(GRNUC)/bin/cci -q -s -p$(EXNUC)/bin/omcpp \
        -I$(BS)/include                 \
        -I$(EXNUC)/include              \
        -I$(GRNUC)/include              \
        -I$(GRNUC)/src/assoc/include_priv \
        -I$(MODEL)/include              \
	-I$(VDS)/vdinclude		\
        -I$(VDS)/include			VDFrPln.u
	mv VDFrPln.e $(VDS)/ppl/bin/VDFrPln.e
