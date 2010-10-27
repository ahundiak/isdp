/* $Id: vdiatcmd.m,v 1.2 2001/01/11 21:21:51 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/vdiatcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiatcmd.m,v $
 *      Revision 1.2  2001/01/11 21:21:51  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.4  2000/02/14  19:47:16  pinnacle
# tr179901064
#
# Revision 1.3  1999/04/09  14:28:04  pinnacle
# VDatSearch.I
#
# Revision 1.2  1998/09/25  15:44:20  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/03/29  14:21:14  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/01/97  ah      Creation
 * 04/09/99  ah      Added VDatSearch.I
 * 02/14/00  ah      SPX Compatible
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDatPcmk.I
VDatLeaf.I
VDatTree.I
VDatAttr.I
VDatSet.I
VDatMgr.I
VDatStage.I
VDatAll.I

VDatForms.I
VDatTreeF.I
VDatSetF.I
VDatSearch.I

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiatcmd.o
#else
$VDS/lib/vdiatcmd.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPX/include
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
