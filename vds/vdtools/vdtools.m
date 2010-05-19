/* $Id: vdtools.m,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $*/

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdtools/vdtools.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdtools.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/24  20:58:56  pinnacle
# Replaced: vdtools/vdtools.m for:  by kddinov for vds
#
# Revision 1.1  1997/11/18  16:58:06  pinnacle
# Created: vdtools/vdtools.m by kddinov for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
*	10-97	KDD	creation
 *
 * -------------------------------------------------------------------*/

LIB
$VDS/lib/vditools.o

SOURCE

VDSError.I
VDModColl.I
VDFormUtil.I
VDGetAttr.I
VDSetRow.I
VDStorage.I


SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

INCLUDE
$BS/include
$EXNUC/include
$GRNUC/include
$MODEL/include
$PDU/include
$NFMDP/include
$VDS/include
$VDS/vdinclude
$VDS/vdpinclude
$GRNUC/src/assoc/include_priv

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

