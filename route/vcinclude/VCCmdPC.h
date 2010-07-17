
/* $Id: VCCmdPC.h,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCCmdPC.h
 *
 * Description:
 *
 *      Constants and structures defined for VC cabling system commands
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdPC.h,v $
 *      Revision 1.2  2002/05/08 15:48:24  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.7  1997/05/06  13:17:52  pinnacle
 * Replaced: vcinclude/VCCmdPC.h for:  by hverstee for cabling
 *
 * Revision 1.6  1997/05/02  21:38:28  pinnacle
 * Replaced: vcinclude/VCCmdPC.h for:  by hverstee for cabling
 *
 * Revision 1.5  1997/03/05  14:39:54  pinnacle
 * Replaced: vcinclude/VCCmdPC.h for:  by hverstee for cabling
 *
 * Revision 1.4  1997/01/20  20:10:26  pinnacle
 * Replaced: vcinclude/VCCmdPC.h for:  by hverstee for cabling
 *
 * Revision 1.3  1996/10/29  16:32:36  pinnacle
 * Replaced: vcinclude/VCCmdPC.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/08/30  17:34:30  pinnacle
 * Replaced: vcinclude/VCCmdPC.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:42:46  pinnacle
 * Created: vcinclude/VCCmdPC.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *      05/27/96	hv		Initial
 *	Feb/Mar 2002	Anand		Split cable related stuff.
 *
 *************************************************************************/
#include "VCLead.h"

#ifndef	VCCmdPC_include

#define	VCCmdPC_include

/*C	forms indexes	*/

/* parameters form is status form */
#define VCC_PC_CONTROL_FORM             0
#define VCC_PC_USR_ATTR_FORM            1
#define VCC_PC_SPL_CAB_FORM		2

/*    VCPcab control form           */

#define VCPCAB_FORMNAME               "VCPcab"

#define VCPCAB_FIBHEAD                          11
#define VCPCAB_ELHEAD                           17
#define VCPCAB_GENHEAD                          13
#define VCPCAB_CONSTRAINT                       14
#define VCPCAB_DIG                              15
#define VCPCAB_CONNECT                          16
#define VCPCAB_ATTACH                           18
#define VCPCAB_ZDEPTH                           20
#define VCPCAB_COMPCODE                         25
#define VCPCAB_TAGNO                            26
#define VCPCAB_BREAK                            28
#define VCPCAB_SPLIT                            29

/*    add cable event codes    */

#define VCL_EMPTY_STACK                  500
#define VCL_LINK_FREE_POINT              501
#define VCL_LINK_ATTACH                  502
#define VCL_LINK_CONNECT                 503
#define VCL_LINK_ENDED                   504
#define VCL_LINK_ROUTING                 505

#define VCL_LINK_NO_PATH                 509
#define VCL_LINK_JOIN                    511
#define VCL_LINK_END_FREE                513

#define VCL_LINK_BREAK                   514

#define VCL_LINK_SPLIT			 515

/*    VCPickLead form related defines          */

#define VC_SPLITCAB_FORM	      "VCPickLead"

#define VCSUBCAB_MESSAGE		10

#define VCSUBCAB_GRAB_LEAD		11 // The '>' button.
#define VCSUBCAB_DROP_LEAD		12 // The '<' button.

#define VCSUBCAB_AVLBL_LEAD		13
#define VCSUBCAB_UNUSD_LEAD		14

#define VCSUBCAB_USED_GROUP		20 // Title and MCF together.
#define VCSUBCAB_USED_FIELD		16 // Multicolumn field.
#define VCSUBCAB_USED_LEADS		0  // column where lead name is shown.
#define VCSUBCAB_USED_WHERE		1  // column showing where lead is used.

#endif
