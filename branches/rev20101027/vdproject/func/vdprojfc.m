/* $Id: vdprojfc.m,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdproject/func / vdprojfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdprojfc.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
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
# Revision 1.3  1995/07/30  20:29:14  pinnacle
# Replaced: vdproject/func/vdprojfc.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/24  20:59:00  pinnacle
# Replaced: vdproject/func/vdprojfc.m for:  by hverstee for vds.240
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

VDProjNb.I
VDProjFn.I
VDCmdProjDb.C

LIB
$VDS/lib/vdiprojfc.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$PDU/spec
$VDS/spec

INCLUDE
$BS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$PDU/include
$NFMDP/include
$MODEL/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
