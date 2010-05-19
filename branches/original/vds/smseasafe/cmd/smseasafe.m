/* $Id: smseasafe.m,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smseasafe/cmd / smseasafe.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smseasafe.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
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
# Revision 1.2  1995/07/30  18:39:42  pinnacle
# Replaced: smseasafe/cmd/smseasafe.m for:  by hverstee for vds.240
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

SMCmdMdStat.S
SMCmdMdStati.I
SMStatNotif.I

SMCmdSsfExt.S
SMCmdSsfExti.I

LIB
$VDS/lib/smcseascmd.o

SPEC
.
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$EMS/spec
$PDU/spec
$VDS/spec

INCLUDE
.
$BS/include 
$EXNUC/include 
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$EMS/include
$PDU/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi
