
/* $Id: VCCmdDef.h,v 1.2 2002/05/08 15:48:24 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCCmdDef.h
 *
 * Description:
 *
 *      Constants and structures defined for VC cabling system commands
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdDef.h,v $
 *      Revision 1.2  2002/05/08 15:48:24  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:33  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1999/01/19  06:46:32  pinnacle
 * Reserved: vcinclude/VCCmdDef.h by aharihar for route
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/11/30  16:09:14  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by r250_int for route
 *
 * Revision 1.18  1997/11/27  16:38:42  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by onayragu for cabling
 *
 * Revision 1.17  1997/07/31  22:12:12  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.16  1997/07/28  22:15:04  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.15  1997/07/25  18:11:50  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.14  1997/07/21  21:13:02  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.13  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.12  1997/05/22  12:48:56  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.11  1997/05/06  13:16:42  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.10  1997/04/28  21:42:04  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.9  1997/03/06  22:11:20  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.8  1997/01/15  20:23:14  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.7  1997/01/03  14:08:34  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.6  1996/12/16  16:45:26  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.5  1996/10/25  13:43:48  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.4  1996/10/17  20:33:08  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.3  1996/10/14  19:46:22  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.2  1996/09/20  21:14:38  pinnacle
 * Replaced: vcinclude/VCCmdDef.h for:  by hverstee for cabling
 *
 * Revision 1.1  1996/08/28  20:42:22  pinnacle
 * Created: vcinclude/VCCmdDef.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *      18 Jan 1999 Anand       Added entry for Jumper form.
 *
 *************************************************************************/

#ifndef	vc_cmddef_include
#define vc_cmddef_include

/*    locate filters for all commands    */

#define VC_LOCATE_LOCAL \
    (LC_RIGID_COMP|LC_FLEX_COMP|LC_FLEX_OWNER|LC_RIGID_OWNER)
#define VC_LOCATE_REF      LC_REF_OBJECTS
#define VC_LOCATE_ALL      (VC_LOCATE_LOCAL|VC_LOCATE_REF)

/*    command types      */

#define VC_CMDTYP_GEN    0
#define VC_CMDTYP_EL     1
#define VC_CMDTYP_FO     2
#define VC_CMDTYP_MISC1  3
#define VC_CMDTYP_MISC2  4

#define VC_CMDTYP_SET    0
#define VC_CMDTYP_REV    1

/*    form types         */

#define VC_FORMTYPE_USER     0
#define VC_FORMTYPE_AUTO     1
#define VC_FORMTYPE_PERS     2

/*    form names                */

#define   VC_FRMNAM_MAIN      "VCform"         /*   place T,B,G command      */
#define   VC_FRMNAM_SUB       "VCusrpar"       /*   userparam, all commands  */
#define   VC_FRMNAM_CONN      "VCConnect"      /*   connect, main form       */
#define   VC_FRMNAM_MORE      "VCCmore"        /*   cables, more info        */
#define   VC_FRMNAM_SET       "VCSetAtt"       /*   set/review main          */
#define   VC_FRMNAM_ANA       "VCAnal"         /*   analysis main            */
#define   VC_FRMNAM_PCAB      "VCPcab"         /*   place cable control      */
#define   VC_FRMNAM_SYS       "VCParSys"       /*   system parameters        */
#define   VC_FRMNAM_TCON      "VCTermCon"      /*   display terminal conn    */
#define   VC_FRMNAM_CCON      "VCCableCon"     /*   display cable conn       */

/*    form labels               */

#define   VC_FRM_MAIN         0         /*   main (base) form label   */
#define   VC_FRM_SUB          1         /*   first subform            */
#define   VC_FRM_MORE         2         /*   "more info", second sub  */
#define   VC_FRM_TCON         3         /*   termcon, third sub       */
#define   VC_FRM_CCON         4         /*   cablecon, fourth sub     */

/*    cable attachment types    */

#define VC_CABATT_OPEN   0
#define VC_CABATT_TERM   1
#define VC_CABATT_MERGE  2

/*    attribute modes    */

#define VC_SYSTEM_ATTR        0x0001
#define VC_USER_ATTR          0x0002

