/* $Id: vdivalom.m,v 1.6 2001/11/09 15:04:29 ahundiak Exp $  */

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
 *      $Log: vdivalom.m,v $
 *      Revision 1.6  2001/11/09 15:04:29  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/08/24 20:01:52  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/08/14 19:15:45  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/08/02 15:33:39  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/07/28 17:34:17  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/07/23 16:32:23  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/20/01  ah      Creation
 ***************************************************************************/

SOURCE
VDvalAtr.I
VDvalParent.I
VDvalComputePiece.c
VDvalCompEqp.I
VDvalCompCpt.c
VDvalCompNoz.I
VDvalCompComp.I
VDvalGenEqp.I
VDvalGenComp.I
VDvalGenPiece.c
VDvalCmdStdPcmks.c
VDgeomoSurf.I
VDvalCompStdPc.c
VDvalPiece.c
VDvalStdPc.c
VDvalCustomAttr.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdivalom.o
#else
$VDS/lib/vdivalom.o
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
$MODEL/spec
$VDS/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
