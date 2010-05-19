/* $Id: smmgr.m,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smmgr / smmgr.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smmgr.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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
# Revision 1.2  1995/07/30  18:29:22  pinnacle
# Replaced: smmgr/smmgr.m for:  by hverstee for vds.240
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

SMmgr.S
SMmgri.I

SMAttMgr.S
SMAttMgri.I

LIB
$VDS/lib/smimgr.o

SPEC
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
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

CC
acc -ansi
