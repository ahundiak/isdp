/* $Id: frmtxt_read.t,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / frmtxt_read.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: frmtxt_read.t,v $
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
 *	Filename:	frmtxt_read.t
 *	Author:		Ad Zuurhout
 *
 *	Date:		April-1992
 *	Type:		Slic File
 *	Process by:	$EXNUC/bin/slic -isTC frmtxt_read.t
 *	Class:		VDCmdFtxt
 *			./config/commands/VDRdFrmTxt
 *	Form:		none
 *
 *	History:
 *	April	1992	Creation date.
 */


/* ********************************************************** */
/*	CLASS SPECIFICATION				      */
/* ********************************************************** */
command_string	VDC_M_RdFrmTxt, 4, VDRdFrmTxt
command_table	"vds.cmd"
class		VDCmdFtxt
product_name	"$VDS"
options		"isTC"
start_state	start

/* ********************************************************** */
/*	STATE TABLE AREA				      */
/* ********************************************************** */

state_table

#include "grmessage.h"
#include "VDmsg.h"
#include "VDSannot.h"

state start

  message_key	VD_M_RdFrmTxt
  prompt_key	VD_P_OverExist
  filter	get_event

  on EX_BACK_UP							state terminate
  on EX_RJT_MOVEON or EX_STRING
	do get_read_option					state get_file

state get_file
  execute	display_default

  prompt_key	VD_P_EnterFile
  filter	get_event

  on EX_STRING or EX_RJT_MOVEON

	do read_file	
	  on RETURN_CODE = "VD_FTEXT_NO_FILE"	
	    do status_key VD_E_NotFound				state start

	  on RETUNR_CODE = "VD_FTEXT_NOT_READABLE"
	    do status_key VD_E_NotReadable			state start

	  on RETURN_CODE = "VD_FTEXT_SEVERE_ERROR" 
	    do status_key VD_E_SynErrAbort 			state terminate

	  on RETURN_CODE = "VD_FTEXT_SUCCESS"			state terminate
								state .

  on EX_BACK_UP
	do status_key VD_E_CommTerm 				state terminate

