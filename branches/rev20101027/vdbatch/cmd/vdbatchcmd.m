/* $Id: vdbatchcmd.m,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdbatch/cmd/vdbatchcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdbatchcmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
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
# Revision 1.3  1995/09/26  14:03:54  pinnacle
# Replaced: vdbatch/cmd/vdbatchcmd.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/31  14:48:32  pinnacle
# Replaced: vdbatch/cmd/vdbatchcmd.m for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/25  21:02:24  pinnacle
# Created: vdbatch/cmd/vdbatchcmd.m by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/23/95	adz/raju	creation date
 *
 * -------------------------------------------------------------------*/

SOURCE
VDCmdBatDrw.S
VDCmdBatDrwi.I
VDCmdDVlist.I
VDCmdBatPrc.I
VDsolLoc2.I

LIB
$VDS/lib/vdcbatchcmd.o

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
$VDS/include
$VDS/vdinclude
$VDS/include/prototypes
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
