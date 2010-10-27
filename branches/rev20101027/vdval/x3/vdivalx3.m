/* $Id: vdivalx3.m,v 1.2 2001/10/16 15:10:41 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x3/vdival.m
 *
 * Description: Piece oriented validation routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdivalx3.m,v $
 *      Revision 1.2  2001/10/16 15:10:41  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/07/23 16:32:40  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/20/01  ah      Creation
 ***************************************************************************/

SOURCE
VDvalPiece.c
VDvalGeom.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdivalx3.o
#else
$VDS/lib/vdivalx3.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$LOCAL/include/glib-1.2
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
