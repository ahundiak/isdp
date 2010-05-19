/* $Id: vdipdf.m,v 1.1 2001/01/11 19:42:21 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdpdf/vdipdf.m
 *
 * Description: Production Data File (Spades) processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdipdf.m,v $
 *      Revision 1.1  2001/01/11 19:42:21  art
 *      sp merge
 *
# Revision 1.2  2000/08/05  17:16:32  pinnacle
# ah
#
# Revision 1.1  2000/08/05  16:51:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/05/00  ah      Creation
 * 01/11/01  ah      sp merge, needs updating, might me obsolete
 ***************************************************************************/

SOURCE
VDpdfValid.C
VDpdfDomTree.C
VDpdfDomDiff.C

#if 1

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdipdf.o
#else
vdipdf.o
#endif

#else

main.C

EXEC
sp_diff

LINKLIB
$SPXV/vdah/VDassert.o
$SPXV/vdxml/VDpdfAttrs.o
$SPXV/vddom/VDdom.o
-lcurses
-lsocket
-lnsl
-lUMS

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
