
/* $Id: VDCmdTBX.h,v 1.2 2001/08/16 21:42:33 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdTBX.h
 *
 * Description:
 *
 *      include file to define Table Export Command gadgets
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdTBX.h,v $
 *      Revision 1.2  2001/08/16 21:42:33  ylong
 *      Added export xml functionality
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.3  1995/08/29  20:23:08  pinnacle
 * Replaced: vdinclude/VDCmdTBX.h for:  by hverstee for vds.240
 *
 * Revision 1.2  1995/07/11  21:54:04  pinnacle
 * Replaced: vdinclude/VDCmdTBX.h for:  by hverstee for vds.240
 *
 * Revision 1.1  1995/07/06  14:57:42  pinnacle
 * Created: vdinclude/VDCmdTBX.h by hverstee for vds.240
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/30/95          HV            New
 *
 * -------------------------------------------------------------------*/

#ifndef  VDCmdTBX_h

#define  VDCmdTBX_h

/*       form numbers                                     */

#define VD_TBEX_MAINFORM             0

/*       error messages             */

#define VD_TBEX_EMSG_MEM    "Memory allocation error, terminated"

/*       form names                                        */

#define VD_TBEX_FORMNAME            "VDTblExport"

#define VD_TBEX_CMDNO                0
#define VD_TBEX_SEPERSTRING         10
#define VD_TBEX_NUMSEPER             5

/* --------------------------------------------------------- */
/*       Gadgets for VDTblExport form                        */
/* --------------------------------------------------------- */

/*       Gadget numbers      */

#define VD_TBEX_FLD_MSG            10
#define VD_TBEX_FLD_TABNAM         19
#define VD_TBEX_FLD_FILNAM         15
#define VD_TBEX_FLD_SEPER          16
#define VD_TBEX_FLD_DATA           24

#define VD_TBEX_BTN_SELECT         25
#define VD_TBEX_BTN_DESELECT       31

#define VD_TBEX_CHK_NUM            17
#define VD_TBEX_CHK_STR            18

#define VD_TBEX_TOG_FMT            32
#define VD_TBEX_GRP_OPT            22

#define VD_TBEX_NUM_CHSTR          80

#define VD_TBEX_FMT_TXT		    0
#define VD_TBEX_FMT_XML		    1


struct VDTBX_data  {
          IGRshort       colno;
          IGRshort       linno;
          IGRshort       dttyp;
          IGRchar        desc[200];
         
                   };

#endif

