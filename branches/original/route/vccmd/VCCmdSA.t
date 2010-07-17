
 /* $Id: VCCmdSA.t,v 1.1.1.1 2001/01/04 21:12:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vccmd/VCCmdSA.t
 *
 * Description:
 *
 *  State table for Set cable attributes command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdSA.t,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1997/11/30  18:32:26  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by impd for route
#
# Revision 1.3  1997/11/30  16:08:20  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by r250_int for route
#
# Revision 1.10  1997/11/27  16:38:52  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by onayragu for cabling
#
# Revision 1.9  1997/09/11  20:50:18  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by apazhani for cabling
#
# Revision 1.8  1997/07/29  14:59:26  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by hverstee for cabling
#
# Revision 1.7  1997/01/23  23:45:30  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by hverstee for cabling
#
# Revision 1.6  1997/01/16  14:45:22  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by hverstee for cabling
#
# Revision 1.5  1996/10/29  22:22:32  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by hverstee for cabling
#
# Revision 1.4  1996/10/25  14:22:26  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by hverstee for cabling
#
# Revision 1.3  1996/10/11  21:49:48  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  20:40:40  pinnacle
# Replaced: vccmd/VCCmdSA.t for:  by hverstee for cabling
#
# Revision 1.1  1996/10/03  18:29:00  pinnacle
# Created: vccmd/VCCmdSA.t by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *      09/11/97          Alwin         Modified for Fence operation
 *
 * -------------------------------------------------------------------*/


class             VCCmdSA
product_name     "$ROUTE"
command_table    "cable.cmd"
options          "isTC"
start_state       start

command_string  VCC_M_SetCbAttr, VC_CMDTYP_SET, VCSetAtt
synonym         VCC_M_RevCbAttr, VC_CMDTYP_REV, VCRevAtt

form            VC_FRMNAM_SET,  VC_FRM_MAIN , VC_FORMTYPE_USER, "-1","-1"
form            VC_FRMNAM_SUB,  VC_FRM_SUB  , VC_FORMTYPE_USER, "-1","-1"
form            VC_FRMNAM_MORE, VC_FRM_MORE , VC_FORMTYPE_USER, "-1","-1"
form            VC_FRMNAM_TCON, VC_FRM_TCON , VC_FORMTYPE_USER, "-1","-1"
form            VC_FRMNAM_CCON, VC_FRM_CCON , VC_FORMTYPE_USER, "-1","-1"



/*****************************************************************************
  STATES AREA 
*****************************************************************************/

state_table

#include        "grmessage.h"
#include        "griodef.h"
#include        "msdef.h"
#include        "lcdef.h"
#include        "FI.h"
#include        "VCmsg.h"
#include        "VCCmdDef.h"
#include        "VCCmdCAT.h"

state *

  on EX_FORM_FINISHED
  state .

  on TERMINATE
  state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
  state Cleanup

  on GR_UNKNOWN_TYPE.VC_RTC_BTN_LOADATT
  state setattfrom

  on GR_UNKNOWN_TYPE.VC_RTC_BTN_RECON
  state reconnect

  on GR_UNKNOWN_TYPE.VC_RTC_BTN_USRPAR
  state user_form
  
  on GR_UNKNOWN_TYPE.VC_RTC_AS_IS
  state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state start

  message_key     VC_M_SetCbAttr

  on ELSE
    state rstart

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state rstart

  accept_key         VC_P_AccReject
  relocate_key       VC_S_CompNotFound
  prompt_key         VC_P_IdCabElem
  locate_eligible    "+VCRoot"
  locate_owner       "VC_LOCATE_ALL"
  dynamics           off
  filter             locate

  on EX_DATA or EX_OBJID
    do VCSAget (&me->ret)
       on RETURN_CODE = VC_RTC_ERROR      
          state rstart
    state display

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state display

  on ELSE
    do VCSAdisp ( &me->ret )
    state modify

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state modify

  prompt_key    VC_P_SetAttr
  filter         get_event

  on EX_FORM_FINISHED
        do VCSARetCode (&me->ret)

             on RETURN_CODE = VC_RTC_CANCEL
               state Cleanup

             on RETURN_CODE = VC_RTC_RESET
               state display

             on RETURN_CODE = VC_RTC_DONE
               state rstart

             on RETURN_CODE = VC_RTC_ACCEPT
               state Cleanup

             on RETURN_CODE = VC_RTC_NEXT
               state display

        state .

  on ELSE
        state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

state Cleanup

prompt     " "

  on ELSE
    do VCSACleanup ()
    state terminate

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state setattfrom

  accept_key         VC_P_AccReject
  relocate_key       VC_S_CompNotFound
  prompt_key         VC_P_SelCopy
  locate_eligible    "+VCRoot"
  locate_owner       "VC_LOCATE_ALL"
  filter             locate

  on EX_DATA or EX_OBJID
    do VCSAref ( &me->ret )
    state -

  on EX_BACK_UP or EX_RJT_MOVEON
    state -

  on ELSE
    state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state user_form

  prompt_key    VC_P_AddAttr
  filter        get_event

  on EX_FORM_FINISHED
        state -

  on ELSE
        state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state reconnect

  accept_key         VC_P_AccReject
  relocate_key       VC_S_CompNotFound
  prompt_key         VC_P_SelRefMov
  locate_eligible    "+GRgencs,VREquipment, VDequipment"
  locate_owner       "VC_LOCATE_ALL"
  filter             locate

  on EX_DATA or EX_OBJID
    do VCSAProcessParent (&me->ret)
       on RETURN_CODE = VC_RTC_ERROR      
	  do status "Element not valid"
          state .
    do VCSAdisp ( &me->ret )
    state -

  on EX_BACK_UP or EX_RJT_MOVEON
    do VCSAdisp ( &me->ret )
    state -

  on ELSE
    state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
