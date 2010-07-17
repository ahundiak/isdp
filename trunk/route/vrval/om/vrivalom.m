/* $Id: vrivalom.m,v 1.2 2001/11/08 20:29:23 anand Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vrval/om/vrivalom.m
 *
 * Description: XML Validation routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vrivalom.m,v $
 *      Revision 1.2  2001/11/08 20:29:23  anand
 *      JTS CR MP 5542
 *
 *      Revision 1.1  2001/08/24 20:10:11  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/03/01  ah      Creation
 ***************************************************************************/

SOURCE
VRvalGenNoz.I
VRvalGenCpt.I
VRvalGenComp.I
VRPartFlow.I

LIB
#if ISDP_MAKE_SP
$SPXR/lib/vrivalom.o
#else
$ROUTE/lib/vrivalom.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXR/include
$SPXR/vrinclude
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
$ROUTE/include
$ROUTE/vrinclude
$ROUTE/vrinclude/prototypes

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$ROUTE/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
