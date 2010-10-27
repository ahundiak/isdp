/* $Id: vdattrib.m,v 1.1.1.1 2001/01/04 21:07:44 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdattrib/cmd / vdattrib.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdattrib.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:44  cvs
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
# Revision 1.3  1995/09/26  13:54:02  pinnacle
# Replaced: vdattrib/cmd/vdattrib.m for:  by sundar for vds.240
#
# Revision 1.2  1995/07/30  19:15:26  pinnacle
# Replaced: vdattrib/cmd/vdattrib.m for:  by hverstee for vds.240
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
VDCmdUsrAtt.S
VDCmdUsrAtti.I

LIB
$VDS/lib/vdcattribcmd.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/vdinclude/prototypes
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

