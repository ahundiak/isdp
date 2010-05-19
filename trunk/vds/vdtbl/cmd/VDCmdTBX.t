 /* $Id: VDCmdTBX.t,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDCmdTBX.t
 *
 * Description:
 *
 *  This is the command class state file for the export table to ASCII
 *  command
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VDCmdTBX.t,v $
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
# Revision 1.4  1995/09/05  22:57:06  pinnacle
# Replaced: vdtbl/cmd/VDCmdTBX.t for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/11  23:20:52  pinnacle
# Replaced: vdtbl/cmd/VDCmdTBX.t for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/11  21:53:10  pinnacle
# Replaced: vdtbl/cmd/VDCmdTBX.t for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  15:19:42  pinnacle
# Created: vdtbl/cmd/VDCmdTBX.t by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/12/95          HV            New
 *
 * -------------------------------------------------------------------*/

/* --------------------------------------------------------------------- */
/* CLASS SPECIFICATION */


class           VDCmdTBX
product_name    "$VDS"
command_table   "vds.cmd"
options         "isTC"
start_state     start

command_string  VDC_M_TblExpt, VD_TBEX_CMDNO, VDTblExpt
form            VD_TBEX_FORMNAME, VD_TBEX_MAINFORM,1,"-1","-1"

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
#include        "VDCmdTBX.h"

/* ======================================================================== */

at wakeup do set_form_pos
at sleep  do save_form_pos

state start

  on TERMINATE
        state Cleanup

  on CMD_TYPE = VD_TBEX_CMDNO
     state Start_tbx

  on ELSE
     state Cleanup

/* ======================================================================== */

state Start_tbx

  on TERMINATE
        state Cleanup

  on ELSE
     do VDTBX_Start
     state Main_tbx

/* ======================================================================== */

state Main_tbx

  display_form  VD_TBEX_MAINFORM
  message_key   VD_M_TblExpt
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
        do VDTBX_Rtc(&me->ret)

             on RETURN_CODE = FI_CANCEL
             state Cleanup

             on RETURN_CODE = FI_RESET
             state Reset

             on RETURN_CODE = FI_ACCEPT
             state Accept

             on RETURN_CODE = FI_EXECUTE
             state Execute

        state .

  on ELSE
        state .

/* ======================================================================== */

state Cleanup

  on ELSE
     do VDTBX_Reset
     state terminate

/* ======================================================================== */

state Reset

  on ELSE
    do VDTBX_Reset
    state Start_tbx

/* ======================================================================== */

state Accept

  on ELSE
    do VDTBX_Exec
    state Cleanup

/* ======================================================================== */

state Execute

  on ELSE
    do VDTBX_Exec

       on TERMINATE
         state Cleanup

    state Reset

/* ======================================================================== */

