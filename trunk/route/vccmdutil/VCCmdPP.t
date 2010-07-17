
/* $Id: VCCmdPP.t,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdutil/VCCmdPP.t
 *
 * Description:
 *      Command object for set/cut passthrough
 *
 *
 * Dependencies:
 *
 *
 * Revision History:
 *        $Log: VCCmdPP.t,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/03  16:55:32  pinnacle
# Replaced: vccmdutil/VCCmdPP.t for:  by impd for route
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/03/19  18:39:36  pinnacle
# Replaced: vccmdutil/VCCmdPP.t for:  by hverstee for cabling
#
# Revision 1.2  1997/01/16  14:51:44  pinnacle
# Replaced: vccmdutil/VCCmdPP.t for:  by hverstee for cabling
#
# Revision 1.1  1996/10/15  19:34:00  pinnacle
# Created: vccmdutil/VCCmdPP.t by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class                VCCmdPP
product_name         "$ROUTE"
command_table        "cable.cmd"
options              "isTC"
start_state           main
command_string       VCC_M_CbPass,0,VCPPset
synonym              VCC_M_CbUnPass,1,VCPPunset

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

  on CMD_TYPE = 1
  state main_sub1

  on ELSE
    state unimplemented

/*------------------------------------------------------------------------*/

state unimplemented

  on ELSE
    state terminate

/*------------------------------------------------------------------------*/

state Cleanup

  on ELSE
    do VCPPcleanup (&me->ret)
    state terminate

/*------------------------------------------------------------------------*/

state  main_sub0

  message_key      VC_M_CbPass

  on ELSE
    state GET_CABLE_1

/*------------------------------------------------------------------------*/

state  main_sub1

  message_key      VC_M_CbUnPass

  on ELSE
    state GET_CABLE_1

/*------------------------------------------------------------------------*/

state GET_CABLE_1

  prompt_key        VC_P_SelCabCode
  accept_key        VC_P_AccReject
  relocate_key      VC_S_CompNotFound
  dynamics          off
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  filter            locate

  on EX_RJT_MOVEON
  state .

  on EX_DATA or EX_OBJID
  do VCPPcab1 (&me->ret)
      on RETURN_CODE = VC_RTC_ERROR
      state .

  state GET_CABLE_2

/*------------------------------------------------------------------------*/

state  GET_CABLE_2

  prompt_key        VC_P_SelCab2
  accept_key        VC_P_AccReject
  relocate_key      VC_S_CompNotFound
  dynamics          off
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  filter            locate

  on EX_DATA or EX_OBJID
  do VCPPcab2 (&me->ret)
      on RETURN_CODE = VC_RTC_ERROR
      state .

  state PROCESS

/*------------------------------------------------------------------------*/

state  PROCESS

  on ELSE
    do VCPPProcess (&me->ret)
    state GET_CABLE_1

/*------------------------------------------------------------------------*/

