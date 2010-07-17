/* $Id: VSnjnattCmd.t,v 1.1.1.1 2001/01/04 21:10:25 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSnjnattCmd.S
 *
 * Description:	"Set Active Joint Attributes"
 *
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSnjnattCmd.t,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/21  13:32:20  pinnacle
# Command Key Problem
#
# Revision 1.1  1998/03/13  23:27:44  pinnacle
# New Joints
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/98  ah      TR179800680 Modify New Joint - Creation
 * 04/21/98  ah      Truncated command key to 10 characters
 ***************************************************************************/
command_string	VSC_M_VSStAcNJnAt,0,VSStAcNJnA
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSnjnattCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vscmddef.h"

state main
	message_key		VS_M_VSStAcJnAt
	ms_on_off		MS_OFF
	execute 		does_form_exist( &me->ret )

		on RETURN_CODE = "VS_K_FORM_EXIST"
					do ms_on_off MS_ON
					do status_key VS_I_AJAfmExists
								state terminate

		on ELSE do createForm( &me->ret )
				on RETURN_CODE = "VS_K_ABORT_CMD"
								state abortCmd
			do initForm( &me->ret )
				on RETURN_CODE = "VS_K_ABORT_CMD"
								state abortCmd
			do displayForm( &me->ret )		state start


state start
	filter_mode		EX_ALL_ASCII_MODE
	filter			wfi

		on CLEAR_STACK or
		   TERMINATE	do deleteForm( &me->ret )
				do ms_on_off MS_ON		state terminate

		on EX_FORM_FINISHED do ms_on_off MS_ON		state terminate

		on EX_CMD_KEY or
		   CMD_STRING or
		   ELSE 					state .


state abortCmd
	status_key VS_E_ErrEncCmdTrm
	on ELSE state terminate


at init 	do disable_enable_pkt_menu( 0 )
at delete	do disable_enable_pkt_menu( 1 )
/*----------------------------------------------------------------------------*/
