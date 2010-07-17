/* $Id: vlisms.m,v 1.12 2002/04/15 13:39:54 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        vlsms/vlisms.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: vlisms.m,v $
 * Revision 1.12  2002/04/15 13:39:54  ahundiak
 * ah
 *
 * Revision 1.11  2002/04/12 22:19:15  ylong
 * Modified for proceeding pload
 *
 * Revision 1.10  2002/04/09 20:54:13  ahundiak
 * ah
 *
 * Revision 1.9  2001/09/14 13:42:56  ahundiak
 * ah
 *
 * Revision 1.8  2001/06/27 15:34:43  ahundiak
 * ah
 *
 * Revision 1.7  2001/06/14 18:29:21  ahundiak
 * ah
 *
 * Revision 1.6  2001/06/06 15:54:15  ahundiak
 * ah
 *
 * Revision 1.5  2001/05/11 13:07:15  ahundiak
 * ah
 *
 * Revision 1.4  2001/02/20 15:57:16  ahundiak
 * ah
 *
 * Revision 1.3  2001/01/22 16:16:38  ahundiak
 * ah
 *
 * Revision 1.2  2001/01/18 17:55:32  art
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 01/26/00  ah      Creation
 * 03/31/00  jvh     Added VLsmsBeam.I
 * 05/12/00  ah      Added VLsmsDxf3.C
 * 01/18/01  ah      sp merge
 * 05/11/01  ah      Slip VDpdfVerify.C into the service pack
 * 09/14/01  ah      Removed the VDpdf functions, back in VDxml where they belong
 *                   New dom based sms to pdf conversion routine
 ***************************************************************************/

SOURCE
VLsmsExt.I
VLsmsCmd.I
VLsmsCmd2.I
VLsmsCmd3.I
VLsmsMark.I
VLsmsUnwrap.I
VLsmsPlate.I
VLsmsBevel.I
VLunwMisc.I
VLunwTran.I
VLunwBevel.I
VLsmsTest.c
VLsmsPdf.c
VLsmsLog.c

LIB
#if ISDP_MAKE_SP
$SPXL/lib/vlisms.o
#else
$LOFT/lib/vlisms.o
#endif

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$VDS/spec
$STRUCT/spec
$LOFT/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXL/include
$SPXS/include
$SPXV/include
#endif
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
$STRUCT/include
$LOFT/include
$LOFT/include/prototypes
$LOFT/include/private

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp




