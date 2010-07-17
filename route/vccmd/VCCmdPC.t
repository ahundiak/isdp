
 /* $Id: VCCmdPC.t,v 1.3 2002/05/24 21:41:49 anand Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vccmd/VCCmdPC.t
 *
 * Description:
 *
 *  State table for Place Cable commands
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPC.t,v $
 *     Revision 1.3  2002/05/24 21:41:49  anand
 *     Second set of bug fixes for the cable lead enhancement.
 *     Fixes errors in model arising out of merge-cable workflows.
 *     Ensure placeholders are created for markers for DB driven
 *     cables. Major shuffling of code in Sketch cable state table.
 *
 *     Revision 1.2  2002/05/08 15:48:23  anand
 *     Files added/modified for sub-cable functionality.
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1997/11/30  18:31:38  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by impd for route
#
# Revision 1.3  1997/11/30  16:08:10  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by r250_int for route
#
# Revision 1.18  1997/11/18  11:41:52  pinnacle
# Replaced: vccmd/VCCmdPC.t for: TR 179701166 by aharihar for cabling
#
# Revision 1.17  1997/08/11  21:48:02  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.16  1997/05/10  14:53:54  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.15  1997/05/07  14:08:48  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.14  1997/04/30  13:02:10  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.13  1997/04/28  22:22:44  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.12  1997/01/23  23:44:40  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.11  1997/01/09  19:47:26  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.9  1996/12/18  17:36:46  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.8  1996/11/21  21:29:16  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.7  1996/11/12  21:43:42  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.6  1996/10/25  14:23:48  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.5  1996/10/08  21:56:20  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.4  1996/10/07  20:41:42  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  21:10:10  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:29:08  pinnacle
# Replaced: vccmd/VCCmdPC.t for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:14:18  pinnacle
# Created: vccmd/VCCmdPC.t by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *      11/18/97        Anand         Modified dynamics in state ConnectPT
 *
 * -------------------------------------------------------------------*/


class             VCCmdPC
super_class       VCCmdCAT
product_name     "$ROUTE"
command_table    "cable.cmd"
options          "isTC"
start_state       start

command_string  VCC_M_PlaceCable, VC_CMDTYP_GEN, VCPlCab
synonym         VCC_M_PlaceElCab, VC_CMDTYP_EL,  VCPlECab
synonym         VCC_M_PlaceFoCab, VC_CMDTYP_FO,  VCPlFCab

form      VCPCAB_FORMNAME,  VCC_PC_CONTROL_FORM,  VC_FORMTYPE_USER,"-1","-1"
form      VCCAT_PAR_USR,    VCC_PC_USR_ATTR_FORM, VC_FORMTYPE_USER,"-1","-1"
form      VC_SPLITCAB_FORM, VCC_PC_SPL_CAB_FORM,  VC_FORMTYPE_USER,"-1","-1"

status_display  VCCAT_PAR_FORM                          ,"-1","-1"




/*****************************************************************************
  STATES AREA 
*****************************************************************************/

state_table

#include "VCmsg.h"
#include "VCCmdDef.h"
#include "VCCmdCAT.h"
#include "VCCmdPC.h"

