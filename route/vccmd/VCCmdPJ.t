
 /* $Id: VCCmdPJ.t,v 1.2 2002/05/24 21:41:49 anand Exp $ */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vccmd/VCCmdPJ.t
 *
 * Description:
 *
 *  State table for Set Terminal Connections
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPJ.t,v $
 *     Revision 1.2  2002/05/24 21:41:49  anand
 *     Second set of bug fixes for the cable lead enhancement.
 *     Fixes errors in model arising out of merge-cable workflows.
 *     Ensure placeholders are created for markers for DB driven
 *     cables. Major shuffling of code in Sketch cable state table.
 *
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.4  1999/02/12  10:33:36  pinnacle
# Replaced: vccmd/VCCmdPJ.t for: CR 179701619 by aharihar for route
#
# Revision 1.3  1999/01/27  07:09:24  pinnacle
# Replaced: vccmd/VCCmdPJ.t for: CR 179701619 by aharihar for route
#
# Revision 1.2  1999/01/20  17:02:44  pinnacle
# Replaced: vccmd/VCCmdPJ.t for:  by apazhani for route
#
# Revision 1.1  1999/01/19  09:55:50  pinnacle
# Created: vccmd/VCCmdPJ.t by aharihar for route
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      09/16/98          Alwin       Creation
 *    27 Jan '99          Anand       Resolved a few issues related to
 *				      command stack.
 *
 * -------------------------------------------------------------------*/

class             VCCmdPJ
super_class       VCCmdCAT
product_name     "$ROUTE"
command_table    "cable.cmd"
options          "isTC"
start_state       start

command_string  VCC_M_ConnTerm, 0, VCPlJump

form            VCPJUMPER_FORMNAME, VCC_PJ_CONTROL_FORM, VC_FORMTYPE_USER,"-1","-1"



/*****************************************************************************
  STATES AREA 
*****************************************************************************/

state_table

#include "VCmsg.h"
#include "VCCmdDef.h"
#include "VCCmdCAT.h"
#include "VCCmdPJ.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state start

  on ELSE
    state startgen

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state startgen

  message_key		VC_M_ConnTerm
  prompt             	"Identify Terminal for configuring Jumpers"
  accept_key         	VC_P_AccReject
  relocate_key       	VC_S_CompNotFound
  locate_eligible    	"+VCTerm"
  locate_owner       	"VC_LOCATE_ALL"
  filter             	locate

  on EX_DATA or EX_OBJID
    do VCGetObject( &me->ret )
    on RETURN_CODE = VC_ERROR
	state startgen
    do VCFstart() /* Display the form */
    state Display

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Display

  prompt             	"Configure Jumpers in terminal"

  on ELSE
      do VCDispForm( &me->ret )
      state goodbye

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state goodbye

  filter             	get_event

  on EX_FORM_FINISHED 
    do VCCleanup( &me->ret )
    state terminate 

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
