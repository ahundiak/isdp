/* $Id: vdigeom2.m,v 1.6 2001/07/23 16:26:48 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdigeom2/vdigeom2.m
 *
 * Description: Dot c geometry routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdigeom2.m,v $
 *      Revision 1.6  2001/07/23 16:26:48  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/06/22 15:14:52  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/06/07 19:31:09  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/06/07 19:05:24  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/05/17 14:55:28  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/04/12 14:38:23  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/12/01  ah      creation
 ***************************************************************************/

SOURCE
VDgeom2Mat.c
VDgeom2Tran.c
VDgeom2Prod.c
VDgeom2Like.c
VDgeom2Curve.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdigeom2.o
#else
$VDS/lib/vdigeom2.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$LOCAL/include/glib-1.2
$LOCAL/include
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

