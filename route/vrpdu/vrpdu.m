/* $Id: vrpdu.m,v 1.5 2002/05/18 23:27:27 anand Exp $ */

/***********************************************************************
 * I/ROUTE
 *
 * File:	vrpdu /vrpdu.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrpdu.m,v $
 *	Revision 1.5  2002/05/18 23:27:27  anand
 *	Removed all the #if ISDP_MAKE_SP stuff (relating to source
 *	files only) - kind of preparing for the Service Pack cycle!
 *	
 *	Revision 1.4  2001/10/15 00:25:23  anand
 *	Rollback of fix JTS TR MP 5586 (will need to redeliver fix
 *	for Pload).
 *	
 *	Revision 1.2  2001/09/04 22:33:16  anand
 *	JTS TR MP 5548
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:02  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/01/24  16:50:48  pinnacle
# Replaced: vrpdu/vrpdu.m for:  by kddinov for route
#
# Revision 1.2  1997/08/15  19:34:34  pinnacle
# Replaced: vrpdu for:  by hverstee for route
#
# Revision 1.2  1997/02/28  22:59:58  pinnacle
# Replaced: vrpdu/vrpdu.m for:  by yzhu for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.7  1996/04/25  15:12:54  pinnacle
# Replaced: vrpdu/vrpdu.m for:  by r240_int for route240
#
# Revision 1.6  1996/04/22  15:09:06  pinnacle
# Replaced: vrpdu/vrpdu.m for:  by hverstee for route240
#
# Revision 1.5  1996/03/06  18:04:06  pinnacle
# Replaced: vrpdu/vrpdu.m for:  by azuurhou for route240
#
# Revision 1.4  1996/01/17  17:32:24  pinnacle
# Replaced: vrpdu/vrpdu.m for:  by r240_int for route240
#
# Revision 1.3  1995/11/04  00:17:02  pinnacle
# Replaced: vrpdu/*.m for:  by tlbriggs for route240
#
# Revision 1.2  1995/11/04  00:05:48  pinnacle
# Replaced: vrpdu/*.m for:  by tlbriggs for route240
#
 *
 * History:
 *	11/3/95		tlb		EMS 3.2 - replace rispcuc by risdp
 *	01/17/96   	tlb		Add BS, ROUTE prototypes
 *	03/06/96	adz		Removed RISexec.rc from vrpdu.
 *	02/14/97	yzhu		Add VRNozfldlst.I.
 *
 ***********************************************************************/

LIB
$ROUTE_PATH/lib/vrpdu.o

SOURCE


VRPDB.S
VRPDBi.I
VRPDBload.I

VRHDB.S
VRHDBi.I
VRHDBload.I

VRRDB.S
VRRDBi.I
VRRDBload.I

VRXgpipe.I
VRXaccpip.I
VRXunits.I
VRXoptcode.I
VRXnpdlst.I
VRXcodenum.I

VRXhvacdb.I
VRXdbpid.I
VRXEquip.I
VRXcache.I
VRXacchvac.I
VRXaccrway.I
VRXaccdb.I
VRXgethvac.I
VRXgetrway.I
VRXsoffset.I

VRdbpb.I
VRdberrmsg.I
VRreperr.I
VRfunc.I
VRnozdb.I
VRhvdbpb.I
VRrwdbpb.I
VRNozfldlst.I

VRhvacdb.c
VRdbpid.c
VREquipLst.c
VRdbCache.c
VRacchvac.c
VRaccrway.c
VRaccess_db.c
VRgethvac.c
VRgetrway.c
VRsoffset.c

VRgnpdlst.c
VRaccpip.c
VRgetpipe.c
VRPDUunits.c
VRgoptcode.c
VRgcodenum.c


SPEC
$ROUTE/spec
$VDS/spec
$EXNUC/spec
$GRNUC/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include/prototypes
$SPXV/vdinclude/prototypes
$SPXV/include
$SPXV/vdinclude
$SPXR/include
$SPXR/vrinclude
$SPXR/vcinclude
#endif
$EXNUC/include
$GRNUC/include
$VDS/include
$VDS/vdinclude
$ROUTE/include
$ROUTE/vrinclude
$ROUTE/vcinclude
$RIS/include
$RIS/risdp/include
$PDM/include
$BS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes
$VDS/include/prototypes
$VDS/vdinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
