
 /* $Id: VCCmdPT.t,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdPT.t
 *
 * Description:
 *
 *  State table for Place Terminal commands
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPT.t,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.3  1998/11/13  16:18:40  pinnacle
# TR179801229
#
# Revision 1.2  1998/07/22  06:44:18  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/10/31  08:48:18  pinnacle
# Replaced: vccmd/VCCmd*.t for: Changed product_name from CABLE to ROUTE by aharihar for route
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.13  1997/09/10  17:41:46  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by apazhani for cabling
#
# Revision 1.12  1997/07/14  22:52:30  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.11  1997/05/07  14:08:32  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.10  1997/04/28  22:22:28  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.9  1997/03/12  21:40:32  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.8  1997/01/23  23:45:12  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.7  1997/01/03  17:51:08  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.6  1996/12/19  23:39:34  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.5  1996/10/30  14:00:56  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.4  1996/10/25  14:23:18  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.3  1996/10/08  21:56:04  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  20:41:04  pinnacle
# Replaced: vccmd/VCCmdPT.t for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:16:08  pinnacle
# Created: vccmd/VCCmdPT.t by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *      09/10/97          Alwin         Modified to add Dynamics
 *      10/31/97          Anand         Changed product_name to $ROUTE
 *      07/22/98          Alwin	        Modified & added a intermediate 
 *					"state Evaluate".
 *      11/13/98          Alwin         Removed the rotation angle option
 *                                      during the placement. As per CERT
 *                                      request. TR179801229
 *
 * -------------------------------------------------------------------*/

/* CLASS SPECIFICATION */

class           VCCmdPT
product_name    "$ROUTE"
command_table   "cable.cmd"
options         "isTC"
start_state     start

command_string  VCC_M_PlaceTerm,   VC_CMDTYP_GEN,   VCPlterm
synonym         VCC_M_PlaceElTerm, VC_CMDTYP_EL,    VCPlEterm
synonym         VCC_M_PlaceFoTerm, VC_CMDTYP_FO,    VCPlFterm
synonym         VCC_M_PlaceCbConn, VC_CMDTYP_MISC1, VCPlCbConn

form            VC_FRMNAM_MAIN, VC_FRM_MAIN,VC_FORMTYPE_USER,"-1","-1"
form            VC_FRMNAM_SUB , VC_FRM_SUB ,VC_FORMTYPE_USER,"-1","-1"

/* ======================================================================== */

state_table

#include        "grmessage.h"
#include        "griodef.h"
#include        "msdef.h"
#include        "lcdef.h"
#include        "FI.h"
#include        "VCmsg.h"
#include        "VCCmdDef.h"

#define DYNCOMP 100
/* ======================================================================== */

state *

  on TERMINATE
        state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
        state Cleanup

  on GR_UNKNOWN_TYPE.VC_RTC_BTN_LOADATT
        state Load_att

  on GR_UNKNOWN_TYPE.VC_RTC_BTN_USRPAR
        state user_form

  on GR_UNKNOWN_TYPE.VC_RTC_PLACED
        state Insert

  on GR_UNKNOWN_TYPE.VC_RTC_RESET
        state start_form

/* ======================================================================== */

state start

  on CMD_TYPE = VC_CMDTYP_EL or
     CMD_TYPE = VC_CMDTYP_FO or
     CMD_TYPE = VC_CMDTYP_GEN
     state start_form

  on CMD_TYPE = VC_CMDTYP_MISC1
     state start_cbcon

  on ELSE
     state terminate

/* ======================================================================== */

state start_form

  message_key     VC_M_PlaceTerm

  on ELSE
     do VCCmdReset (&me->ret)
     state Startobj

/* ======================================================================== */

state Startobj

  on ELSE
     do VCCmdInit  (&me->ret)
     state formin

/* ======================================================================== */

state formin

  prompt_key    VC_P_SelTerm
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state .

  on EX_DATA
        state Place

  on EX_RJT_MOVEON
        state Place

  on EX_RESET
        state start_form

  on EX_FORM_FINISHED
        do VCCmdRetCode (&me->ret)

             on RETURN_CODE = VC_RTC_CANCEL
             state Cleanup

             on RETURN_CODE = VC_RTC_RESET
             state start_form

             on RETURN_CODE = VC_RTC_DONE
             state Place

             on RETURN_CODE = VC_RTC_ACCEPT
             state Place

        state .

  on ELSE
        do VCCmdRetCode (&me->ret)
             on RETURN_CODE = VC_RTC_BTN_USRPAR
                state user_form

             on RETURN_CODE = VC_RTC_BTN_LOADATT
                state Load_att

        state .

/* ======================================================================== */

