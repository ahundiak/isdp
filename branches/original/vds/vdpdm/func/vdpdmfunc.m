/* $Id: vdpdmfunc.m,v 1.11 2001/11/08 20:11:16 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdpdm/func/vdpdmfunc.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdpdmfunc.m,v $
 *      Revision 1.11  2001/11/08 20:11:16  jdsauby
 *      JTS MP TR 5764, added caching of DB queries into DOM tree - jds
 *
 *      Revision 1.10  2001/10/03 14:04:52  jdsauby
 *      JTS MP CR 5527 and 5591
 *
 *      Revision 1.9  2001/06/04 13:08:37  jdsauby
 *      CR3403, new replace part
 *
 *      Revision 1.8  2001/04/24 20:41:56  jdsauby
 *      Post Macros, CR 5083
 *
 *      Revision 1.7  2001/04/12 20:42:50  jdsauby
 *      sp 11
 *
 *      Revision 1.6  2001/03/02 21:45:11  jdsauby
 *      Added purpose Info
 *
 *      Revision 1.5  2001/02/26 16:11:16  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/21 13:02:27  jdsauby
 *      CR4088
 *
 *      Revision 1.3  2001/02/12 21:26:04  jdsauby
 *      Added for CR 4088
 *
 *      Revision 1.2  2001/02/05 18:43:15  jdsauby
 *      Made PLOAD friendly with ISDP_MAKE_SP variable
 *
 *      Revision 1.1  2001/02/05 16:38:46  jdsauby
 *      JTS MP CR4088
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/31/00  ah      creation
 ***************************************************************************/

SOURCE
VDpdmFileKey.c
VDpdmApprCfg.c
VDpdm.I
VDpdmRefList.C
VDpdmStartup.c
VDpdmPurpose.I
VDpdmPost.I
VDpdmNotebook.C
VDpdmNbDoom.I
VDpdmMacros.I
VDpdmReplPrt.I
VDpdmCache.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdpdmfunc.o
#else
$VDS/lib/vdpdmfunc.o
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
