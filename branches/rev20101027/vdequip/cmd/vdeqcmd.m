/* $Id: vdeqcmd.m,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/cmd / vdeqcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdeqcmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/09  20:36:52  pinnacle
# Replaced: vdequip/cmd/vdeqcmd.m for:  by v241_int for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/26  15:44:20  pinnacle
# Replaced: vdequip/cmd/vdeqcmd.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/30  19:48:42  pinnacle
# Replaced: vdequip/cmd/vdeqcmd.m for:  by hverstee for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

SOURCE

VDCmdPart.S
VDCmdParti.I

VDCmdAttMgr.S
VDCmdAttMgri.I

VDm_place.S
VDm_place1_.I
VDm_place2_.I

VDm_modify.S
VDm_modifyi.I

VDPpreLdNot.I
VDChkPath.I

LIB
$VDS/lib/vdceqcmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$ROUTE/spec

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$NFMDP/include
$VDS/include
$VDS/vdinclude
$VDS/vdpinclude
$GRNUC/src/assoc/include_priv
$ROUTE/include
$ROUTE/vrinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

OPPFLAGS
-l


