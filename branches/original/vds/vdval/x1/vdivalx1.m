/* $Id: vdivalx1.m,v 1.4 2002/01/03 14:36:25 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/vdival.m
 *
 * Description: Generic validation routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdivalx1.m,v $
 *      Revision 1.4  2002/01/03 14:36:25  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/11/09 14:59:56  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/10/23 16:33:45  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/05/24 18:50:21  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/21/01  ah      Creation
 ***************************************************************************/

SOURCE
VDvalFamily.c
VDvalStaging.c
VDvalStdPcmk.c
VDvalMaterial.c
VDvalTolerance.c
VDsynonAttr.I
VDvalEqp.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdivalx1.o
#else
$VDS/lib/vdivalx1.o
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
