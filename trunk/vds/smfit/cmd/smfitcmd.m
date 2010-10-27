/* $Id: smfitcmd.m,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smfit/cmd / smfitcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smfitcmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
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
# Revision 1.4  1995/09/26  19:48:30  pinnacle
# Replaced: smfit/cmd/smfitcmd.m for:  by sundar for vds.240
#
# Revision 1.3  1995/07/30  18:15:16  pinnacle
# Replaced: smfit/cmd/smfitcmd.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/24  15:49:50  pinnacle
# Replaced: smfit/cmd/smfitcmd.m for:  by hverstee for vds.240
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
SMCmdFit.S
SMCmdFiti.I

LIB
$VDS/lib/smcfitcmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$BS/include
$UMS/include
$FORMS/include
$VDS/include
$VDS/vdinclude
$GRNUC/ingrsys

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
