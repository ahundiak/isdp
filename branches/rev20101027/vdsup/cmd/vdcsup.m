/* $Id: vdcsup.m,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdsup/cmd/vdcsup.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdcsup.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/10/29  15:45:12  pinnacle
# Fix Lib Path
#
# Revision 1.2  1997/10/29  15:20:24  pinnacle
# Added Headers
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 ***************************************************************************/

SOURCE
VDCsupGen.S
VDCsupGeni.I

VDCsupGenPl.S
VDCsupGenPli.I
VDCsupGenPl1.I

INCLUDE
$BS/include
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/vdinclude

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec

LIB
$VDS/lib/vdcsup.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

