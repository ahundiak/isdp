/* $Id: vdirrvcmd.m,v 1.15 2002/06/07 20:14:49 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/vdirrvcmd.m
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vdirrvcmd.m,v $
 *      Revision 1.15  2002/06/07 20:14:49  ahundiak
 *      ah
 *
 *      Revision 1.14  2002/05/17 15:22:34  ahundiak
 *      ah
 *
 *      Revision 1.13  2002/03/14 22:17:01  ylong
 *      Added VDrrvPen.c and VDrrvBevel.c
 *
 *      Revision 1.12  2002/02/28 21:41:34  ahundiak
 *      ah
 *
 *      Revision 1.11  2001/06/03 14:50:59  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.10  2001/04/13 19:48:52  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/03/19 22:06:24  jdsauby
 *      Added pdm_info and purp_info attributes to tree, moved post to create form
 *
 *      Revision 1.8  2001/03/16 19:05:40  jdsauby
 *      Modified to suit for Posting, File and Database Operations
 *
 *      Revision 1.7  2001/03/13 00:19:32  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/03/11 18:39:42  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/09 15:15:19  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/07 16:24:20  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/22 22:42:33  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/20 15:21:32  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/17 14:23:45  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 ***************************************************************************/

SOURCE
VDrrvCreate.c
VDrrvReview.c
VDrrvUtil.c
VDrrvTree.c
VDrrvDooms.c
VDrrvFile.c
VDrrvPost.c
VDrrvDbOps.c
VDrrvAttr.c
VDrrvStaging.c
VDrrvDiff.c
VDrrvSnap.c
VDrrvList.c
VDrrvEqp.c
VDrrvComp.c
VDrrvPen.c
VDrrvBevel.c
VDrrvGet.c

LIB
#if ISDP_MAKE_SP
$SPXV/lib/vdirrvcmd.o
#else
$VDS/lib/vdirrvcmd.o
#endif

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$LOCAL/include/glib-1.2
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
/export/home/forms/xforms/source/xfi/include
/export/home/forms/xforms/source/xfi/fs_include
.

SPEC
$EXNUC/spec
$GRNUC/spec
$VDS/spec


OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
