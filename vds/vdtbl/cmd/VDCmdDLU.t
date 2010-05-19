 /* $Id: VDCmdDLU.t,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdDLU.t
 *
 * Description:
 *
 *  This is the command class state file for all utility actions on the
 *   table layout, sort criteria or summarization criteria objects.
 *    (post/delete)
 *    supersedes VDDLUcmd.t
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VDCmdDLU.t,v $
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
# Revision 1.4  1995/09/05  22:56:16  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.t for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/15  23:40:10  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.t for:  by hverstee for vds.240
#
# Revision 1.2  1995/08/11  23:21:40  pinnacle
# Replaced: vdtbl/cmd/VDCmdDLU.t for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  15:20:38  pinnacle
# Created: vdtbl/cmd/VDCmdDLU.t by hverstee for vds.240
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

class           VDCmdDLU
product_name    "$VDS"
command_table   "vds.cmd"
options         "isTC"
start_state     start

command_string  VDC_M_Dlo_Del,VD_DLU_CMD_DELETE, VDSscDl
synonym         VDC_M_Dlo_Pst,VD_DLU_CMD_POST, VDSscPs

form            VDN_DLU_UTILFORM, VD_DLU_UTILFORM, 0,"-1","-1"


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
#include        "VDCmdDLU.h"

/* ======================================================================== */

state start

  on CMD_TYPE = VD_DLU_CMD_DELETE
     do VDDLU_Init
        on TERMINATE
        state Cleanup

     state start_delete

  on CMD_TYPE = VD_DLU_CMD_POST
     do VDDLU_Init
        on TERMINATE
        state Cleanup

     state start_post

  on ELSE
     state Cleanup

/* ======================================================================== */

state start_delete

  on ELSE
     do VDDLU_Start
     state main_delete

/* ======================================================================== */

state start_post

  on ELSE
     do VDDLU_Start
     state main_post

/* ======================================================================== */

state  Cleanup
  on ELSE
             do VDDLU_Cleanup
             state terminate

/* ======================================================================== */

state main_post

  message_key   VD_M_Dlo_Pst
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
        do VDDLU_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_post

             on RETURN_CODE = FI_ACCEPT
             state Cleanup

             on RETURN_CODE = FI_EXECUTE
             state start_post

        state .

/* ======================================================================== */

state main_delete

  message_key   VD_M_Dlo_Del
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
        do VDDLU_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state start_delete

             on RETURN_CODE = FI_ACCEPT
             state Cleanup

             on RETURN_CODE = FI_EXECUTE
             state start_delete

        state .

/* ======================================================================== */

