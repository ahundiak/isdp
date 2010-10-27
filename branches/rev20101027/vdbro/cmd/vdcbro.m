/* $Id: vdcbro.m,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbro/cmd/vdcbro.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdcbro.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/29  20:30:26  pinnacle
# Fix Include Path
#
# Revision 1.1  1997/10/29  17:23:26  pinnacle
# ah creation
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTION
 *      10/29/97  ah      added header
 ***************************************************************************/

SOURCE
VDCbro.S
VDCbroi.I
VDCbroChn.I

INCLUDE
.
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
$VDS/lib/vdcbro.o

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