state Load_att

  accept_key         VC_P_AccReject
  relocate_key       VC_S_CompNotFound
  prompt_key         VC_P_SelCopy
  locate_eligible    "+VCRoot"
  locate_owner       "VC_LOCATE_ALL"
  filter             locate

  on EX_BACK_UP
        state -

  on EX_DATA
        do VCCmdLoadAtt (&me->ret)
        state -

  on ELSE
        state .

/* ======================================================================== */

state user_form

  prompt_key    VC_P_AddAttr
  filter        get_event

  on EX_FORM_FINISHED
        state -

  on ELSE
        state .

/* ======================================================================== */

state  Cleanup

   on ELSE
        do VCCmdCleanup (&me->ret)
        state terminate

/* ======================================================================== */

state start_cbcon

  message_key      VC_M_PlaceCbConn

  on ELSE
     do VCCmdInit  (&me->ret)
     state Place_cbcon

/* ======================================================================== */

state Place_cbcon

  prompt_key         VC_P_SelCabEnd
  accept_key         VC_P_AccReject
  relocate_key       VC_S_CompNotFound
  dynamics           off
  locate_owner       "VC_LOCATE_LOCAL"
  locate_eligible    "+VCCable"
  filter             locate

  on EX_BACK_UP
        state start_cbcon

  on EX_DATA or EX_OBJID
     do VCCmdGetRef (&me->ret)

        on RETURN_CODE = VC_RTC_PLACED
        state Insert_cbcon

        on RETURN_CODE = VC_RTC_ERROR
        state .

     state Insert_cbcon

/* ======================================================================== */

state Place

  prompt_key         VC_P_SelRefMov
  accept_key         VC_P_AccReject
  relocate_key       VC_S_CompNotFound
  dynamics           off
  locate_owner       "VC_LOCATE_ALL"
  locate_eligible    "+GRgencs,VREquipment,VDequipment"
  filter             locate

  on EX_BACK_UP
        state start_form

  on EX_RJT_MOVEON
     do VCCmdNulPar (&me->ret)
        on RETURN_CODE = VC_RTC_ERROR
                  do VCCmdCleanup (&me->ret)
                  state start
        state Evaluate

  on EX_DATA or EX_OBJID
     do VCCmdGetRef (&me->ret)
           on RETURN_CODE = VC_RTC_PLACED
           state Insert

           on RETURN_CODE = VC_RTC_ERROR
                  do VCCmdCleanup (&me->ret)
                  state start

           state Evaluate

  on ELSE
     state .

/* ======================================================================== */

/* Added this Intermediate state to avoid the confusion. Alwin */
state Evaluate 

   on ELSE 
     do VCTEvaluate ( &me->ret )

     on RETURN_CODE = VC_RTC_ERROR
	do VCCmdCleanup ( &me->ret )
	state start

     state Position

/* ======================================================================== */

state Position

/********* Commented and separated from the "state Position", as this 
method is getting executed twice, unnessarily . Found while fixing the 
TR179801132

 execute VCTEvaluate (&me->ret)
     on RETURN_CODE = VC_RTC_ERROR
        do VCCmdCleanup (&me->ret)
        state start

*********/

  prompt_key    VC_P_Position
  dynamics      DYNCOMP
  filter        get_event

  on EX_RJT_MOVEON
     do VCAT_pid (&me->ret)
         on RETURN_CODE = VC_RTC_PID
            state Rotate3D
            /****
            *  state RotatePID
            Alwin for TR179801229 ****/

         state Rotate3D

  on EX_BACK_UP
         state Place

  on EX_DATA
      do VCCmdPosition (&me->ret)
         on RETURN_CODE = VC_RTC_ALLOK
            do VCAT_pid (&me->ret)
              on RETURN_CODE = VC_RTC_PID
                 state Rotate3D
                /****
                *  state RotatePID
                Alwin for TR179801229 ****/

      state Rotate3D

  state .

/* ======================================================================== */

/*     Rotation in PID environment, only 2D     */

state RotatePID

  prompt_key    VC_P_RotatePID
  dynamics      off       /*  TBD   */
  filter        get_event

  on EX_RJT_MOVEON
         state Insert

  on EX_BACK_UP
         state Evaluate

  on EX_DATA or EX_STRING
     do VCCmdRotate (&me->ret)
         on RETURN_CODE = VC_RTC_ALLOK
         state Insert

  state .

/* ======================================================================== */

state Rotate3D

/*      TBD       */

  on ELSE
    state Insert

/* ======================================================================== */

state Insert

  message_key          VC_S_PlacingTm

  on ELSE
      do VCCmdInsert (&me->ret)
         on RETURN_CODE = VC_RTC_DONE
         state Cleanup

      state Startobj
      
/* ======================================================================== */

state Insert_cbcon

  message_key          VC_S_PlacingCn

  on ELSE
      do VCCmdCbInsert (&me->ret)
         on RETURN_CODE = VC_RTC_DONE
         state Cleanup

      state start_cbcon

/* ======================================================================== */

