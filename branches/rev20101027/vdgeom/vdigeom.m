/* $Id: vdigeom.m,v 1.4 2001/10/04 16:07:55 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdgeom/vdigeom.m
 *
 * Description: Geometry Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdigeom.m,v $
 *      Revision 1.4  2001/10/04 16:07:55  ramarao
 *      Fixed TR# 5525 and TR# 5564.
 *
 *      Revision 1.3  2001/05/03 14:45:36  ramarao
 *      Corrected "Problem getting arc length" error.
 *
 *      Revision 1.2  2001/01/11 18:41:19  art
 *      sp merge
 *
# Revision 1.4  2000/11/27  17:07:18  pinnacle
# ah
#
# Revision 1.3  2000/04/28  19:32:24  pinnacle
# ah
#
# Revision 1.2  2000/04/25  16:15:56  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:14:28  pinnacle
# ah
#
# Revision 1.2  2000/03/27  21:29:22  pinnacle
# ah
#
# Revision 1.1  2000/03/24  17:16:32  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/22/00  ah      Creation
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDgeomLen.I
VDgeomNatEd.I
#else
VDgeomOld.I
VDgeomMat.I
VDgeomGet.I
VDgeomPar.I
VDgeomProd.I
VDgeomCurve.I
VDgeomPrint.I
VDgeomNatEd.I
VDgeomKnot.I
VDgeomTran.I
VDgeomLen.I
VDgeomSym.I
VDgeomSrf.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdigeom.o
#else
$VDS/lib/vdigeom.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$BS/include
$BS/include/prototypes
$UMS/include
$FORMS/include
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$GRNUC/src/assoc/include_priv
$MODEL/include
$VDS/include
$VDS/include/prototypes
$VDS/vdinclude

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

