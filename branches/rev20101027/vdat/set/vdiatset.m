/* $Id: vdiatset.m,v 1.2 2001/01/11 21:12:34 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/rdb/vdiatset.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiatset.m,v $
 *      Revision 1.2  2001/01/11 21:12:34  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.10  2000/03/31  17:09:12  pinnacle
# ah
#
# Revision 1.9  2000/02/14  19:47:16  pinnacle
# tr179901064
#
# Revision 1.8  1999/11/16  17:50:58  pinnacle
# (No comment)
#
# Revision 1.7  1999/10/29  20:30:26  pinnacle
# ylong
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/28/97  ah      creation
 * 01/12/99  vinit   Added VDatAttr.I
 * 04/27/99  ah      Added VDatStub.I
 * 10/29/99  ylong   Added VDatGetLgstPln.I
 * 11/16/99  ylong   replaced VDatGetLgstPln.I with a shorter name VDatGetLP.I
 * 02/14/00  ah      SPX Compatible
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDatSum.I
VDatSet.I
VDatLeaf.I
VDatTree.I
VDatNode.I
VDatMisc.I
VDatType.I
VDatTest.I
VDatBase.I
VDatAttr.I
VDatStub.I
VDatGetLP.I

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiatset.o
#else
$VDS/lib/vdiatset.o
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