#define   VC_SYSTEM  0
#define   VC_USER    1

#define   VC_CMD_BUFSIZE     100

/*    VCusrpar multicolumn gadget           */

#define   VC_GDG_MFL_USERPAR       12

/*      all set by _put_response       */
/*      return codes for buttons       */

#define   VC_RTC_BTN_MORE        1001  /* more info form          */
#define   VC_RTC_BTN_CCON        1003  /* Cable connections form  */
#define   VC_RTC_BTN_TCON        1005  /* Term connections form   */
#define   VC_RTC_BTN_USRPAR      1007  /* user param form         */
#define   VC_RTC_BTN_LOADATT     1009  /* copy attr form          */
#define   VC_RTC_BTN_RECON     	 1049  /* change connection	  */

/*      other response codes        */

#define   VC_RTC_ERROR           1020  /* general error           */

/*    do we need these ???          */

#define   VC_RTC_ACCEPT          1011
#define   VC_RTC_CANCEL          1013
#define   VC_RTC_RESET           1015
#define   VC_RTC_DONE            1017

#define   VC_RTC_2D              1019  /* We're in 2D mode.....   */
#define   VC_RTC_PID             1021  /* We're in PID mode       */

/*      ok                          */

#define   VC_RTC_ALLOK           1031  /* general OK (no error)   */
#define   VC_RTC_AS_IS           1033  /* general continue        */

/*      force bypass                */

#define   VC_RTC_PLACED          1035  /* bypass offset (forced)  */
#define   VC_RTC_ENDCON          1037  /* end term, auto close    */
#define   VC_RTC_RWEND           1039  /* auto end of raceway     */
#define   VC_RTC_SINGLE          1041  /* single vertex attach    */

#define   VC_RTC_ANCAB           1043  /* analyze cable select, only
                                          complete network possible  */

#define   VC_RTC_USRRETURN       1045  /* force return from userpar */

#define   VC_RTC_NEXT            1047  /* for fence set attr         */

/*       dynamics definitions       */

#define VC_MLDYN_LINE                   606
#define VC_MLDYN_CONN                   607
#define VC_MLDYN_MVTX                   608
#define VC_MLDYN_DVTX                   609
#define VC_MLDYN_ATTC                   610
#define VC_MLDYN_MSEG                   611

/*C     for command object */

#define VC_LINK_INCRBUF                 30

/*      seen that the VDS/ROUTE equipment approach shuns standardization
        in attribute names I'll define them here so that cabling at least
        shows some semblance of organisation                  */

#define    VC_VDS_EQ_EQTYP        "nomenclature"
#define    VC_VDS_EQ_EQTAG        "eqp_number"
#define    VC_VDS_EQ_COMPT        "compt_number"

/*      forms position controller    */

#define VC_FPOS_PB_MAIN         0
#define VC_FPOS_PB_SUB          1

#define VC_FPOS_PT_MAIN         2
#define VC_FPOS_PT_SUB          3

#define VC_FPOS_PG_MAIN         4
#define VC_FPOS_PG_SUB          5

#define VC_FPOS_PC_MAIN         6
#define VC_FPOS_PC_SUB          7
#define VC_FPOS_PC_CTRL         8
#define VC_FPOS_PC_MORE         9

#define VC_FPOS_SA_MAIN        10
#define VC_FPOS_SA_SUB         11
#define VC_FPOS_SA_MORE        12
#define VC_FPOS_SA_TCON        13
#define VC_FPOS_SA_CCON        14

#define VC_FPOS_RA_MAIN        15
#define VC_FPOS_RA_SUB         16

#define VC_FPOS_ANA            17

#define VC_FPOS_CONN           18

#define VC_FPOS_GLOB           19

/* added for Set Terminal Connections form. Alwin */
#define VC_FPOS_PJ_MAIN        20

/* added for Configure Cable leads. Jayadev */
#define VC_FPOS_CL_MAIN	       21

    /* added for Sketch Cable (split) */
#define VC_FPOS_PC_LEAD	       22

#define VC_FPOS_MAX            40

#endif
