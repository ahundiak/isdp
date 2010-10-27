 /* $Id: VDCmdADS.t,v 1.1.1.1 2001/01/04 21:09:25 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdADS.t
 *
 * Description:
 *
 *  This is the command class state file for all actions on the attribute
 *   driven symbols table objects (edit/review)
 *   supersedes VDADScmd.t
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VDCmdADS.t,v $
 *     Revision 1.1.1.1  2001/01/04 21:09:25  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1995/09/05  22:57:28  pinnacle
# Replaced: vdtbl/cmd/VDCmdADS.t for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/14  22:29:48  pinnacle
# Replaced: vdtbl/cmd/VDCmdADS.t for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/11  23:22:04  pinnacle
# Replaced: vdtbl/cmd/VDCmdADS.t for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/29  17:07:08  pinnacle
# Replaced: vdtbl/cmd/VDCmdADS.t for:  by azuurhou for vds.240
#
# Revision 1.1  1995/07/06  15:21:26  pinnacle
# Created: vdtbl/cmd/VDCmdADS.t by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/12/95          HV            New
 *
 * -------------------------------------------------------------------*/

/* --------------------------------------------------------------------- */
/* CLASS SPECIFICATION */


class           VDCmdADS
product_name    "$VDS"
command_table   "vds.cmd"
options         "isTC"
start_state     start

command_string  VDC_M_DloAdEd, VD_CMD_ADS_EDIT, VDDloAdEd
synonym         VDC_M_DloAdRv, VD_CMD_ADS_REV,  VDDloAdRv

form            VD_ADSYM_FORM_NAME, VD_ADS_EDITFORM,0,"-1","-1"

/* --------------------------------------------------------------------- */
/* STATES AREA */

state_table

#include        "grmessage.h"
#include        "griodef.h"
#include        "msdef.h"
#include        "lcdef.h"
#include        "FI.h"
#include        "VDmsg.h"
#include        "VDStextdef.h"
#include        "VDCmdADS.h"

/* ======================================================================== */

state start

  on TERMINATE
     state Cleanup

  on CMD_TYPE = VD_CMD_ADS_EDIT
     state start_e_ads

  on CMD_TYPE = VD_CMD_ADS_REV
     state start_r_ads

  on ELSE
     state Cleanup

/* ======================================================================== */

state start_e_ads

  on TERMINATE
     state Cleanup

  on ELSE
     do VDADS_StEdit
     state main_e_ads

/* ======================================================================== */

state start_r_ads

  on TERMINATE
     state Cleanup

  on ELSE
     do VDADS_StRev           /* change for review startup    */
     state main_r_ads

/* ======================================================================== */

state main_e_ads

  display_form  VD_ADS_EDITFORM
  message_key   VD_M_DloAdEd
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state -

  on TERMINATE
        state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
        state Cleanup

  on EX_FORM_FINISHED
        do VDADS_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_e_ads

             on RETURN_CODE = FI_ACCEPT
             state Cleanup

             on RETURN_CODE = FI_EXECUTE
             state .

        state .

  on ELSE
        state .

/* ======================================================================== */

state main_r_ads

  display_form  VD_ADS_EDITFORM
  message_key   VD_M_DloAdRv
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state -

  on TERMINATE
        state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
        state Cleanup

  on EX_FORM_FINISHED
        do VDADS_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_r_ads

        state .

  on ELSE
        state .

/* ======================================================================== */

state  Cleanup

  on ELSE
             do VDADS_Cleanup
             state terminate

/* ======================================================================== */

