/* $Id: vdictset.m,v 1.1.1.1 2001/01/04 21:08:01 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/set/vdictset.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdictset.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:01  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/05/30  14:27:54  pinnacle
# ct
#
# Revision 1.1  1999/05/28  19:08:46  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      creation
 ***************************************************************************/

SOURCE
VDctMgr.I
VDctSet.I
VDctBase.I

LIB
$VDS/lib/vdictset.o

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
