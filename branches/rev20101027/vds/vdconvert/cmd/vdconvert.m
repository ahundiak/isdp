/* $Id: vdconvert.m,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdconvert/cmd / vdconvert.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdconvert.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
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
# Revision 1.5  1995/09/26  14:44:26  pinnacle
# Replaced: vdconvert/cmd/vdconvert.m for:  by sundar for vds.240
#
# Revision 1.4  1995/07/31  17:24:10  pinnacle
# Replaced: vdconvert/cmd for:  by hverstee for vds.240
#
# Revision 1.3  1995/07/30  19:24:24  pinnacle
# Replaced: vdconvert/cmd/vdconvert.m for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/24  16:43:16  pinnacle
# Replaced: vdconvert/cmd/vdconvert.m for:  by hverstee for vds.240
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
SMCmdCvtCmp.S
SMCmdCvtCmpi.I
SMCmdCvtFrm.S
SMCmdCvtFrmi.I
VDCmdupdbox.S
VDCmdupdboxi.I
VDrtupdcls.S
VDrtupdclsi.I

LIB
$VDS/lib/vdicvrtcmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$VDS/include
$VDS/vdinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
