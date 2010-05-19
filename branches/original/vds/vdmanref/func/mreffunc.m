/* $Id: mreffunc.m,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $ */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdmanref/func/mreffunc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: mreffunc.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/01/26  16:22:56  pinnacle
# Replaced: vdmanref/func/mreffunc.m for:  by mdong for vds
#
# Revision 1.1  1997/12/30  16:17:50  pinnacle
# Created: vdmanref/func/mreffunc.m by mdong for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      12/17/97      Adz & Ming        Creation
 *
 * -------------------------------------------------------------------*/

SOURCE
MREF_tools.C

LIB
$VDS/lib/vdireffunc.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$VDS/include
$VDS/vdinclude
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$UMS/include
$MODEL/include
$GRNUC/src/assoc/include_priv
$FORMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
