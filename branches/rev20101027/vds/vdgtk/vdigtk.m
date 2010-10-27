/* $Id: vdigtk.m,v 1.1 2001/05/24 19:32:51 ahundiak Exp $  */

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
 *      $Log: vdigtk.m,v $
 *      Revision 1.1  2001/05/24 19:32:51  ahundiak
 *      ah
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
VDgtkTree.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdigtk.o
#else
$VDS/lib/vdigtk.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$LOCAL/include/gtk-1.2
$LOCAL/include/glib-1.2 
$LOCAL/include
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
