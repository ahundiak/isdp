/* $Id: vdivexml.m,v 1.2 2001/01/18 16:58:47 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vexml/vdivexml.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: vdivexml.m,v $
 * Revision 1.2  2001/01/18 16:58:47  art
 * ah
 *
 * Revision 1.1.1.1  2001/01/04 21:09:32  cvs
 * Initial import to CVS
 *
# Revision 1.1  2000/03/31  17:06:38  pinnacle
# ah
#
# Revision 1.2  2000/03/31  13:20:44  pinnacle
# ah
#
# Revision 1.1  2000/03/24  15:49:10  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/08/00  ah      Creation
 * 03/28/00  ah      Moved at stuff to vdat
 ***************************************************************************/

SOURCE
VEsmsTree.C
VEpdfSetup.C
VEpdfShip.C

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdivexml.o
#else
$VDS/lib/vdivexml.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
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




