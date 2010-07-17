/* $Id: vrtools.m,v 1.7 2002/05/18 23:27:27 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / vrtools.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrtools.m,v $
 *	Revision 1.7  2002/05/18 23:27:27  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.6  2001/10/25 19:30:34  anand
 *	JTS TRs 5649, 5651 and 5652.
 *	
 *	Revision 1.5  2001/08/31 19:30:15  anand
 *	JTS TR MP 5098
 *	
 *	Revision 1.4  2001/08/03 17:29:39  louis
 *	tr4724-shifting duct syndrome
 *	
 *	Revision 1.3  2001/06/07 19:15:00  anand
 *	JTS CR MP 5189
 *	
 *	Revision 1.2  2001/05/11 21:56:58  louis
 *	TR3303 - HOSE component sometimes incorrectly being constructed as a VRPComp.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:13  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/04/20  18:08:44  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1997/10/25  17:30:48  pinnacle
# Replaced: vrtools/vrtools.m for:  by onayragu for route
#
# Revision 1.4  1997/10/24  23:35:02  pinnacle
# Replaced: vrtools/vrtools.m for:  by onayragu for route
#
# Revision 1.3  1997/10/24  20:44:50  pinnacle
# Replaced: vrtools/vrtools.m for:  by onayragu for route
#
# Revision 1.2  1997/09/08  00:36:40  pinnacle
# Replaced: vrtools/vrtools.m for:  by kddinov for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/03/11  17:13:24  pinnacle
# Replaced: vrtools/vrtools.m for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.5  1996/05/27  15:04:12  pinnacle
# Replaced: vrtools/vrtools.m for:  by r240_int for route240
#
# Revision 1.4  1996/01/18  00:33:52  pinnacle
# Replaced: vrtools/vrtools.m for:  by r240_int for route240
#
 *
 * History:
 *	01/17/96   tlb		Add BS, ROUTE prototypes, 
 *	04/20/99   Alwin	Added the entry VRRwDimen.I file
 *	05/11/01   law		Added SP protocol
 *
 *************************************************************************/
LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrtools.o
#else
$ROUTE/lib/vrtools.o
#endif

SOURCE
VRtolerance.I
VRcomtools.I
VRGetAttrib.I
VRGetChanObj.I
VRExtNozz.I
VRFormUtil.I
VRAttributes.I
VRSelect.I
VRModColl.I
VRTestColl.I
VRprivfunk.I
VRPlaceAuto.I
VRReplace.I
VROrie.I
VRPlCor.I
VRPlSeg.I
VRCreate.I
VREval.I
VREvalNoz.I
VREvalEquip.I
VRNozColl.I
VRPlace.I
VRPlaceNoz.I
VRDefSegPl.I
VRskfunk.I
VRskcon_funk.I
VRskutilfunk.I
VRhcfunk.I
VRlibfunk.I
VRget_params.I
VRsym_cache.I
VRsplitnet.I
ci_kludge.I
VRGlobFun.I
VRReConnect.I
VRInfo.I
VRLnUtil.I
VRFIutil.I
VRConnect.I
VRStubs.C
VRVerifyFunk.I
VR_Tracer.I
VR_Tracutil.I
VRStorage.I
VRRwDimen.I

SPEC
$VDS/spec
$ROUTE/spec
$EXNUC/spec
$GRNUC/spec
$EMS/spec
$MODEL/spec


INCLUDE
#if ISDP_MAKE_SP
$SPXR/include
$SPXR/vrinclude
$SPXV/include
$SPXV/vdinclude
$SPXR/vrinclude/prototypes
#endif
.
$ROUTE/include
$ROUTE/vrinclude
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$EMS/include
$MODEL/include
$BS/include
$VDS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes
$VDS/include
$VDS/vdinclude


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


