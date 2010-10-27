/* $Id: vdrepimp.m,v 1.1.1.1 2001/01/04 21:09:07 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrep/imp / vdrepimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdrepimp.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:07  cvs
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
# Revision 1.2  1995/07/30  20:33:16  pinnacle
# Replaced: vdrep/imp/vdrepimp.m for:  by hverstee for vds.240
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
VDMcGetSymb.I


LIB
$VDS/lib/vdirepimp.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$GRNUC/proto_priv
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
