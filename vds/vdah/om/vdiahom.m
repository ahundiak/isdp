/* $Id: vdiahom.m,v 1.21 2002/04/01 15:38:29 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/vdiah.m
 *
 * Description: Dot I and C utilities
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdiahom.m,v $
 *      Revision 1.21  2002/04/01 15:38:29  ahundiak
 *      ah
 *
 *      Revision 1.20  2002/03/30 17:26:02  ad
 *      *** empty log message ***
 *
 *      Revision 1.19  2002/02/25 20:22:07  ahundiak
 *      ah
 *
 *      Revision 1.18  2002/01/03 14:44:41  ahundiak
 *      ah
 *
 *      Revision 1.17  2001/11/16 14:26:12  ahundiak
 *      ah
 *
 *      Revision 1.16  2001/10/24 15:53:12  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.15  2001/10/19 18:30:21  ahundiak
 *      ah
 *
 *      Revision 1.14  2001/09/04 13:33:08  ahundiak
 *      ah
 *
 *      Revision 1.13  2001/08/02 15:31:14  ahundiak
 *      ah
 *
 *      Revision 1.12  2001/06/22 15:10:00  ahundiak
 *      ah
 *
 *      Revision 1.11  2001/06/07 19:30:53  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/06/03 14:41:33  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/05/02 15:14:06  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/04/03 20:53:02  anand
 *      *** empty log message ***
 *
 *      Revision 1.7  2001/02/22 22:52:13  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/02/17 14:01:12  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/02/12 20:48:50  jdsauby
 *      Moved VDpdm.I to vds/vdpdm/func  js
 *
 *      Revision 1.4  2001/02/08 15:19:46  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
# Revision 1.2  2000/12/06  16:29:28  pinnacle
# ah
#
# Revision 1.1  2000/12/06  14:53:10  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/05/00  ah      creation
 * 02/12/01  js      moved VDpdm.I to vds/vdpdm/func
 * 03/04/01  Anand   Knocked out VDcoli.I since it's been moved. Did SP stuff.
 * 04/25/01  ah      Added new functions to VDobj2.I
 * 06/07/01  ah      Added VDbufMacroj.I
 ***************************************************************************/

SOURCE
#if ISDP_MAKE_SP
VDFrmSubList.I
VDobj2.I
VDobj3.I
VDbufMacroj.I
VDdraw.I
VDexp.I
VDdoomXml.c
VDdoom.I
VDobj.I
VDref.I
#else
VDref.I
VDexp.I
VDchn.I
VDvla2.I
VDdraw.I
VDdoom.I
VDdoomXml.c
VDahChn.I
VDahClass.I
VDahExp.I
VDahFrm.I
VDahLoc.I
VDahObj.I
VDahPPL.I
VDahRef.I
VDbro1.I
VDmac.I
VDobj.I
VDobj2.I
VDobj3.I
VDppl2.I
VDtag.I
VDvla.I
VDxmlPDM.I
VDFrmSubList.I
VDbufMacroj.I
#endif

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdiahom.o
#else
$VDS/lib/vdiahom.o
#endif

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

