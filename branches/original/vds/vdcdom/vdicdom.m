/* $Id: vdicdom.m,v 1.2 2001/05/17 14:45:38 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcdom/vdicdom.m
 *
 * Description: Cdom routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdicdom.m,v $
 *      Revision 1.2  2001/05/17 14:45:38  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/02 15:07:25  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/23/01  ah      creation
 ***************************************************************************/

SOURCE
cdom_attr.c
cdom_node.c
cdom_xml.c
cdom_isdp.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdicdom.o
#else
$VDS/lib/vdicdom.o
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

