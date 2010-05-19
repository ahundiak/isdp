/* $Id: VDCmdExDr.t,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/cmd/VDCmdExDri.t
 *
 * Description:
 *		Drawing extraction from struct objects.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdExDr.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
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
# Revision 1.13  1996/03/01  05:18:52  pinnacle
# Replaced: vddraw/cmd/VDCmdExDr.t for:  by rgade for vds.240
#
# Revision 1.12  1995/08/07  20:57:02  pinnacle
# Replaced: vddraw/cmd/VDCmdExDr.t for:  by azuurhou for vds.240
#
# Revision 1.11  1995/07/29  15:17:16  pinnacle
# Replaced: vddraw/cmd/VDCmdExDr.t for:  by azuurhou for vds.240
#
# Revision 1.10  1995/06/29  15:10:34  pinnacle
# Replaced: vddraw/cmd/VDCmdExDr.t for:  by azuurhou for vds.240
#
# Revision 1.9  1995/05/02  22:55:12  pinnacle
# Replace: vddraw/cmd/VDCmdExDr.t by azuurhou for OPE
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      07/19/93	rmn		Creation
 *	04/28/95	adz		Message/Prompt control
 *	05/02/95	adz		Exit command on CLEAR_STACK/
 *	02/29/96	Ravi		Handling of RJT_MOVE on for setupfile.
 *
 ************************************************************************/


command_string     VDC_M_AssVisPrc, 0, VDOPE_ExDr
class              "VDCmdExDr"
super_class        "VDS_LOCATE"
product_name       "$VDS"
command_table      "vds.cmd"
options            "siTC"

status_display	   "VDdraw","-1","-1"
start_state	   start

/*
 *            state table area
 */

state_table

/*
 * state table resulting values.
 */
#define         VD_K_VIS_OKE            0
#define         VD_K_VIS_ERROR          1

#include "VDmsg.h"
#include "dp.h"

state start
     
     message_key	VD_M_AssVisPrc
     prompt_key		VD_P_AVPGvSupport
     execute		display_default
     filter             get_event

     on GR_UNKNOWN_TYPE.TERMINATE or
	GR_UNKNOWN_TYPE.CLEAR_STACK			state terminate

     on TEXT_VALUE or EX_RJT_MOVEON
	do get_setup_file( & me->ret )
	    on RETURN_CODE = VD_K_VIS_OKE
		do set_locate_filter
		   on RETURN_CODE = VD_K_VIS_OKE	state	loc_objects
							state	.
							state	.

     on STATUS_DISP
	do status_disp()				state	.

     on ELSE
							state	terminate

state loc_objects

     execute		display_setup
     execute		dpLocObjs( &me->ret, 0 , GRhd )

     message_key	VD_M_AssVisPrc
     prompt_key         VD_P_IdElEx
     accept_key         VD_P_AccRej
     locate_class	"+ACncpx,GRclhdr,GRsmhdr"
     locate_owner       "LC_RIGID_OWNER | LC_FLEX_OWNER | 
                         LC_RIGID_COMP  | LC_FLEX_COMP  |
                         LC_REF_OBJECTS | LC_NO_REF_HEADER"

     mask               "GRm_DATA | GRm_RJT_MOVEON | 
                         GRm_SPECIFIED_OBJ | GRm_BACK_UP"

     filter             locate

     on GR_UNKNOWN_TYPE.TERMINATE or
	GR_UNKNOWN_TYPE.CLEAR_STACK			state terminate

     on STATUS_DISP
	do status_disp()				state .

     on EX_DATA or EX_OBJID
	do process_locate
		on SUCCESS				state .
		on ERROR				state terminate
							state .

     on EX_RJT_MOVEON       
	do extract_drw					state loc_objects

     on ELSE						state terminate


at init   do myinit
at wakeup do mywakeup
	  do status_display_button(1)
	  do erase_hilite
at sleep  do mysleep
	  do status_display_button(0)
at delete do mydelete
