/* $Id: VDCmdGenFam.t,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $ */

/* I/VDS 
 * 
 * File:     vdequip/fam/VDCmdGenFam.t
 *
 * Description:
 * 	Defines a command object which command creates .f (family) 
 *	and .p (part) ascii files for the loading of a VDS data base. 
 *
 * Depedencies:
 *	VDCmdGenFam.S
 *	VDCmdGenFami.I
 *	VDgenfamfnc.I 
 *
 * Revision History:
 *	$Log: VDCmdGenFam.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
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
# Revision 1.2  1995/02/16  21:41:40  pinnacle
# Replaced: vdequip/fam/VDCmdGenFam.t by jwfrosch r#
#
# Revision 1.1  1995/02/14  19:25:56  pinnacle
# Created: vdequip/fam/VDCmdGenFam.t by azuurhou r#
# rno
#
# Revision 1.1  1995/02/07  22:51:28  pinnacle
# Created: vdequip/fam/VDCmdGenFml.sl by tdumbach r#
#
# Revision 1.1  1995/02/07  20:59:30  pinnacle
# Replacement
#
# Revision 1.1  1994/11/16  20:17:08  pinnacle
# forgotten directory
#
 *
 * History:
 *      25/02/94       Chaya Rao  Created file from ppl file VDgenfamfil.u.
 *
 *      	Changed the form related to the command to give a logical 
 *		workflow.  Added a new .mb file which includes prompts, 
 *		messages, and status information to the command. 
 *
 *	01/10/94	HF
 *
 *		Separated "VDCmdGenFam.S" and "VDCmdGenFami.I" 
 *		from "VDCmdGenFam.sl", which has been renamed
 *		to   "VDCmdGenFam.t"
 */

command_string    VDC_M_VDGnFmFl, 0, VDGnFmFl
class             VDCmdGenFam
super_class       VDS_LOCATE
product_name      "$VDS"
options           "isTC"
command_table     "vds.cmd"
spec_path	  "$VDS/spec"
start_state       start
form              "VDGenFamFil",0,1,"-1","-1"


state_table

#include "VDmsg.h"

state start
    
      message_key	VD_M_VDGnFmFl
      prompt_key	VD_P_VDGnFmSlt
      filter		get_event

      on FORM_FINISHED					state terminate

      on EX_STRING
	do evaluate_input				state .
