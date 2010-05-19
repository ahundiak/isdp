/* $Id: frmtxt_wrt.t,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / frmtxt_wrt.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: frmtxt_wrt.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
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
# Revision 1.2  1995/01/06  16:43:36  pinnacle
# Replaced: vdannot/cmd/frmtxt_wrt.t by tdumbach r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 *
 *
 *	Filename:	write_form.t
 *	Author:		Ad Zuurhout
 *
 *	Date:		April - 1992
 *	Type:		Slic File
 *	Process by:	$EXNUC/bin/slic -isTC write_form.t
 *	Class:		VDCmdFtxt
 *			./config/commands/VDWrFrmTxt
 *	Form:		none
 *
 *	History:
 *	April	1992	Creation date.
 */


/* ********************************************************** */
/*	CLASS SPECIFICATION				      */
/* ********************************************************** */

command_string	VDC_M_WrFrmTxt, 5, VDWrFrmTxt
command_table	"vds.cmd"
class		VDCmdFtxt
product_name	"$VDS"
options		"isTC"
start_state	start


/************************************************************************/
/*	STATE TABLE							*/
/************************************************************************/

state_table

#include "grmessage.h"
#include "VDmsg.h"
#include "VDSannot.h"


state start

  execute	formats_defined( &me->ret )
		  on RETURN_CODE = "VD_FTEXT_NOT_WRITEABLE"
		  do status_key VD_E_NoFormat 			state terminate

  message_key	VD_M_WrFrmTxt
  prompt_key	VD_P_FormatFile
  filter	get_event

  on EX_BACK_UP
	do status_key VD_E_CommTerm 				state terminate

  on EX_STRING or EX_RJT_MOVEON
	do write_file	
	  on RETURN_CODE = "VD_FTEXT_SEVERE_ERROR"
		do status_key VD_E_ErrWrtFile			state start

	  on RETURN_CODE = "VD_FTEXT_NOT_WRITEABLE"
		do status_key VD_E_NothWrtFil 			state terminate

	  on RETURN_CODE = "VD_FTEXT_SUCCESS"	 		state terminate
								state terminate
