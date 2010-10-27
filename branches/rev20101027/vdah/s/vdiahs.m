/* $Id: vdiahs.m,v 1.7 2001/11/09 14:19:02 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdahs/vdiahs.m
 *
 * Description: Standalone utilities and stubs
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiahs.m,v $
 *      Revision 1.7  2001/11/09 14:19:02  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/06/14 18:46:51  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/02/09 22:25:32  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/01 15:34:48  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
# Revision 1.3  2000/12/07  17:36:58  pinnacle
# ah
#
# Revision 1.2  2000/12/07  13:36:08  pinnacle
# ah
#
# Revision 1.1  2000/12/06  14:54:16  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/05/00  ah      Creation
 * 01/25/01  ah      Removed VDos.c, som based function in vdah/c
 ***************************************************************************/

SOURCE
VDom.c
VDui.c
VDobj2.c
VDfrm2.c
VDct1.c
VDbuf.c
VDgbl.c

LIB
vdiahs.o

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
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

