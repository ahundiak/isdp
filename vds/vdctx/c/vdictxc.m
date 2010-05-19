/* $Id: vdictxc.m,v 1.15 2001/10/19 18:21:34 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdictx/c/vdictxc.m
 *
 * Description: Dot c routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdictxc.m,v $
 *      Revision 1.15  2001/10/19 18:21:34  ahundiak
 *      ah
 *
 *      Revision 1.14  2001/10/18 15:31:02  ahundiak
 *      ah
 *
 *      Revision 1.13  2001/08/24 20:00:01  ahundiak
 *      ah
 *
 *      Revision 1.12  2001/06/22 15:12:54  ahundiak
 *      ah
 *
 *      Revision 1.11  2001/05/17 14:48:14  ahundiak
 *      ah
 *
 *      Revision 1.10  2001/05/02 15:33:19  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/01/14 16:02:29  art
 *      sp merge
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      creation
 ***************************************************************************/

SOURCE
VDctxMgr.c
VDctxXml.c
VDctxInit.c
VDctxBase.c
VDctxInfo.c
VDctxComp.c
VDctxWalk.c
VDctxTest.c
VDctxList.c
VDctxPiece.c
VDctxStage.c
VDctxXdom.c
VDctzStaging.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdictxc.o
#else
$VDS/lib/vdictxc.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
#endif
$LOCAL/include/glib-1.2
$LOCAL/include
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

