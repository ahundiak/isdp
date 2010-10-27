/* $Id: vdivalx2.m,v 1.3 2001/07/23 16:28:36 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x2/vdival.m
 *
 * Description: Specific validation routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdivalx2.m,v $
 *      Revision 1.3  2001/07/23 16:28:36  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/22 15:19:33  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/03 15:02:59  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/24 18:50:21  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/29/01  ah      Creation
 ***************************************************************************/

SOURCE
VDvalStaging.c
VDvalPcmk.c
VDvalSpades.c
VDvalParse.c
VDvalError.c
VDvalBsp.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdivalx2.o
#else
$VDS/lib/vdivalx2.o
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
