
 /* $Id: VCCmdPG.t,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdPG.t
 *
 * Description:
 *
 *  State table for Place Guide commands
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPG.t,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/10/31  08:48:18  pinnacle
# Replaced: vccmd/VCCmd*.t for: Changed product_name from CABLE to ROUTE by aharihar for route
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.7  1997/01/23  23:44:56  pinnacle
# Replaced: vccmd/VCCmdPG.t for:  by hverstee for cabling
#
# Revision 1.6  1997/01/03  17:51:32  pinnacle
# Replaced: vccmd/VCCmdPG.t for:  by hverstee for cabling
#
# Revision 1.5  1996/12/19  23:39:56  pinnacle
# Replaced: vccmd/VCCmdPG.t for:  by hverstee for cabling
#
# Revision 1.4  1996/11/25  17:42:54  pinnacle
# Replaced: vccmd/VCCmdPG.t for:  by hverstee for cabling
#
# Revision 1.3  1996/10/25  14:24:12  pinnacle
# Replaced: vccmd/VCCmdPG.t for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  20:41:26  pinnacle
# Replaced: vccmd/VCCmdPG.t for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:14:54  pinnacle
# Created: vccmd/VCCmdPG.t by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *      10/31/97          Anand         Changed product_name to $ROUTE
 *
 * -------------------------------------------------------------------*/

/*
 *     Command object code to create a cable conduit from graphics
 */

class                   VCCmdPG
product_name           "$ROUTE"
command_table          "cable.cmd"
options                "isTC"
start_state            start

command_string          VCC_M_PlaceGuide,VC_CMDTYP_GEN,VCPlGuide

form    VC_FRMNAM_MAIN, VC_FRM_MAIN,VC_FORMTYPE_USER,"-1","-1"
form    VC_FRMNAM_SUB , VC_FRM_SUB ,VC_FORMTYPE_USER,"-1","-1"

/*=======================================================================*/

state_table
#include        "VCmsg.h"        /* message keys        */
#include        "VCCmdDef.h"
#include        "FI.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state *

  on TERMINATE
        state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
        state Cleanup

  on GR_UNKNOWN_TYPE.VC_RTC_BTN_LOADATT
        state Loadatt

  on GR_UNKNOWN_TYPE.VC_RTC_BTN_USRPAR
        state user_form

  on GR_UNKNOWN_TYPE.VC_RTC_RESET
        state Startform

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state start

  on ELSE
    state Startform

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Startform

  message_key    VC_M_PlaceGuide

  on ELSE
    do VCCmdReset (&me->ret)
    state Startobj

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Startobj

  on ELSE
     do VCCmdInit  (&me->ret)
     state Formfill

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Formfill

   prompt         " "
   status         " "
   dynamics       off
   filter         get_event

   on EX_DATA
      state Place

   on EX_BACK_UP
      state .

   on EX_RJT_MOVEON
      state Place

   on EX_RESET
      state Startform

   on EX_FORM_FINISHED
        do VCCmdRetCode (&me->ret)

               on RETURN_CODE = VC_RTC_CANCEL
                   state Cleanup

               on RETURN_CODE = VC_RTC_RESET
                   state Startform

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
                state Loadatt

        state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Loadatt

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

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state user_form

  prompt_key    VC_P_AddAttr
  filter        get_event

  on EX_FORM_FINISHED
        state -

  on ELSE
        state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Place

  prompt_key             VC_P_IdCurve
  accept_key             VC_P_AccReject
  relocate_key           VC_S_CompNotFound
  locate_eligible        "+GR3dlinestr,GRbcsubbc"
  dynamics                off
  locate_owner           "VC_LOCATE_ALL"
  filter                  locate

  on EX_BACK_UP
        state Formfill

  on EX_RJT_MOVEON
        state PlaceStr

  on EX_DATA or EX_OBJID
     do VCCmdGetRef (&me->ret)

        on RETURN_CODE = VC_RTC_ERROR
        state .

        on RETURN_CODE = VC_RTC_ALLOK
        state Process

        on RETURN_CODE = VC_RTC_PLACED
        state Process

   state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state PlaceStr

  prompt_key       VC_P_CurvePt
  dynamics         VC_MLDYN_LINE
  filter           get_event

  on EX_RJT_MOVEON
     do VCCmdPGpl
     state Process

  on EX_DATA or EX_OBJID
     do VCCmdPGvt
        on RETURN_CODE = VC_RTC_ERROR
        state Place

     state .

  on ELSE
     state .

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Process

  message_key            VC_S_PlacingGd

  on ELSE
      do VCCmdInsert (&me->ret)
         on RETURN_CODE = VC_RTC_DONE
         state Cleanup

      state Startobj

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Cleanup

  on ELSE
        do VCCmdCleanup (&me->ret)
        state terminate

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

