/* $Id: VDCSlAsCp.t,v 1.3 2001/01/16 14:26:31 art Exp $ */

/* *****************************************************************************
   I/VDS

   File:     vds/vdat/pocket/VDCSlAsCp.t

   Purpose:

   This file is input to the slic processor to create the .T file,
   ${VDS}/config/commands/VDCSlAsCp.

   Description:

   The command class, VDCSlAsCp, collects assembly tree components (leaves, 
   pieces) as a saveset which can then be input into another command.

   Dependencies:

   Form:    SelAssyCmp.frm, "Select Assembly Components"

   VDS_LOCATE

   Note: 
   
   The statement, "on 1 state .", allows entry into the form_notification 
   method.
   EX_BACK_UP           double click, Right mouse button
   EX_RJT_MOVEON        single click, Right mouse button
   Without above two entries, status bar reads, "Ignoring BACK_UP input" or
                                                "Ignoring REJECT/MOVEON" input.
   (toggle cmd stack    double click, Left  mouse button, always implicit)

   keyword, "form", uses CEO.init to call FIf_new, FIf_set_cmd_oid_os and
   FIf_set_initial_notification_routine


   Revision History:

        $Log: VDCSlAsCp.t,v $
        Revision 1.3  2001/01/16 14:26:31  art
        sp merge

        Revision 1.2  2001/01/11 21:01:17  art
        sp merge

# Revision 1.2  2000/05/04  13:51:20  pinnacle
# Replaced: vds/vdat/pocket/VDCSlAsCp.t for:  by impd252 for Service Pack
#
# Revision 1.1  2000/04/10  19:03:32  pinnacle
# ah
#
# Revision 1.2  2000/03/09  16:59:10  pinnacle
# ylong
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/04/10  20:24:20  pinnacle
# TR179800633
#
# Revision 1.4  1998/01/09  21:38:42  pinnacle
# AssyTree
#
# Revision 1.3  1997/12/29  15:04:42  pinnacle
# added "on EX_FORM_FINISHED" statement
#
# Revision 1.2  1997/12/19  15:44:02  pinnacle
# took out unnecessary code, added note statements
#
# Revision 1.1  1997/12/18  20:57:26  pinnacle
# Assembly Tree: slic file for Select Assembly Component command, new
#

   History:

   MM/DD/YY  AUTHOR  DESCRIPTION
  
   12/16/97  EJM     Created this file.
 * 04/10/98  ah      TR179800633 Add ability to specify 2d view (state locate_view)
   03/09/00  ylong   TR179901080 Changed prompt string for Extrat Drawing View
			and checking commands
***************************************************************************** */
/*---------------------
 * class specification
 */


command_string	VDC_M_SlAsCp,0,VDSlAsCp
command_table	"vds.cmd"
class		VDCSlAsCp
super_class     VDS_LOCATE
product_name	"$VDS"
options         "siTC"  /* suppress .S, i.I, output .T, update command_table  */

form		"VDatPocket.frm",0,0,"-1","-1"

start_state  form_info

/*---------------------
 * state table area
 */


state_table


#include "exdef.h"
#include "VDmsg.h"

/* -------------------------------------------------------
 * Locate Drawing View
 */
state locate_view

  prompt		"Select component within drawing view"
  locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
  locate_owner         "LC_RIGID_COMP | LC_RIGID_OWNER |
                         LC_FLEX_COMP | LC_FLEX_OWNER  | LC_REF_OBJECTS"
  locate_eligible      "+VDSroot"
  filter		locate

  on EX_DATA
    do VDCpickedView(&me->ret,1)
    on RETURN_CODE = 1 				state terminate
                       				state terminate

  on EX_RJT_MOVEON				state .
    
  on EX_BACK_UP					state terminate

/* ----------------------------------------
 * Main Form Processing
 */
state form_info
     prompt_key		VD_P_SelSet
     filter		get_event

     on EX_BACK_UP				state terminate

     on EX_FORM_FINISHED
	do VDCcheckCommands(&me->ret)
	on RETURN_CODE = 1			state locate_view
	   do VDCpickedView(&me->ret,0)		state terminate

	on ELSE
		do VDCpickedView(&me->ret,0)
		on RETURN_CODE = 1 		state terminate
						state terminate


      on 1 					state .

at init		do message_key	VD_M_SlAsCp







