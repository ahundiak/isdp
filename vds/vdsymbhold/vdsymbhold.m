/* $Id: vdsymbhold.m,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdsymbhold / vdsymbhold.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdsymbhold.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:25  cvs
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
# Revision 1.2  1995/07/30  20:45:38  pinnacle
# Replaced: vdsymbhold/vdsymbhold.m for:  by hverstee for vds.240
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
VDsymb_hold.S
VDsymb_holdi.I

LIB
$VDS/lib/vdisymbhold.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$GRNUC/src/include_priv/include
$MODEL/include
$VDS/include
$VDS/vdinclude
/usr/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp