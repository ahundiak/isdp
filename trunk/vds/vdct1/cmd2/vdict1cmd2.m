/* $Id: vdict1cmd2.m,v 1.3 2001/04/03 17:09:36 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct/cmd/vdictcmd2.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdict1cmd2.m,v $
 *      Revision 1.3  2001/04/03 17:09:36  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/14 16:21:13  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 21:48:41  art
 *      sp merge
 *
# Revision 1.6  2000/11/16  19:48:34  pinnacle
# pn
#
# Revision 1.5  2000/09/07  18:04:04  pinnacle
# js
#
# Revision 1.4  2000/08/09  13:07:24  pinnacle
# ah
#
# Revision 1.3  2000/08/08  16:35:14  pinnacle
# ah
#
# Revision 1.1  1999/05/28  13:59:18  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      creation
 * 01/11/01  ah      sp merge
 ***************************************************************************/

SOURCE
VDct1Mgr.c
VDct1Set.c
VDct1Box.c
VDct1Lib.c
VDct1Test.c
VDct1Part.c
VDct1Stru.c
VDct1Attr.c
VDct1Node.c
VDct1Root.c
VDct1Free.c
VDct1Tree.c
VDct1TreeF.c
VDct1DbTbl.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdict1cmd2.o
#else
$VDS/lib/vdict1cmd2.o
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
