
/* $Id: VCCmdSC.t,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdutil/VCCmdSC.t
 *
 * Description:
 *      Command object for set equipment connectible
 *
 *
 * Dependencies:
 *
 *
 * Revision History:
 *        $Log: VCCmdSC.t,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/03  16:55:36  pinnacle
# Replaced: vccmdutil/VCCmdSC.t for:  by impd for route
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/05/19  19:50:44  pinnacle
# Replaced: vccmdutil/VCCmdSC.t for:  by hverstee for cabling
#
# Revision 1.2  1997/03/19  18:39:54  pinnacle
# Replaced: vccmdutil/VCCmdSC.t for:  by hverstee for cabling
#
# Revision 1.1  1997/01/23  23:57:42  pinnacle
# Created: vccmdutil/VCCmdSC.t by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class                VCCmdSC
product_name         "$ROUTE"
command_table        "cable.cmd"
options              "isTC"
start_state           main
command_string       VCC_M_SetConnect,0,VCSCset

/*C   state table definition for the command  */

state_table

#include        "grmessage.h"
#include        "griodef.h"
#include        "dp.h"
#include        "msdef.h"
#include        "lcdef.h"
#include        "FI.h"
#include        "VCmsg.h"
#include        "VCCmdDef.h"

/*------------------------------------------------------------------------*/

state *

  on TERMINATE
    state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
    state Cleanup

  on EX_BACK_UP
    state -

/*------------------------------------------------------------------------*/

state  main

  on CMD_TYPE = 0
    state main_sub0

  on ELSE
    state unimplemented

/*------------------------------------------------------------------------*/

state unimplemented

  message_key    VC_M_UnImplemented
  status_key     VC_S_Exiting

  on ELSE
    state Cleanup

/*------------------------------------------------------------------------*/

state Cleanup

  on ELSE
    do VCSCcleanup (&me->ret)
    state terminate

/*------------------------------------------------------------------------*/

state  main_sub0

  message_key      VC_M_SetConnect

  on ELSE
    state GET_EQUIP

/*------------------------------------------------------------------------*/

state GET_EQUIP

  prompt_key        VC_P_IdEquip
  accept_key        VC_P_AccReject
  relocate_key      VC_S_CompNotFound
  dynamics          off
  locate_eligible   "+VDequipment,VREquipment,ACconst"
  locate_owner      "VC_LOCATE_LOCAL"
  filter            locate

  on EX_RJT_MOVEON
  state .

  on EX_DATA or EX_OBJID
  do VCSCgetref (&me->ret)
      on RETURN_CODE = VC_RTC_ERROR
      state .

  state PROCESS

/*------------------------------------------------------------------------*/

state  PROCESS

  on ELSE
    do VCSCprocess (&me->ret)
    state Cleanup

/*------------------------------------------------------------------------*/

