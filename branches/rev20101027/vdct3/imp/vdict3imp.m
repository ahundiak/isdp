/* $Id: vdict3imp.m,v 1.1.1.1 2001/01/04 21:08:03 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct3/imp/vdict3imp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdict3imp.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:03  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/06/29  18:27:04  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      creation
 ***************************************************************************/

SOURCE
VDct3Base.S
VDct3Basei.I
VDct3Basej.I

VDct3Defn.S
VDct3Defni.I

LIB
$VDS/lib/vdict3imp.o

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/src/assoc/include_priv
$FORMS/include
$PDU/include
$NFMDP/include
$MODEL/include
$UMS/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
