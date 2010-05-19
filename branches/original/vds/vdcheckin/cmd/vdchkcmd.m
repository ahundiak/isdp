/* $Id: vdchkcmd.m,v 1.2 2001/01/26 14:27:39 build Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcheckin/cmd / vdchkcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdchkcmd.m,v $
 *	Revision 1.2  2001/01/26 14:27:39  build
 *	*** empty log message ***
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1997/02/05  11:24:24  pinnacle
# Replaced: vdcheckin/cmd/vdchkcmd.m for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/09/26  14:30:58  pinnacle
# Replaced: vdcheckin/cmd/vdchkcmd.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/30  19:18:34  pinnacle
# Replaced: vdcheckin/cmd/vdchkcmd.m for:  by hverstee for vds.240
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
 *      11/06/96        Ravi		 Added entry for VDbatchPost.I
 *
 * -------------------------------------------------------------------*/

SOURCE
VDCmdChkIn.S
VDCmdChkIni.I
VDbatchPost.I

LIB
$VDS/lib/vdcchkcmd.o

SPEC
.
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
.
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$PDUDP/include
$NFM/include
$NFMDP/include
$RIS/rispcuc/include
$VDS/include
$VDS/vdinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp


CC
acc -ansi


