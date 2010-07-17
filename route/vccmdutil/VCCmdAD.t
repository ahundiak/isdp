
/* $Id: VCCmdAD.t,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdutil/VCCmdAD.t
 *
 * Description:
 *      Command object for attach/detach cable
 *
 *
 * Dependencies:
 *
 *
 * Revision History:
 *        $Log: VCCmdAD.t,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.2  1998/10/14  14:52:58  pinnacle
# Replaced: vccmdutil/VCCmdAD.t for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/03  16:55:22  pinnacle
# Replaced: vccmdutil/VCCmdAD.t for:  by impd for route
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.7  1997/10/06  16:47:24  pinnacle
# Replaced: vccmdutil/VCCmdAD.t for:  by apazhani for cabling
#
# Revision 1.6  1997/03/19  18:39:08  pinnacle
# Replaced: vccmdutil/VCCmdAD.t for:  by hverstee for cabling
#
# Revision 1.5  1997/01/31  18:08:12  pinnacle
# Replaced: vccmdutil/VCCmdAD.t for:  by hverstee for cabling
#
# Revision 1.4  1997/01/20  22:18:06  pinnacle
# Replaced: vccmdutil/VCCmdAD.t for:  by hverstee for cabling
#
# Revision 1.3  1997/01/16  14:50:24  pinnacle
# Replaced: vccmdutil/VCCmdAD.t for:  by hverstee for cabling
#
# Revision 1.2  1996/11/21  21:32:38  pinnacle
# Replaced: vccmdutil/VCCmdAD.t for:  by hverstee for cabling
#
# Revision 1.1  1996/10/15  19:34:16  pinnacle
# Created: vccmdutil/VCCmdAD.t by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *        09/25/97        Alwin     Inserted the state GET_CHOICE and state 
 *                                  MOV_VERTEX for allowing the user to
 *                                  move the vertex and to attach it to
 *                                  the Point, instead  of inserting a new
 *                                  vertex.
 *        10/14/98        Alwin     Made sure while selecting the Rway guide
 *				    user is not allowed to pick the correction
 *				    component.
 *
 *************************************************************************/

class                VCCmdAD
product_name         "$ROUTE"
command_table        "cable.cmd"
options              "isTC"
start_state           main
command_string       VCC_M_CbAttach,0,VCCbAtt
synonym              VCC_M_CbDetach,1,VCCbDet

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

state *

  on TERMINATE
  do VCADReset
  do VCADDel
  state terminate

  on CLEAR_STACK
  do VCADReset
  do VCADDel
  state terminate

  on EX_BACK_UP
  state -

state  main

  on CMD_TYPE = 0
  state main_sub0

  on CMD_TYPE = 1
  state main_sub1

  on ELSE
  state terminate

/*------------------------------------------------------------------------*/

state  main_sub0

  message_key      VC_M_CbAttach

  on ELSE
  state GET_FATHER_ATT

state  GET_FATHER_ATT

  prompt_key        VC_P_IdGdRwPt
  accept_key        VC_P_AccReject
  relocate_key      VC_S_CompNotFound
  dynamics          off
  locate_eligible   "+VCGuide,VCTerm,VRRComp,VRRCComp,GR3dpoint,GRgencs"
  locate_owner      "VC_LOCATE_ALL"
  filter            locate

  on EX_RJT_MOVEON
  state .

  on EX_DATA or EX_OBJID
  do VCADGetFather
      /* changed ERROR -> VC_RTC_ERROR Alwin */
      on RETURN_CODE = VC_RTC_ERROR
      state .

      on RETURN_CODE = VC_RTC_SINGLE
        state GET_CHOICE

      on RETURN_CODE = VC_RTC_RWEND
      state GET_FATHER2

  state GET_CABATTCON

state GET_FATHER2

  prompt_key         VC_P_IdRwOther
  locate_eligible    "+VRRComp,VRRCComp"
  locate_owner       "VC_LOCATE_ALL"
  dynamics           off
  filter             locate

  on EX_DATA
    do VCADGetARW ( &me->ret )
	/* Introduced this check. TR179801971 Alwin */
	on RETURN_CODE = VC_RTC_ERROR 
	state .
    state GET_CABATTCON

state  GET_CHOICE 

  prompt  "Accept, to locate the desired vertex / Reject to continue"
  filter  wfi

  on EX_DATA    state MOV_VERTEX 

  on EX_RJT_MOVEON  state GET_CABATTPT

state MOV_VERTEX 

  prompt_key       VC_P_IdCable
  accept           "Accept at the desired Vertex"
  relocate_key      VC_S_CompNotFound
  locate_eligible   "+VCCable"
  dynamics          off
  locate_owner      "VC_LOCATE_LOCAL"
  filter            locate

  on EX_DATA or EX_OBJID 
       do VCADGetCable 
           on ERROR state .
       do VCADMoAttVertex ( &me->ret  )
           on RETURN_CODE = VC_ERROR  
               do status  "Vertex movement Failed"
               state GET_FATHER_ATT
       state main_sub0

state  GET_CABATTPT

  prompt_key        VC_P_IdCable
  accept_key        VC_P_AccLoc
  relocate_key      VC_S_CompNotFound
  locate_eligible   "+VCCable"
  dynamics          off
  locate_owner      "VC_LOCATE_LOCAL"
  filter            locate

  on EX_DATA or EX_OBJID
  do VCADGetCable
      on ERROR
      state .

  state PROCESSATT

state  GET_CABATTCON

  prompt_key        VC_P_IdCable
  accept_key        VC_P_AccVtxLoc
  relocate_key      VC_S_CompNotFound
  locate_eligible   "+VCCable"
  dynamics          off
  locate_owner      "VC_LOCATE_LOCAL"
  filter            locate

  on EX_DATA or EX_OBJID
  do VCADGetCable
      on ERROR
      state .

  state GET_CABATTCON2

state GET_CABATTCON2

  prompt_key        VC_P_Id2Vtx
  filter            get_event

  on EX_RJT_MOVEON
  state PROCESSATT

  on EX_DATA or EX_OBJID
  do VCADGetVtx2
      on ERROR
      state .

  state PROCESSATT

state  PROCESSATT

  on ELSE
  do VCADProcess
  do VCADReset
  state GET_FATHER_ATT

/*------------------------------------------------------------------------*/

state  main_sub1

  message_key      VC_M_CbDetach

  on ELSE
  state GET_FATHER_DET

state  GET_FATHER_DET

  prompt_key        VC_P_IdGdRwPt
  accept_key        VC_P_AccReject
  relocate_key      VC_S_CompNotFound
  dynamics          off
  locate_eligible   "+VCGuide,VCTerm,VRRComp,VRRCComp,GR3dpoint,GRgencs"
  locate_owner      "VC_LOCATE_ALL"
  filter            locate

  on EX_RJT_MOVEON
  state .

  on EX_DATA or EX_OBJID
  do VCADGetFather
      on ERROR
      state .

  state GET_CABDET

state  GET_CABDET

  prompt_key        VC_P_IdCable
  accept_key        VC_P_AccReject
  relocate_key      VC_S_CompNotFound
  locate_eligible   "+VCCable"
  dynamics          off
  locate_owner      "VC_LOCATE_LOCAL"
  filter            locate

  on EX_DATA or EX_OBJID
  do VCADGetCable
      on ERROR
      state .
  state PROCESSDET

state  PROCESSDET

  on ELSE
  do VCADProcess
  do VCADReset
  state GET_FATHER_DET

/*------------------------------------------------------------------------*/

