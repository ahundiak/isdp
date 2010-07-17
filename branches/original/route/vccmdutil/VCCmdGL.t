
/* $Id: VCCmdGL.t,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdutil/VCCmdGL.t
 *
 * Description:
 *      Command object for set cabling globals
 *
 * Dependencies:
 *
 *
 * Revision History:
 *        $Log: VCCmdGL.t,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/03  16:55:30  pinnacle
# Replaced: vccmdutil/VCCmdGL.t for:  by impd for route
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.1  1997/07/22  15:18:30  pinnacle
# Created: vccmdutil/VCCmdGL.t by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class                VCCmdGL
product_name         "$ROUTE"
command_table        "cable.cmd"
options              "isTC"
start_state           main
command_string       VCC_M_SetGlobals,0,VCGLset

form                 VC_FRMNAM_SYS, VC_FRM_MAIN, VC_FORMTYPE_USER,"-1","-1"

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

/*------------------------------------------------------------------------*/

state *

  on TERMINATE
    state Cleanup

  on GR_UNKNOWN_TYPE.TERMINATE or
     GR_UNKNOWN_TYPE.CLEAR_STACK
    state Cleanup

  on EX_BACK_UP
    state -

/*------------------------------------------------------------------------*/

state  main

  on CMD_TYPE = 0
    state main_sub0

  on ELSE
    state unimplemented

/*------------------------------------------------------------------------*/

state unimplemented

  message_key    VC_M_UnImplemented
  status_key     VC_S_Exiting

  on ELSE
    state Cleanup

/*------------------------------------------------------------------------*/

state Cleanup

  on ELSE
    do VCGLcleanup (&me->ret)
    state terminate

/*------------------------------------------------------------------------*/

state  main_sub0

  message_key   VC_M_SetGlobals
  dynamics      off

  on ELSE
    do VCGLstart (&me->ret)
    state main_sub1

/*------------------------------------------------------------------------*/

state main_sub1

  message_key   VC_M_SetGlobals
  dynamics      off
  filter        get_event

  on EX_FORM_FINISHED
    state Cleanup

  on ELSE
    state .

/*------------------------------------------------------------------------*/

