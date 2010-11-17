/* $Id: vdistepcmd.m,v 1.1.2.1 2004/11/29 16:27:16 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/vdirrvcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdistepcmd.m,v $
 *      Revision 1.1.2.1  2004/11/29 16:27:16  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/29/04  ah      Creation
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDstep227.c
#else
VDstep227.c
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdistepcmd.o
#else
$VDS/lib/vdistepcmd.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
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
/export/home/forms/xforms/source/xfi/include
/export/home/forms/xforms/source/xfi/fs_include
.

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
