/* $Id: vdict1tree.m,v 1.5 2002/01/07 18:53:42 jdsauby Exp $  */

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
 *      $Log: vdict1tree.m,v $
 *      Revision 1.5  2002/01/07 18:53:42  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.4  2001/05/25 14:56:53  jdsauby
 *      ETL 2235, Add HVAC tree to OTM
 *
 *      Revision 1.3  2001/03/11 18:37:01  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/14 16:29:17  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/12 15:14:11  art
 *      sp merge
 *
# Revision 1.10  2000/12/08  15:49:54  pinnacle
# ah
#
# Revision 1.9  2000/09/07  18:02:38  pinnacle
# js
#
# Revision 1.8  2000/08/25  19:59:20  pinnacle
# ah
#
# Revision 1.7  2000/08/10  13:23:02  pinnacle
# js
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/12/00  ah      Creation
 * 01/12/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDct1Test.c
VDct1Tree.c
VDct1Init.c
VDct1Misc.c
VDct1RootTree.c
VDct1RootTree2.c
VDct1EngAttrs.c
VDct1RootTreeC.c
VDct1RootTreeX.c
VDct1RootTreeP.c
VDct1RootTreeM.c
VDct1PlotTree.c
VDct1ProdTree.c
VDct1StdParts.c
VDct1StdAssys.c
VDct1PalAssys.c
VDct1EngTree.c
VDct1OftTree.c
VDct1CableTree.c
VDct1WWayTree.c
VDct1HvacTree.c
VDct1Model.I
VDct1DeltaTree.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdict1tree.o
#else
$VDS/lib/vdict1tree.o
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
