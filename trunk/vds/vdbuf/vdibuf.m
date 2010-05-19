/* $Id: vdibuf.m,v 1.3 2001/01/18 16:58:55 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbuf/vdibuf.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdibuf.m,v $
 *      Revision 1.3  2001/01/18 16:58:55  art
 *      ah
 *
 *      Revision 1.2  2001/01/18 16:56:01  art
 *      ah
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/03/24  15:38:14  pinnacle
# ah
#
# Revision 1.1  2000/02/25  17:23:52  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/17/00  ah      Creation
 ***************************************************************************/

SOURCE
VDbuf.S
VDbufi.I
VDbufCS.S
VDbufCSi.I
VDbufMacro.S
VDbufMacroi.I
VDbufPoint.S
VDbufPointi.I

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdibuf.o
#else
$VDS/lib/vdibuf.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
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

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