state *

  on TERMINATE
  state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
  state Cleanup

  on GR_UNKNOWN_TYPE.VC_RTC_CANCEL
  state Cleanup

  on GR_UNKNOWN_TYPE.VC_RTC_AS_IS
  state .

  on GR_UNKNOWN_TYPE.VCCAT_LOAD_CABLE
  state setAttrFromLink
  
  on GR_UNKNOWN_TYPE.VC_RTC_BTN_LOADATT
  state setAttrFromLink
  
  on GR_UNKNOWN_TYPE.VCL_LINK_FREE_POINT
  state freePoint
  
  on GR_UNKNOWN_TYPE.VCL_LINK_CONNECT
  state Connectall

  on GR_UNKNOWN_TYPE.VCL_LINK_BREAK
  state Breakall

  on GR_UNKNOWN_TYPE.VCL_LINK_ATTACH
  state Attachall

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state start

  on CMD_TYPE = VC_CMDTYP_GEN
    state startgen

  on CMD_TYPE = VC_CMDTYP_EL
    state startel

  on CMD_TYPE = VC_CMDTYP_FO
    state startfo

  on ELSE
    state unimplemented

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state startgen

  message_key    VC_M_PlaceCable

  on ELSE
    state rstart


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state startel

  message_key    VC_M_PlaceElCab

  on ELSE
    state rstart

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state startfo

  message_key    VC_M_PlaceFoCab

  on ELSE
    state rstart

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state unimplemented

  message_key    VC_M_UnImplemented
  status_key     VC_S_Exiting

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state rstart

  on ELSE
    do VCFstart()
    state freePoint

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state setAttrFromLink

  accept_key         VC_P_AccReject
  relocate_key       VC_S_CompNotFound
  prompt_key         VC_P_SelCopy
  locate_eligible    "+VCRoot"
  locate_owner       "VC_LOCATE_ALL"
  filter             locate
     
  on EX_DATA or EX_OBJID
    do VCGetLinkAttr ( &me->ret ) 
    state -

  on EX_BACK_UP or EX_RJT_MOVEON
    state -

  on ELSE
    state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state freePoint

  prompt_key     VC_P_DataPoint
  dynamics       VC_MLDYN_LINE
  filter         get_event

  on EX_FORM_FINISHED
    do VCMLSetRetCode( &me->ret )
    on RETURN_CODE = VCL_LINK_SPLIT
      state PreSplit
    state .

  on EX_DATA 
    do VCPushPoint( &me->ret )
    state suspend /* . */

  on EX_RJT_MOVEON
    state insertLink

  on EX_BACK_UP 
    do VCPopPoint( &me->ret )
    on RETURN_CODE = VCL_EMPTY_STACK
      do VCinit (&me->ret)
      state freePoint

  state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Breakall

  prompt_key     VC_P_DataBreak
  dynamics       VC_MLDYN_CONN
  filter         get_event

  on EX_FORM_FINISHED
    state .

  on EX_DATA
    do VCPushPoint( &me->ret )
    state freePoint

  on EX_RJT_MOVEON
    state .

  on EX_BACK_UP
    do VCPopPoint( &me->ret )
    on RETURN_CODE = VCL_EMPTY_STACK
      do VCinit (&me->ret)
      state freePoint

  state freePoint

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Connectall

  prompt_key         VC_P_IdConnect
  relocate_key       VC_S_CompNotFound
  accept_key         VC_P_AccReject
  locate_eligible    "+VCTerm,VCCable"
  locate_owner       "VC_LOCATE_ALL"
  dynamics           VC_MLDYN_CONN
  filter             locate

  on EX_FORM_FINISHED
    state .

  on EX_DATA
    do VCGetCitem ( &me->ret )
      on RETURN_CODE = VCL_LINK_ENDED
      state ConnectPT

      on RETURN_CODE = VCL_LINK_JOIN
      state insertLink

      on RETURN_CODE = VCL_LINK_ROUTING
      state freePoint

      on RETURN_CODE = VCL_LINK_SPLIT
      state PreSplit

      on RETURN_CODE = VC_RTC_ERROR
      state .

    state ConnectPT

  on EX_BACK_UP or EX_RJT_MOVEON
    state freePoint

  on ELSE
    state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state ConnectPT

  prompt             "Locate dynamic connectpoint/MOVEON to select closest"
  dynamics           VC_MLDYN_LINE
  filter             get_event

  on EX_FORM_FINISHED
    state .

  on EX_RJT_MOVEON
     do VCGetCPT ( &me->ret )
       on RETURN_CODE = VCL_LINK_ENDED
       state insertLink

     state freePoint

  on EX_DATA
     do VCAddCPT (&me->ret )
       on RETURN_CODE = VCL_LINK_ENDED
       state insertLink

     state freePoint

  on EX_BACK_UP
     state -

  on ELSE
     state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Attachall

  prompt_key         VC_P_IdGdRwPt
  locate_eligible    "+VCGuide,VCTerm,VRRComp,VRRCComp,GR3dpoint,GRgencs"
  locate_owner       "VC_LOCATE_ALL"
  dynamics           VC_MLDYN_ATTC
  filter             locate

  on EX_FORM_FINISHED
    state .

  on EX_DATA
  do VCGetAitem ( &me->ret )
    on RETURN_CODE = VCL_LINK_NO_PATH
    state AttRW

  on EX_BACK_UP or EX_RJT_MOVEON
    state freePoint

  state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state AttRW

  prompt_key         VC_P_IdRwOther
  locate_eligible    "+VRRComp,VRRCComp"
  locate_owner       "VC_LOCATE_ALL"
  dynamics           VC_MLDYN_ATTC
  filter             locate

  on EX_FORM_FINISHED
    state .

  on EX_DATA
  do VCGetARW ( &me->ret )
    state freePoint 

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state insertLink

  prompt         "  "

  on ELSE
    do VCInsertLink (&me->ret)
      on RETURN_CODE = VC_RTC_ERROR
      state -

    state freePoint

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state PreSplit
  prompt	"Pick leads for sub-cable"

  on ELSE
    do VCSplitPreFormProc( &me->ret )
    on RETURN_CODE = VC_RTC_ERROR
      state -

  state PostSplit


state PostSplit
  filter	get_event
  prompt	"  "

  on EX_FORM_FINISHED
    do VCMLSetRetCode( &me->ret )

    on RETURN_CODE = VC_RTC_ERROR
      do status "Command restarted"
      state freePoint

    on RETURN_CODE = VCL_LINK_JOIN
      do status "Continue sketching"
      do VCRedirectMerge( &me->ret )
      state freePoint

    do VCStartSplit( &me->ret )
      on RETURN_CODE = VCL_LINK_JOIN
	do VCRedirectMerge( &me->ret )
	state freePoint
      state freePoint

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Cleanup

  on ELSE
    do VCCleanup (&me->ret)
    state terminate

