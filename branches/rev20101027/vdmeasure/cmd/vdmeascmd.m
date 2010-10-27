/* $Id: vdmeascmd.m,v 1.1.1.1 2001/01/04 21:08:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdmeasure/cmd/vdmeascmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdmeascmd.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/11/08  21:49:24  pinnacle
# Created: vdmeasure/cmd/vdmeascmd.m by v241_int for vds.241
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 ***************************************************************************/

SOURCE
VDCmdMeas.S
VDCmdMeasi.I
VDmeasOver.I

INCLUDE
$FORMS/include
$UMS/include
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude
$VDS/include/prototypes
$VDS/vdinclude/prototypes
$PDU/include

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

LIB
$VDS/lib/vdcmeascmd.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
