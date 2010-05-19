 /* $Id: VDCmdDLO.t,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdDLO.t
 *
 * Description:
 *
 *  This is the command class state file for all actions on the table
 *   layout object (create/edit/post/delete)
 *   supersedes VDDLOcmd.t
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VDCmdDLO.t,v $
 *     Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/09/05  22:56:44  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.t for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/14  22:30:10  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.t for:  by hverstee for vds.240
#
# Revision 1.2  1995/08/11  23:21:14  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLO.t for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  15:21:02  pinnacle
# Created: vdtbl/cmd/VDCmdDLO.t by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      03/13/95          HV            New
 *
 * -------------------------------------------------------------------*/

/* --------------------------------------------------------------------- */
/* CLASS SPECIFICATION */

class           VDCmdDLO
product_name    "$VDS"
command_table   "vds.cmd"
options         "isTC"
start_state     start

command_string  VDC_M_EdDrwlo, 0, VDDloEd
synonym         VDC_M_RvDrwlo, 1, VDDloRv

form            VDN_DLO_MAINFORM, VD_DLO_MAINFORM,0,"-1","-1"
form            VDN_DLO_FILLFORM, VD_DLO_FILLFORM,0,"-1","-1"
form            VDN_RLO_MAINFORM, VD_RLO_MAINFORM,0,"-1","-1"
form            VDN_RLO_FILLFORM, VD_RLO_FILLFORM,0,"-1","-1"


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
#include        "VDCmdDrwlo.h"

/* ======================================================================== */

state start

  on TERMINATE
     state Cleanup

  on CMD_TYPE = VD_DLO_CMD_EDIT
     state start_edit

  on CMD_TYPE = VD_DLO_CMD_REVIEW
     state start_review

  on ELSE
     state Cleanup

/* ======================================================================== */

state start_edit

  on ELSE
     do VDDLO_EMSt
       on TERMINATE
          state Cleanup

     state main_edit

/* ======================================================================== */

state start_review

  on ELSE
     do VDDLO_RMSt
       on TERMINATE
          state Cleanup

     state main_review

/* ======================================================================== */

state main_edit

  message_key   VD_M_EdDrwlo
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state start_edit

  on TERMINATE
        state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
        state Cleanup

  on EX_FORM_FINISHED
        do VDGetRetCode(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_edit

             on RETURN_CODE = FI_ACCEPT
             state Cleanup

             on RETURN_CODE = FI_EXECUTE
             state .

        state .

  on ELSE
        do VDGetRetCode(&me->ret)
             on RETURN_CODE = VD_DLO_RETC_SUB
             do VDDLO_EFSt
             state sub_edit
        state .

/* ======================================================================== */

state sub_edit

  message       "Edit Field Fill"
  dynamics      off
  filter        get_event

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK or
     TERMINATE
        do VDDLO_Cleanfill
        state Cleanup

  on EX_FORM_FINISHED
        do VDDLO_Cleanfill
        state main_edit

  on ELSE
        state .

/* ======================================================================== */

state  Cleanup
  on ELSE
             do VDDLO_Cleanup
             state terminate

/* ======================================================================== */

state main_review

  message_key   VD_M_RvDrwlo
  dynamics      off
  filter        get_event

  on EX_BACK_UP
        state start_review

  on TERMINATE
        state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
        state Cleanup

  on EX_FORM_FINISHED
        state Cleanup

  on ELSE
        do VDGetRetCode(&me->ret)
             on RETURN_CODE = VD_DLO_RETC_SUB
                do VDDLO_RFSt
                state sub_review
        state .

/* ======================================================================== */

state sub_review

  message       "Review Field Fill"
  dynamics      off
  filter        get_event

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK or
     TERMINATE
        do VDDLO_Cleanfill
        state Cleanup

  on EX_FORM_FINISHED
        do VDDLO_Cleanfill
        state main_review

  on ELSE
        state .

/* ======================================================================== */

