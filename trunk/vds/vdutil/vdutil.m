/* $Id: vdutil.m,v 1.3 2001/01/26 00:37:21 build Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdutil / vdutil.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdutil.m,v $
 *	Revision 1.3  2001/01/26 00:37:21  build
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/10 18:12:25  art
 *	sp merge
 *	
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  2000/02/10  21:44:54  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/26  18:00:32  pinnacle
# Replaced: vdutil/vdutil.m for:  by yzhu for vds
#
 *
 * History:
 * 	11/05/95	tlb		Remove VDconst*.I
 * 	05/07/96	Sundar		Added  VDtrim.C
 * 	01/17/97	Sundar		Added  $(VDS)/include/prototypes
 *      01/09/00        ah              262 SP Merge
 * -------------------------------------------------------------------*/

SOURCE
VDSutil.c
VDSLoadLay.I
VDSColUtil.I
VDref_util.I
VDSequip_ut.C
VDSequtil.C
VDSunits.C
VDgetcdlst.C
VDSPartAtt.C
VDIdManage.C
VDMgmTagNum.C
VDMngShName.C
VDGetCodList.C
VDget_name.I
/* VDSstatus.C */
VDparameters.I
VDusrAttrs.I
VDgetattsym.C
VDerrHndlr.C
VDmsgkey2str.C
VDprdMacFn.I
VDut_time.C
VDrefList.I
VDmemUtil.c
VDchk_child.I
VDFitObj.I
VDtrim.C
VDDbParams.I
VDFindObjs.I
VDdumpGeom.I
VDcompAttr.I    
VDfixRT.I  

LIB
$VDS/lib/vdiutil.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$PDU/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$UMS/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
