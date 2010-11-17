# $Id: makefile,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $

# -------------------------------------------------------------------
# I/VDS
#
# File:	vds/vdutil/makefile 
#
# Description:
#
# Dependencies:
#
# Revision History:
#	$Log: makefile,v $
#	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
#	Initial import to CVS
#	
# Revision 1.1  1997/05/08  14:52:14  pinnacle
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

target: mkfile
	grmake -r -k -f mkfile

mkfile: vdutil.m
	grmakemake vdutil.m mkfile

$(VDS)/ppl/bin/COlayers.e : COlayers.u
	@/bin/echo "\t remaking COlayers.e\n"
	$(GRNUC)/bin/cci -q -s -p$(EXNUC)/bin/omcpp \
        -I$(BS)/include                 \
        -I$(EXNUC)/include              \
        -I$(GRNUC)/include              \
        -I$(GRNUC)/srtc/assoc/include_priv \
        -I$(MODEL)/include              \
        -I$(PDU)/include                \
        -I$(VDS)/include			COlayers.u
	mv COlayers.e $(VDS)/ppl/bin/COlayers.e

clean:
	@rm -f mkfile *.e *.o
	@rm -f VDIdManage.c VDSLoadLay.c VDtrim.c VDdumpGeom.c VDSequip_ut.c VDerrHndlr.c VDSunits.c VDFindObjs.c
	@rm -f VDGetCodList.c VDchk_child.c VDmsgkey2str.c VDFitObj.c VDgetattsym.c VDusrAttrs.c VDMgmTagNum.c
	@rm -f VDfixRT.c VDSColUtil.c VDut_time.c VDrefList.c VDgetcdlst.c VDref_util.c VDMngShName.c VDDbParams.c
	@rm -f VDcompAttr.c VDprdMacFn.c VDget_name.c VDSequtil.c VDSPartAtt.c VDparameters.c

