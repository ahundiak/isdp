/* $Id: vdict1test.m,v 1.1 2001/01/12 15:02:14 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/vdict1tree.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdict1test.m,v $
 *      Revision 1.1  2001/01/12 15:02:14  art
 *      sp merge
 *
# Revision 1.2  2000/09/14  20:39:14  pinnacle
# js
#
# Revision 1.1  2000/08/15  18:27:10  pinnacle
# ah
#
# Revision 1.3  2000/08/10  16:16:30  pinnacle
# js
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/12/00  ah      Creation
 * 01/12/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDct1Test.C
VDct1TestStd.C
VDct1CableTest.C
VDct1TestAttr.C
VDct1TestOft.C
VDct1LoadRhgr.C

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdict1test.o
#else
$VDS/lib/vdict1test.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
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

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
