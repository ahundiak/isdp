/* $Id: frmtxt_crt.t,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / frmtxt_crt.t
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: frmtxt_crt.t,v $
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
 *	Filename:	frmtxt_crt.t
 *	Author:		Ad Zuurhout
 *
 *	Date:		April 1992
 *	Type:		Slic File
 *	Process by:	$EXNUC/bin/slic -isCT frmtxt_crt.t
 *
 *	Description:
 *
 *	  Slic file to produce a command object which creates format_text 
 *	  expressions.
 *	
 *	  This command locates a macro object and displays the defined
 *	  formatted text expressions in the form.
 *	  This command permits to create new expressions.
 *
 *	History:
 *	April	1992	Creation date.
 *
 */


/* ********************************************************** */
/*	CLASS SPECIFICATION				      */
/* ********************************************************** */

command_string	VDC_M_CrFrTx, 0, VDCrFrTx
command_table	"vds.cmd"
class		VDCmdFtxt
product_name	"$VDS"
options		"isTC"
start_state	start

form		"VDCrFrmTxt",0,0,"-1","-1"

/************************************************************************/
/*	STATE TABLE							*/
/************************************************************************/
									
state_table

#include "grmessage.h"
#include "VDmsg.h"
#include "VDSannot.h"

state start

   message_key		VD_M_CrFrTx
   prompt_key		VD_P_Locate
   dynamics		off 
   locate_display	" ELEM_HILIGHT "
   locate_class		"+ACcpx"
   locate_owner		"LC_FLEX_COMP | LC_REF_OBJECTS | LC_RIGID_COMP"
   locate_properties	" LC_DP_ONLY | LC_LC_ONLY "
   accept_key		VD_P_AccRej
   relocate_key		VD_P_Relocate
   mask			"GRm_DATA | GRm_RJT_MOVEON | GRm_STRING"
   filter		locate
   
   on EX_RJT_MOVEON					state terminate

   on EX_DATA
	do process_locate
		on ERROR				state  .
							state process_object

   on EX_STRING
	do translate_name
		on ERROR
		  do status_key VD_E_BadTrans		state .
							state process_object

state process_object

  execute process_object( &me->ret ) 
    on RETURN_CODE = MSFAIL				state -
    on RETURN_CODE = MSSUCC				state Get_Form

state Get_Form

   prompt_key		VD_P_EnterData
   dynamics		off
   filter		get_event
  
   on EX_BACK_UP or EX_RJT_MOVEON			state .

   on EX_DATE						state .

   on GR_UNKNOWN_TYPE.VD_FTEXT_FORM_INFO
	do erase_form 0
	do VDS_FormReturn( &me->ret )
	  on RETURN_CODE = VD_FTEXT_CANCEL		state start
	  on RETURN_CODE = VD_FTEXT_ACCEPT		state start	
	  on RETURN_CODE = VD_FTEXT_TERMINATE		state terminate	
							state start
