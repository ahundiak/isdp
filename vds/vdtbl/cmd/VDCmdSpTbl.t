/* $Id: VDCmdSpTbl.t,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDCmdSpTbl.t
 *
 * Description:
 *	State table for the "Split Table" command
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *
 *	05/26/95	R. Manem	Creation
 * 	12/15/97	vini		added VDgettherow
 *
 * -------------------------------------------------------------------*/


command_string  VDC_M_VDSpTbl,2,VDSpTbl
command_table   "vds.cmd"
class           VDCmdCrTbl
super_class     VDS_LOCATE
product_name    "$VDS"
options         "siTC"

form            "VDsplitTable",0,0,"-1","-1"


/*---------------------
 * state table area
 */


state_table

#include "exdef.h"
#include "VDmsg.h"
#include "VDCmdDef.h"
#include "VDtblCmdDef.h"
#include "VDSFilter.h"

state start
    message_key  		VD_M_VDSpTbl
    prompt_key   		VD_P_IdTbl
    accept_key			VD_P_AccRej
    locate_class 		"VDdrwTbl"
    locate_properties 		"LC_DP_ONLY | LC_LC_ONLY | LC_WRITE_ONLY"
    locate_owner  		"LC_RIGID_OWNER | LC_FLEX_COMP"

    filter			vds_locate

    on EX_DATA
	
	do VDgettherow

	do store_and_process_table
	    on RETURN_CODE = VD_RESTART_CMD
		state .
	    on RETURN_CODE = VD_ERROR
		state terminate

	do init_from_table
	    on RETURN_CODE = VD_ERROR
		state terminate

	do init_split_form				
	    on RETURN_CODE = VD_ERROR
		state terminate

    	state process_form

state process_form
    message_key  		VD_M_VDSpTbl
    prompt_key   		VD_P_ModForm
    display_form 		0
    filter 			vds_get_event

    on GR_UNKNOWN_TYPE.VD_FORM_ACCEPT
	do erase_form 0

	do get_existing_cs
	    on RETURN_CODE = VD_ERROR
		state terminate

	do check_to_locate_cs
	    on RETURN_CODE = VD_TBL_LOCATE_CS
		state getCoordSys

	    on RETURN_CODE = VD_TBL_NO_CS_NEEDED
		do prompt ""
		do status "Processing.."

		do disconnect_rows
		    on RETURN_CODE = VD_ERROR
			state terminate

		do place_headers
		    on RETURN_CODE = VD_ERROR
			state terminate
		
		do place_table

		state terminate
    	state .

    on GR_UNKNOWN_TYPE.VD_FORM_CANCEL
	do erase_form 0
    	state terminate

    on GR_UNKNOWN_TYPE.VD_TBL_LOCATE_ROW
	do erase_form 0
    	state locate_row

state locate_row
    message_key  		VD_M_VDSpTbl
    prompt_key   		VD_P_IdTblRow
    accept_key   		VD_P_AccRej

    locate_class 		"VDdrwTblRow"
    locate_properties 		"LC_DP_ONLY | LC_LC_ONLY "
    locate_owner  		"LC_RIGID_OWNER | LC_FLEX_OWNER | 
					LC_RIGID_COMP | LC_FLEX_COMP"

    filter			vds_locate

    on EX_DATA
	do process_rowno
	state process_form

    on EX_RJT_MOVEON or EX_RESET
	state process_form


state getCoordSys
    message_key  		VD_M_VDSpTbl

/* prompt is set by check_to_locate_cs action */

    accept_key   		VD_P_AccRej

    locate_class 		"+GRgencs"
    locate_properties 		"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
    locate_owner  		"LC_RIGID_OWNER | LC_FLEX_COMP |
				LC_RIGID_COMP  | LC_FLEX_OWNER | LC_REF_OBJECTS"

    filter  			vds_locate

    on EX_DATA
	do store_cs

	do check_to_locate_cs
	    on RETURN_CODE = VD_TBL_LOCATE_CS
		state .

	    on RETURN_CODE = VD_TBL_NO_CS_NEEDED
		do prompt ""
		do status "Processing.."

		do disconnect_rows
		    on RETURN_CODE = VD_ERROR
			state terminate

		do place_headers
		    on RETURN_CODE = VD_ERROR
		    state terminate

		do place_table
		state terminate

        state terminate

/*
    on EX_BACKUP
	do clear_cs_list
	state process_form
*/

at init 	do my_init
at delete	do erase_hilite
		do status ""
		do wrap_up

