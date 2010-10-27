/* $Id: vdiatpost.m,v 1.3 2001/04/24 20:40:06 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/post/vdiatpost.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiatpost.m,v $
 *      Revision 1.3  2001/04/24 20:40:06  jdsauby
 *      Post table timestamp  CR 4474
 *
 *      Revision 1.2  2001/01/11 21:06:42  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/02/14  19:47:16  pinnacle
# tr179901064
#
# Revision 1.2  1998/11/07  14:05:16  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/03/29  14:21:14  pinnacle
# AssyTree
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/09/98  ah      Creation
 * 02/14/00  ah      Make SPX Compatibility
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDatPost.I
VDatMisc.I
VDatFile.I
VDatPdm.I
VDatKey.I
VDatTable.I
VDatImp.c  
VDatRis.c  
VDatXml.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiatpost.o
#else
$VDS/lib/vdiatpost.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
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

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
