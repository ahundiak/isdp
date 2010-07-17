
 /* $Id: VCCmdPB.t,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */
   
/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdPB.t
 *
 * Description:
 *
 *  State table for Place Backshell command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPB.t,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.4  2000/03/15  19:44:04  pinnacle
# Replaced: vccmd/VCCmdPB.t for:  by lawaddel for route
#
# Revision 1.3  2000/03/13  17:05:24  pinnacle
# Replaced: vccmd/VCCmdPB.t for:  by lawaddel for route
#
# Revision 1.2  1998/11/13  16:25:08  pinnacle
# TR79801229 Terminal Rotation
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
# Revision 1.2  1997/09/10  17:40:58  pinnacle
# Replaced: vccmd/VCCmdPB.t for:  by apazhani for cabling
#
# Revision 1.1  1997/07/14  22:58:14  pinnacle
# Created: vccmd/VCCmdPB.t by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *      09/10/97          Alwin         Modified to add Dynamics
 *      10/31/97          Anand         Changed product_name to $ROUTE
 *      11/13/98          Alwin         Removed the rotation angle option
 *                                      during the placement. As per CERT
 *                                      request. TR179801229
 *      03/13/00          law           cr179900814-allow backshells on guides
 * -------------------------------------------------------------------*/

/* CLASS SPECIFICATION */

class           VCCmdPB
product_name    "$ROUTE"
command_table   "cable.cmd"
options         "isTC"
start_state     start

command_string  VCC_M_PlaceShell,  VC_CMDTYP_GEN,   VCPlShell

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

#define        DYNCOMP 100
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

  on CMD_TYPE = VC_CMDTYP_GEN
     state start_form

  on ELSE
     state terminate

/* ======================================================================== */

state start_form

  message_key     VC_M_PlaceShell

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

  prompt_key    VC_P_SelShell
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

/*  prompt_key         VC_P_SelRef */
/* ======================================================================== */
/* cr179900814-modify prompt and locate filter                              */
state Place

  prompt             "Select Terminal or Guide"
  accept_key         VC_P_AccReject
  relocate_key       VC_S_CompNotFound
  dynamics           off
  locate_owner       "VC_LOCATE_ALL"
  locate_eligible    "+VCTerm, VCGuide"
  filter             locate

  on EX_BACK_UP
        state formin

  on EX_RJT_MOVEON
     state .

  on EX_DATA or EX_OBJID
     do VCCmdGetRef (&me->ret)
        on RETURN_CODE = VC_RTC_ALLOK
        state Position

        on RETURN_CODE = VC_RTC_PLACED
        state Insert

        on RETURN_CODE = VC_RTC_ERROR
        state .

     state Position

  on ELSE
     state .

/* ======================================================================== */

state Position

 execute VCBEvaluate (&me->ret)
     on RETURN_CODE = VC_RTC_ERROR
        do VCCmdCleanup (&me->ret)
        state start

  prompt_key    VC_P_PosBksh
  dynamics      DYNCOMP
  filter        get_event

  on EX_RJT_MOVEON
            /****
     do VCAT_pid (&me->ret)
         on RETURN_CODE = VC_RTC_PID
            state Rotate3D
            *  state RotatePID
            Alwin for TR179801229 ****
            *** removed for cr179900814 ***
         state Rotate3D
           ***/
         /*** installed for cr179900814 ***/
         state Place

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
         state Position

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

