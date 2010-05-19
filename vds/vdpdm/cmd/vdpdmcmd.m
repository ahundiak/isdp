/* $Id: vdpdmcmd.m,v 1.9 2001/10/03 14:04:18 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/part/vdict1part.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdpdmcmd.m,v $
 *      Revision 1.9  2001/10/03 14:04:18  jdsauby
 *      JTS MP CR 5527 and 5591
 *
 *      Revision 1.8  2001/06/04 13:07:51  jdsauby
 *      CR3403, new replace part
 *
 *      Revision 1.7  2001/04/24 20:41:07  jdsauby
 *      Post Macros, CR 5083
 *
 *      Revision 1.6  2001/04/12 20:41:40  jdsauby
 *      sp 11
 *
 *      Revision 1.5  2001/03/29 19:37:52  jdsauby
 *      Set Purpose Info command
 *
 *      Revision 1.4  2001/02/26 16:10:59  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/21 13:00:35  jdsauby
 *      CR4088
 *
 *      Revision 1.2  2001/02/05 18:40:29  jdsauby
 *      Made PLOAD friendly with ISDP_MAKE_SP variable
 *
 *      Revision 1.1  2001/02/05 16:38:07  jdsauby
 *      JTS MP CR4088
 *
# Revision 1.6  2000/12/07  17:40:02  pinnacle
# ah
#
# Revision 1.5  2000/08/23  14:50:00  pinnacle
# ah
#
# Revision 1.4  2000/07/13  12:28:40  pinnacle
# Replaced: vds/vdct1/part/vdict1part.m for:  by jdsauby for Service Pack
#
# Revision 1.3  2000/06/30  17:28:24  pinnacle
# ah
#
# Revision 1.2  2000/06/02  14:35:42  pinnacle
# ah
#
# Revision 1.1  2000/05/31  21:04:10  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/31/00  ah      creation
 ***************************************************************************/

SOURCE
VDpdmMain.c
VDpdmPtHull.c
VDpdmHullPt.c
VDpdmNonList.c
VDpdmSetPurp.c
VDpdmClass.c
VDpdmNoteBk.c
VDpdmCmdUtil.c
VDpdmMacro.c
VDpdmReplPrt.c
VDpdmNewRev.c
VDpdmDbNb.C
VDpdmNbTitle.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdpdmcmd.o
#else
$VDS/lib/vdpdmcmd.o
#endif


SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec

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
$PDUDP/include
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
