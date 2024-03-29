/* $Id: vdvisucmd.m,v 1.1.1.1 2001/01/04 21:09:32 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdvisual/cmd / vdvisucmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdvisucmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/05/21  13:33:00  pinnacle
# Replaced: vdvisual/cmd/vdvisucmd.m for:  by v240_int for vds.240
#
# Revision 1.4  1996/05/09  16:03:34  pinnacle
# Replaced: vdvisual/cmd/vdvisucmd.m for:  by v240_int for vds.240
#
# Revision 1.3  1995/07/30  21:00:24  pinnacle
# Replaced: vdvisual/cmd/vdvisucmd.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/24  18:44:24  pinnacle
# Replaced: vdvisual/cmd/vdvisucmd.m for:  by hverstee for vds.240
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

VDCmdGridOn.S
VDCmdGridOni.I

VDCmdGridOf.S
VDCmdGridOfi.I

VDCmdDirFrm.S
VDCmdDirFrmi.I
VDCmdDirUpd.I
VDCmdVdsUpd.I

VDCmdGridCrt.I
VDCmdGridSel.I

GRdpbi.I

LIB
$VDS/lib/vdcvisucmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
