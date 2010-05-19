/* $Id: vdixml.m,v 1.5 2001/09/14 13:49:13 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdxml/vdixml.m
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdixml.m,v $
 *      Revision 1.5  2001/09/14 13:49:13  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/04/12 14:04:45  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/20 15:19:40  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/11 21:30:18  art
 *      sp merge
 *
# Revision 1.1  2000/04/25  16:20:48  pinnacle
# ah
#
# Revision 1.9  2000/03/24  15:20:54  pinnacle
# bsp
#
# Revision 1.8  2000/03/07  14:20:22  pinnacle
# ah
#
# Revision 1.7  2000/02/18  16:26:22  pinnacle
# sms
#
# Revision 1.6  2000/01/26  15:42:58  pinnacle
# ah
#
# Revision 1.3  2000/01/10  21:15:52  pinnacle
# ah
#
# Revision 1.2  1999/10/26  19:37:08  pinnacle
# ah
#
# Revision 1.1  1999/04/21  20:01:14  pinnacle
# xml
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/21/99  ah      Creation
 * 03/24/00  ah      Add bsp routines
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDxml.C
VDxmlDom.C
VDxmlBsp.C
VDxmlParse.c
VDxmlParseS.c
VDdxf.C        
VDpdf.C
VDpdfChr.C
VDpdfAttrs.C
VDpdfVerify.C
VDhttp.C

VDxml2Parse.c
VDxml2ParseS.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdixml.o
#else
$VDS/lib/vdixml.o
#endif

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

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
