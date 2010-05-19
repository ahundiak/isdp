/* $Id: smsurfcmd.m,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/cmd / smsurfcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smsurfcmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/02/06  21:09:38  pinnacle
# Replaced: smsurf/cmd/smsurfcmd.m for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/07/30  18:52:12  pinnacle
# Replaced: smsurf/cmd/smsurfcmd.m for:  by hverstee for vds.240
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

SMCmdSurf.S 
SMCmdSurfi.I

SMCmdBulkHd.S
SMCmdBulkHdi.I
SMBulkHdNtf.I

SMCmdCcCmbr.S
SMCmdCcCmbri.I
SMCcCmbrNtf.I

SMCmdSlCmbr.S
SMCmdSlCmbri.I
SMSlCmbrNtf.I


SMCmdTrBk.S
SMCmdTrBki.I
SMTrBkNtf.I


SMCmdSlShr.S
SMCmdSlShri.I
SMSlShrNtf.I


SMCmdTrCrBk.S
SMCmdTrCrBki.I
SMTrCrBkNtf.I

SMCmdPtCmbr.S
SMCmdPtCmbri.I
SMPtCmbrNtf.I


SMCmdPtShr.S
SMCmdPtShri.I
SMPtShrNtf.I


SMCmdLgBk.S
SMCmdLgBki.I
SMLgBkNtf.I


SMCmdLgCrBk.S
SMCmdLgCrBki.I
SMLgCrBkNtf.I

LIB
$VDS/lib/smcsurfcmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$NFMDP/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
