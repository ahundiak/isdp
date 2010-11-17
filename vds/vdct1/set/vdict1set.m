/* $Id: vdict1set.m,v 1.3 2001/01/12 14:53:35 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/set/vdict1set.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdict1set.m,v $
 *      Revision 1.3  2001/01/12 14:53:35  art
 *      sp merge
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      creation
 * 03/13/00  ah      Added VDct1CSMat.I
 * 07/17/00  ah      Added VDct1Xml.I
 * 07/25/00  ah      I to C
 * 01/12/01  ah      sp merge, this directory should go away
 ***************************************************************************/

SOURCE
VDct1Mgr.C
VDct1Set.C
VDct1Buf.C
VDct1Xml.C
VDct1Assy.C
VDct1Node.C
VDct1Attr.C
VDct1Base.I
VDct1Defn.I
VDct1Model.I
VDct1CSMat.I
VDct1SirGrp.C

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdict1set.o
#else
$VDS/lib/vdict1set.o
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
