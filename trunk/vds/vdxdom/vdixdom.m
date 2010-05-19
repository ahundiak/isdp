/* $Id: vdixdom.m,v 1.3 2001/11/16 14:27:51 ahundiak Exp $  */

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
 *      $Log: vdixdom.m,v $
 *      Revision 1.3  2001/11/16 14:27:51  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/09/20 14:36:27  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/24 20:08:07  ahundiak
 *      ah
 *
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
xdom_xml.c
xdom_sax.c
xdom_isdp.c
xdom_xslt.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdixdom.o
#else
$VDS/lib/vdixdom.o
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

