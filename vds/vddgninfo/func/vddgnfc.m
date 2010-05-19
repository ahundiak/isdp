/* $Id: vddgnfc.m,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddgninfo/func/vddgnfc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vddgnfc.m,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/07/08  16:13:26  pinnacle
# Created: vddgninfo/func/vddgnfc.m by yzhu for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      06/21/97	yzhu		Create
 * -------------------------------------------------------------------*/

SOURCE
VDgetDgnPar.I
VDgetAttDrSy.I
VDgetDiagPr.I
VDsetRepDiag.I

LIB
$VDS/lib/vdidgnfc.o

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
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude
$FORMS/include
$UMS/include

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
