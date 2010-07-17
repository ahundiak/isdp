/* $Id: VCCmdForm.h,v 1.1.1.1 2001/01/04 21:12:33 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCCmdForm.h
 *
 * Description:
 *
 *      Gadgets for the general VCform (place terminal/guide/backshell)
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdForm.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/12/22  17:03:38  pinnacle
 * Replaced: vcinclude/VCCmdForm.h for:  by lawaddel for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.1  1997/07/14  21:24:12  pinnacle
 * Created: vcinclude/VCCmdForm.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *      12/02/98    law         CR179802404-add rotation to form
 *
 *************************************************************************/

#ifndef	VCCmdForm_include

#define	VCCmdForm_include

/*    FORM HEADINGS             */

#define VCFORM_GDG_GDHEAD                           25
#define VCFORM_GDG_TRHEAD                           22
#define VCFORM_GDG_BKHEAD                           23

/*   regular input              */

#define VCFORM_GDG_CCODE                            40
#define VCFORM_GDG_ADDLAB                           13
#define VCFORM_GDG_TAGNO                            131
#define VCFORM_GDG_UNIT                             19
#define VCFORM_GDG_SYSNM                            20
#define VCFORM_GDG_CHGNUM                           24
#define VCFORM_GDG_APPRV                            37
#define VCFORM_GDG_CONSTR                           38
#define VCFORM_GDG_DESC                             32
#define VCFORM_GDG_NOTES                            21
#define VCFORM_GDG_MSG                              11
#define VCFORM_GDG_AROT                             33 /* TR179802404 */
#define VCFORM_GDG_AROTLBL                          34 /* TR179802404 */

#define VCFORM_GDG_COPYBTN                          29
#define VCFORM_GDG_USERBTN                          30

#define VCFORM_GDG_MTO                              18

/*    erasable gadgets              */

#define VCFORM_GDG_CCODE_TXT                        12
#define VCFORM_GDG_DIAM_TXT                         80
#define VCFORM_GDG_DIAM_FLD                         27
#define VCFORM_GDG_SCALE_TXT                        26
#define VCFORM_GDG_SCALE_FLD                        28

#define VCFORM_GDG_DBSW                             17

/*    old names                           */

#define   VC_GDG_TXT_COMPCODE      12
#define   VC_GDG_TXT_TAGNUMBER     39

#define   VC_GDG_TXT_DIAMETER      80
#define   VC_GDG_TXT_SDESC         31

#define   VC_GDG_FLD_COMPCODE      40
#define   VC_GDG_FLD_TAGNUMBER    131
#define   VC_GDG_FLD_ADDLABEL      13
#define   VC_GDG_FLD_UNITNUMBER    19
#define   VC_GDG_FLD_SYSNUMBER     20

#define   VC_GDG_FLD_CHGNO         24
#define   VC_GDG_FLD_APPSTAT       37
#define   VC_GDG_FLD_CONSTR        38
#define   VC_GDG_CHK_NOMTO         18
#define   VC_GDG_FLD_DIAMETER      27
#define   VC_GDG_FLD_NOTES         21
#define   VC_GDG_FLD_SDESC         32

#define   VC_GDG_BTN_USRPAR        30
#define   VC_GDG_BTN_LOADATT       29

#define   VC_GDG_TGG_NOCODE        17

#define   VC_GDG_FLD_MSG            9

#define   VC_GDG_CMD_GENTERM       22
#define   VC_GDG_CMD_BKSH          23
#define   VC_GDG_CMD_GUIDE         25

#define   VC_GDG_TXT_SCALE         26
#define   VC_GDG_FLD_SCALE         28

#endif
