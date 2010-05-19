 /* $Id: VDCmdSSC.t,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdSSC.t
 *
 * Description:
 *
 *  This is the command class state file for all actions on the sort
 *   and summarization criteria objects (edit/review)
 *   supersedes VDSSCcmd.t
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VDCmdSSC.t,v $
 *     Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/11/26  15:25:36  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.t for:  by mdong for vds
#
# Revision 1.2  1997/11/11  02:39:40  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.t for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1995/09/05  22:57:48  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.t for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/15  23:40:36  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.t for:  by hverstee for vds.240
#
# Revision 1.4  1995/08/11  23:22:26  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.t for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/04  14:37:10  pinnacle
# Replaced: vdtbl/cmd/VDCmdSSC.t for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  15:20:12  pinnacle
# Created: vdtbl/cmd/VDCmdSSC.t by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      04/20/95          HV            New
 *
 * -------------------------------------------------------------------*/

/* --------------------------------------------------------------------- */
/* CLASS SPECIFICATION */


class           VDCmdSSC
product_name    "$VDS"
command_table   "vds.cmd"
options         "isTC"
start_state     start

command_string  VDC_M_DloSrEd, VD_CMD_SRT_EDIT, VDDloSrEd
synonym         VDC_M_DloSmEd, VD_CMD_SUM_EDIT, VDDloSmEd
synonym         VDC_M_DloExpEd, VD_CMD_EXP_EDIT, VDDloExpEd
synonym         VDC_M_DloSrRv, VD_CMD_SRT_REV, VDDloSrRv
synonym         VDC_M_DloSmRv, VD_CMD_SUM_REV, VDDloSmRv
synonym         VDC_M_DloExpRv, VD_CMD_EXP_REV, VDDloExpRv

form            VD_CRSRT_FORM_NAME, VD_SSC_SORTFORM,0,"-1","-1"
form            VD_CRSUM_FORM_NAME, VD_SSC_SUMMFORM,0,"-1","-1"
form            VD_CREXP_FORM_NAME, VD_SSC_EXPRFORM,0,"-1","-1"

/* --------------------------------------------------------------------- */
/* STATES AREA */

state_table

#include        "grmessage.h"
#include        "griodef.h"
#include        "msdef.h"
#include        "lcdef.h"
#include        "FI.h"
#include        "VDmsg.h"
#include        "VDStextdef.h"
#include        "VDCmdSSC.h"

/* ======================================================================== */

state start

  on CMD_TYPE = VD_CMD_SRT_EDIT
     state start_esort

  on CMD_TYPE = VD_CMD_SRT_REV
     state start_rsort

  on CMD_TYPE = VD_CMD_SUM_EDIT
     state start_esumm

  on CMD_TYPE = VD_CMD_SUM_REV
     state start_rsumm

  on CMD_TYPE = VD_CMD_EXP_EDIT
     state start_eexpr

  on CMD_TYPE = VD_CMD_EXP_REV
     state start_rexpr

  on ELSE
     state Cleanup

/* ======================================================================== */

state start_esort

  on ELSE
     do VDSSC_StSrt
        on TERMINATE
           state Cleanup

     state main_esort

/* ======================================================================== */

state start_esumm

  on ELSE
     do VDSSC_StSum
        on TERMINATE
           state Cleanup

     state main_esumm

/* ======================================================================== */

state start_rsort

  on ELSE
     do VDSSC_StSrt           /* change for review startup    */
        on TERMINATE
           state Cleanup

     state main_rsort

/* ======================================================================== */

state start_rsumm

  on ELSE
     do VDSSC_StSum           /* change for review startup    */
        on TERMINATE
           state Cleanup

     state main_rsumm

/* ======================================================================== */

/* ======================================================================== */

state start_eexpr

  on ELSE
     do VDSSC_StExp
        on TERMINATE
           state Cleanup

     state main_eexpr

/* ======================================================================== */

/* ======================================================================== */

state start_rexpr

  on ELSE
     do VDSSC_StExp           /* change for review startup    */
        on TERMINATE
           state Cleanup

     state main_rexpr

/* ======================================================================== */

state main_esort

  display_form  VD_SSC_SORTFORM
  message_key   VD_M_DloSrEd
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state -

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK 
        state Cleanup

  on TERMINATE
        state Cleanup

  on EX_FORM_FINISHED
        do VDSSC_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_esort

             on RETURN_CODE = FI_ACCEPT
             state Cleanup

             on RETURN_CODE = FI_EXECUTE
             state .

        state Cleanup

  on ELSE
        state .

/* ======================================================================== */

state main_rsort

  display_form  VD_SSC_SORTFORM
  message_key   VD_M_DloSrRv
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state -

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK 
        state Cleanup

  on TERMINATE
        state Cleanup

  on EX_FORM_FINISHED
        do VDSSC_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_rsort

        state .

  on ELSE
        state .

/* ======================================================================== */

state main_esumm

  display_form  VD_SSC_SUMMFORM
  message_key   VD_M_DloSmEd
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state -

  on TERMINATE
        state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK 
        state Cleanup

  on EX_FORM_FINISHED
        do VDSSC_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_esumm

             on RETURN_CODE = FI_ACCEPT
             state Cleanup

             on RETURN_CODE = FI_EXECUTE
             state . 

        state .

  on ELSE
        state .

/* ======================================================================== */

state main_rsumm

  display_form  VD_SSC_SUMMFORM
  message_key   VD_M_DloSmRv
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state -

  on TERMINATE
        state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK 
        state Cleanup

  on EX_FORM_FINISHED
        do VDSSC_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_rsumm

        state .

  on ELSE
        state .

/* ======================================================================== */

state main_eexpr

  display_form  VD_SSC_EXPRFORM
  message_key   VD_M_DloExpEd
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state -

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK 
        state Cleanup

  on TERMINATE
        state Cleanup

  on EX_FORM_FINISHED
        do VDSSC_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_eexpr

             on RETURN_CODE = FI_ACCEPT
             state Cleanup

             on RETURN_CODE = FI_EXECUTE
             state .

        state Cleanup

  on ELSE
        state .

/* ======================================================================== */

state main_rexpr

  display_form  VD_SSC_EXPRFORM
  message_key   VD_M_DloExpRv
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state -

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK 
        state Cleanup

  on TERMINATE
        state Cleanup

  on EX_FORM_FINISHED
        do VDSSC_Rtc(&me->ret)

	     on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_rexpr

             on RETURN_CODE = FI_ACCEPT
             state Cleanup

             on RETURN_CODE = FI_EXECUTE
             state .

        state .

  on ELSE
        state .

/* ======================================================================== */

state  Cleanup

  on ELSE
             do VDSSC_Cleanup
             state terminate

/* ======================================================================== */
