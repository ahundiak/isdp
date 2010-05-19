/* $Id: vdiefp.m,v 1.6 2001/07/08 16:34:23 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdefp/vdiefp.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiefp.m,v $
 *      Revision 1.6  2001/07/08 16:34:23  ramarao
 *      Used old as well as new NeatPlate Algorithms.
 *
 *      Revision 1.5  2001/04/26 21:56:45  ramarao
 *      Fixed ETL# 7962.
 *
 *      Revision 1.4  2001/04/22 17:08:35  ramarao
 *      Applied Symbology to 'neat_cont' macro.
 *
 *      Revision 1.3  2001/03/16 16:49:01  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/11 19:04:50  art
 *      sp merge
 *
# Revision 1.3  2000/11/27  16:55:16  pinnacle
# ah
#
# Revision 1.2  2000/04/28  19:40:10  pinnacle
# ah
#
# Revision 1.1  2000/04/11  17:15:04  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/24/99  ah      creation
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDefpEdge.I
VDefpMacro.I
VDefpEdge2.I
#else
VDefpEdge.I
VDefpEdge2.I
VDefpNatEd.I
VDefpCrvLens.I
/* VDefpCrvTran.I*/
/* VDefpLike.I*/
VDefpCompare.I
VDefpDatMark.I
VDefpMacro.I
VDefpPlate.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiefp.o
#else
$VDS/lib/vdiefp.o
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

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp

