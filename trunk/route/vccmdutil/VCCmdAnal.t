
/* $Id: VCCmdAnal.t,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdutil/VCCmdAnal.t
 *
 * Description:
 *     Command object code to Analyze individual fiber links
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdAnal.t,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/03  16:55:24  pinnacle
# Replaced: vccmdutil/VCCmdAnal.t for:  by impd for route
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/03/19  18:39:22  pinnacle
# Replaced: vccmdutil/VCCmdAnal.t for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  22:20:30  pinnacle
# Replaced: vccmdutil/VCCmdAnal.t for:  by hverstee for cabling
#
# Revision 1.4  1997/01/16  14:52:04  pinnacle
# Replaced: vccmdutil/VCCmdAnal.t for:  by hverstee for cabling
#
# Revision 1.3  1996/10/25  19:08:54  pinnacle
# Replaced: vccmdutil/VCCmdAnal.t for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  20:27:46  pinnacle
# Replaced: vccmdutil/VCCmdAnal.t for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:01:54  pinnacle
# Created: vccmdutil/VCCmdAnal.t by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class                   VCCmdAnal
product_name           "$ROUTE"
command_table          "cable.cmd"
options                "isTC"
start_state             start
command_string          VCC_M_CbAnalyze,VC_CMDTYP_GEN,VCAnal 
synonym                 VCC_M_CbAnalEl, VC_CMDTYP_EL, VCAnEl 
synonym                 VCC_M_CbAnalFo ,VC_CMDTYP_FO, VCAnFo 

form    VC_ANA_FNAM, VC_ANA_FORM, VC_FORMTYPE_USER,"-1","-1"

state_table

#include        "grmessage.h"
#include        "griodef.h"
#include        "msdef.h"
#include        "lcdef.h"
#include        "FI.h"
#include        "VCmsg.h"
#include        "VCCmdDef.h"
#include        "VCCmdANA.h"

/*=======================================================================*/
state start

  on CMD_TYPE = VC_CMDTYP_GEN
  state GNstart

  on CMD_TYPE = VC_CMDTYP_EL
  state ELstart

  on CMD_TYPE = VC_CMDTYP_FO
  state FOstart

  on ELSE
  state unimplemented

/*=======================================================================*/
state unimplemented

  message_key   VC_M_UnImplemented
  status_key    VC_S_Exiting

  on ELSE
  state terminate

/*=======================================================================*/
state ELstart

  message_key             VC_M_CbAnalEl
  prompt_key              VC_P_IdTermCab
  locate_eligible        "+VCElCable,VCElTerm"
  dynamics                off
  locate_owner           "VC_LOCATE_ALL"
  filter                  locate

  on EX_DATA or EX_OBJID
         do VCGetRefInfo ( &me->ret)
            on RETURN_CODE = VC_RTC_ANCAB
            state SetupForm

         state ELsec

/*=======================================================================*/
state FOstart

  message_key             VC_M_CbAnalFo
  prompt_key              VC_P_IdTermCab
  locate_eligible        "+VCFoCable,VCFoTerm"
  dynamics                off
  locate_owner           "VC_LOCATE_ALL"
  filter                  locate

  on EX_DATA or EX_OBJID
         do VCGetRefInfo ( &me->ret)
            on RETURN_CODE = VC_RTC_ANCAB
            state SetupForm

         state FOsec

/*=======================================================================*/
state GNstart

  message_key             VC_M_CbAnalyze
  prompt_key              VC_P_IdTermCab
  locate_eligible        "+VCCable,VCTerm"
  dynamics                off
  locate_owner           "VC_LOCATE_ALL"
  filter                  locate

  on EX_DATA or EX_OBJID
         do VCGetRefInfo ( &me->ret)
            on RETURN_CODE = VC_RTC_ANCAB
            state SetupForm

         state GNsec

/*=======================================================================*/
state        GNsec

  prompt_key             VC_P_SelEnd
  locate_eligible        "+VCTerm"
  dynamics                off
  locate_owner           "VC_LOCATE_ALL"
  filter                  locate

  on EX_DATA or EX_OBJID
         do VCGetRefInfo ( &me->ret)
         state SetupForm

  on EX_RJT_MOVEON
         do VCTrace ( &me->ret)
         state SetupForm

/*=======================================================================*/
state        FOsec

  prompt_key             VC_P_SelEnd
  locate_eligible        "+VCFoTerm"
  dynamics                off
  locate_owner           "VC_LOCATE_ALL"
  filter                  locate

  on EX_DATA or EX_OBJID
         do VCGetRefInfo ( &me->ret)
         state SetupForm

  on EX_RJT_MOVEON
         do VCTrace ( &me->ret)
         state SetupForm

/*=======================================================================*/
state        ELsec

  prompt_key             VC_P_SelEnd
  locate_eligible        "+VCElTerm"
  dynamics                off
  locate_owner           "VC_LOCATE_ALL"
  filter                  locate

  on EX_DATA or EX_OBJID
         do VCGetRefInfo ( &me->ret)
         state SetupForm

  on EX_RJT_MOVEON
         do VCTrace ( &me->ret)
         state SetupForm

/*=======================================================================*/
state        SetupForm

   on ELSE
         do VCFillForm()
         state ProcForm
        
/*=======================================================================*/
state ProcForm

  display_form       VC_ANA_FORM
  prompt_key         VC_P_ANinter
  dynamics           off
  filter             get_event

  on EX_BACK_UP 
          state -

  on EX_FORM_FINISHED
          do VCGetRetCode()

               on RETURN_CODE = FI_CANCEL
                   state Cleanup

               on RETURN_CODE = FI_RESET
                   do VCReset()
                   state SetupForm

               on RETURN_CODE = FI_EXECUTE
                   do VCAnalyze( &me->ret )
                   state .

           state .

/*=======================================================================*/
state Cleanup

        on ELSE
                do VCCleanup()
                state terminate

/*=======================================================================*/

