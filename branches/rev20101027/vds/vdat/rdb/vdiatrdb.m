/* $Id: vdiatrdb.m,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/rdb/vdiatrdb.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiatrdb.m,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/04/02  23:28:18  pinnacle
# ah
#
# Revision 1.6  1998/03/29  14:21:14  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      Creation
 *
 ***************************************************************************/

SOURCE
VDatMac.I
VDatCache.I
VDatPost.I
VDatAttr.I
VDatNode.I
VDatSet.I

LIB
$VDS/lib/vdiatrdb.o

SPEC
.
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
.
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
