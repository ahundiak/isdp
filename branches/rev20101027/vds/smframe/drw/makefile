# $Id: makefile,v 1.2 2001/05/24 21:48:12 jayadev Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/smframe/drw/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.2  2001/05/24 21:48:12  jayadev
#	*** empty log message ***
#	
#	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  15:06:38  pinnacle
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

target: $(VDS_PATH)/ppl/bin/COz_Frame.e2 \
	mkfile
	grmake -r -k -f mkfile
	@if test ${ISDP_MAKE_SP} -eq 1; \
	then \
	ldso    ${SPXV}/lib/smiframedrw; \
	/bin/cp ${SPXV}/lib/smiframedrw.so ${SPV};   \
	fi

mkfile: smfrdrw.m
	grmakemake smfrdrw.m mkfile

$(VDS_PATH)/ppl/bin/COz_Frame.e2 :

$(VDS_PATH)/ppl/bin/COz_Frame.e : COz_Frame.u
	@/bin/echo "\t remaking COz_Frame.e\n"
	$(GRNUC)/bin/cci -m -q -s -p$(EXNUC)/bin/omcpp \
	-I$(BS)/include			\
	-I$(EXNUC)/include		\
	-I$(GRNUC)/include		\
	-I$(GRNUC)/src/assoc/include_priv		\
	-I$(MODEL)/include		\
	-I$(VDS)/vdinclude		\
	-I$(VDS)/include		COz_Frame.u
	mv COz_Frame.e $(VDS_PATH)/ppl/bin/COz_Frame.e

