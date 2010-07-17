
 /* $Id: VCCmdCL.t,v 1.1 2002/05/08 15:48:23 anand Exp $ */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vccmd/VCCmdCL.t
 *
 * Description:
 *
 *  State table for "C Configure Cable Leads" command for 
 *  lead configuration management in subcables
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdCL.t,v $
 *     Revision 1.1  2002/05/08 15:48:23  anand
 *     Files added/modified for sub-cable functionality.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      04/12/02        Jayadev       Creation
 * -------------------------------------------------------------------*/

class             VCCmdCL
super_class       VCCmdCAT
product_name     "$ROUTE"
command_table    "cable.cmd"
options          "isTC"
start_state       start

command_string  VCC_M_ConfLeads, 0, VCConfLd

form            VC_SPLITCAB_FORM, VCC_PJ_CONTROL_FORM, VC_FORMTYPE_USER,"-1","-1"

/*****************************************************************************
  STATES AREA 
*****************************************************************************/

state_table

#include "VCmsg.h"
#include "VCCmdDef.h"
#include "VCCmdCAT.h"
#include "VCCmdPC.h"
#include "VCLead.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state start

  on ELSE
    state startgen

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state startgen

  message_key		VC_M_ConLeads
  prompt             	"Identify Subcable to configure leads"
  accept_key         	VC_P_AccReject
  relocate_key       	VC_S_CompNotFound
  locate_eligible    	"+VCCable"
  locate_owner       	"VC_LOCATE_ALL"
  filter             	locate

  on EX_DATA 
    do VCGetObject( &me->ret )
    on RETURN_CODE = VC_ERROR 
	state startgen
    do VCFstart() /* Display the form */
    state Display

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Display

  prompt             	"Manipulate form to configure cable leads"

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
