/* $Id: smframecmd.m,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/cmd / smframecmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smframecmd.m,v $
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
# Revision 1.4  1996/04/30  23:30:04  pinnacle
# Replaced: smframe/cmd/smframecmd.m for:  by azuurhou for vds.240
#
# Revision 1.3  1996/02/24  21:52:24  pinnacle
# Replaced: smframe/cmd/smframecmd.m for:  by v240_int for vds.240
#
# Revision 1.2  1995/07/30  18:16:50  pinnacle
# Replaced: smframe/cmd/smframecmd.m for:  by hverstee for vds.240
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
 *	02/24/96	adz		Move files to func directory.
 *
 * -------------------------------------------------------------------*/

SOURCE

SMCmdPlMdFr.S
SMCmdPlMdFri.I

SMCmdDelFr.S
SMCmdDelFri.I
 
SMCmdModSct.S
SMCmdModScti.I 

SMModNotif.I 



LIB
$VDS/lib/smcframecmd.o

SPEC
$EXNUC/spec 
$GRNUC/spec
$MODEL/spec
$PDU/spec
$VDS/spec

INCLUDE
.
$BS/include
$UMS/include
$FORMS/include
$EXNUC/include 
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$PDU/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

CC
acc -ansi
