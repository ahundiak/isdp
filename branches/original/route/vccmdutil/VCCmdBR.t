
/* $Id: VCCmdBR.t,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdutil/VCCmdBR.t
 *
 * Description:
 *      Command object for override bend radius maintenance
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdBR.t,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/03  16:55:28  pinnacle
# Replaced: vccmdutil/VCCmdBR.t for:  by impd for route
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/03/12  22:21:02  pinnacle
# Replaced: vccmdutil/VCCmdBR.t for:  by hverstee for cabling
#
# Revision 1.2  1997/01/16  14:50:44  pinnacle
# Replaced: vccmdutil/VCCmdBR.t for:  by hverstee for cabling
#
# Revision 1.1  1996/11/12  17:20:20  pinnacle
# Created: vccmdutil/VCCmdBR.t by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Command object to modify the bend radius of the free linestring
    vertices of a composite cable object

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

class             VCCmdBR
product_name     "$ROUTE"
command_table    "cable.cmd"
options          "isTC"
start_state       main
command_string    VCC_M_CbSetBrad,0,VCCbSbrd
synonym           VCC_M_CbDelBrad,1,VCCbDbrd
synonym           VCC_M_CbClrBrad,2,VCCbCbrd

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

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state *

  on TERMINATE
  state Cleanup

  on BACKUP
  state -

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
  state Cleanup

  on ERROR
  state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state main

  on CMD_TYPE = 0
  state SETstart

  on CMD_TYPE = 1 
  state DELstart

  on CMD_TYPE = 2 
  state CLRstart

  on ELSE
  state unimplemented

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state unimplemented

  message_key   VC_M_UnImplemented
  status_key    VC_S_Exiting

  on ELSE
  state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state SETstart

  message_key   VC_M_CbSetBrad
  prompt_key    VC_P_Bradius
  dynamics      off
  mask          " GRm_DIST | GRm_BACK_UP "
  filter        get_event

  on DISTANCE
    do VCBget
    state SETget

  on ELSE
    state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state SETget

  prompt_key        VC_P_SelCable
  accept_key        VC_P_AccVertex
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCBset
    state .

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state DELstart

  message_key       VC_M_CbDelBrad
  prompt_key        VC_P_SelCable
  accept_key        VC_P_AccVertex
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCBset
    state .

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state CLRstart

  message_key       VC_M_CbDelBrad
  prompt_key        VC_P_SelCable
  accept_key        VC_P_AccReject
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCBclr
    state .

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Cleanup

  on ELSE
    state terminate

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

