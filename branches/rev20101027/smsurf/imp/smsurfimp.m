/* $Id: smsurfimp.m,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/imp / smsurfimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smsurfimp.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/02/06  20:56:08  pinnacle
# Replaced: smsurf/imp/smsurfimp.m for:  by jwfrosch for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1995/08/01  15:21:16  pinnacle
# Replaced: smsurf/imp/smsurfimp.m for:  by hverstee for vds.240
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

SMbulkhead.S
SMbulkheadi.I
SMbulkhdMac.I


SMsurf_fn.I


SMCcCamber.S
SMCcCamberi.I
SMCcCambMac.I


SMSlCamber.S
SMSlCamberi.I
SMSlCambMac.I


SMTransBk.S
SMTransBki.I
SMTransBkMac.I

SMSlSheer.S
SMSlSheeri.I
SMSlSheerMac.I

SMTrCrgtBk.S
SMTrCrgtBki.I
SMTrCrBkMac.I


SMPtCamber.S
SMPtCamberi.I
SMPtCambMac.I


SMPtSheer.S
SMPtSheeri.I
SMPtSheerMac.I


SMLongBk.S
SMLongBki.I
SMLongBkMac.I


SMLgCrgtBk.S
SMLgCrgtBki.I
SMLgCrBkMac.I


LIB
$VDS/lib/smisurfimp.o

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
