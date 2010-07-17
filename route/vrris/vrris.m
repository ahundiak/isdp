/* $Id: vrris.m,v 1.1.1.1 2001/01/04 21:13:06 cvs Exp $ */

/***********************************************************************
 * I/ROUTE
 *
 * File:	vrris /vrris.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vrris.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.1  1996/04/24  20:30:22  pinnacle
# Created: vrris/vrris.m by hverstee for route240
#
 *
 * History:
 *
 ***********************************************************************/

LIB
$ROUTE/lib/vrris.o

SOURCE

VRRISexec.c

SPEC
$EXNUC/spec
$GRNUC/spec

INCLUDE
$EXNUC/include
$GRNUC/include
$PDU/include
$VDS/include
$ROUTE/include
$ROUTE/vrinclude
$RIS/include
$RIS/risdp/include
$BS/include
$BS/include/prototypes
$ROUTE/vrinclude/prototypes

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
