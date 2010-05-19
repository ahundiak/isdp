/* $Id: vdiatimp.m,v 1.2 2001/01/11 21:18:27 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/imp/vdiatimp.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiatimp.m,v $
 *      Revision 1.2  2001/01/11 21:18:27  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.4  2000/02/14  19:47:16  pinnacle
# tr179901064
#
# Revision 1.3  1998/11/07  14:02:58  pinnacle
# ah
#
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/04/09  14:33:28  pinnacle
# ah
#
# Revision 1.6  1998/03/29  14:21:14  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      Creation
 * 10/10/98  ah      Deleted VDatFrmMgr.I, VDvlaFld.I
 * 02/14/00  ah      SPX Compatible
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDatBase.S
VDatBasei.I
VDatBase1.I
VDatBase2.I
VDatMgr.I
VDatFld.I
VDatGet.I
VDatGetStr.I

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiatimp.o
#else
$VDS/lib/vdiatimp.o
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
