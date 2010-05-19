/* $Id: vdrelhdr.m,v 1.1.1.1 2001/01/04 21:09:06 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrelhdr / vdrelhdr.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdrelhdr.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:06  cvs
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
# Revision 1.2  1995/07/30  20:30:42  pinnacle
# Replaced: vdrelhdr/vdrelhdr.m for:  by hverstee for vds.240
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
VDlink.S
VDlinki.I

VDrelat_hdr.S
VDrelat_hdri.I
VDhdr_loc.I
VDhdr_db.I
VDhdr_fun.I

VDrflconst.S
VDrflconsti.I

CC
acc -ansi

LIB
$VDS/lib/vdirelhdr.o

SPEC
$EXNUC/spec
$GRNUC/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$MODEL/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
