/* $Id: vrco.m,v 1.5 2002/05/18 23:27:26 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco / vrco.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrco.m,v $
 *	Revision 1.5  2002/05/18 23:27:26  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.4  2001/08/31 19:30:15  anand
 *	JTS TR MP 5098
 *	
 *	Revision 1.3  2001/04/03 20:32:09  anand
 *	TR JTS 4485
 *	
 *	Revision 1.2  2001/01/22 17:44:06  anand
 *	Merged func.I into VRfunc.I
 *	func.I is therefore redundant in vrco directory.
 *	It's entry has been removed from the vrco.m file.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/24  22:07:02  pinnacle
# Replaced: vrco/vrco.m for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/03/04  17:47:34  pinnacle
# Replaced: vrco/vrco.m for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  21:17:46  pinnacle
# Replaced: vrco/vrco.m for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/
CC
acc -ansi -Atarg=c300

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrco.o
#else
$ROUTE/lib/vrco.o
#endif

SOURCE
VRCmpMgr.S
VRCmpMgri.I

VRCOProduct.S
VRCOProduc1i.I
VRCOProduc2i.I
VRCOProduc3i.I

VRCOPiping.S
VRCOPipingi.I

VRCOHvac.S
VRCOHvaci.I

VRCORway.S
VRCORwayi.I

VRPInsert.S
VRPins.I

VRHInsert.S
VRHins.I

VRRInsert.S
VRRins.I

VROrient.S
VROrienti.I

VRPidPasCmd.S
VRPidPasCmdi.I

VRPlHanger.S
VRPlHangeri.I

VRPlNozzle.S
VRPlNozzlei.I

VRUpEvent.I
VRLnDynamic.I

VRCOPFunc1i.I
VRCOPFunc2i.I
VRCOPFunc3i.I

VRfunc.I
 
VRPReplace.S
VRPReplacei.I
VRHReplace.S
VRHReplacei.I
VRRReplace.S
VRRReplacei.I
VRNReplace.S
VRNReplacei.I

VRHvFrPl.S
VRHvFrPli.I
 
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
$ROUTE/vrinclude
$ROUTE/include
$EXNUC/include
$GRNUC/include
$EMS/include
$MODEL/include
$BS/include
$VDS/include
$VDS/vdinclude
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

