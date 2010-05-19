/* $Id: VDCmdMdTbl.t,v 1.2 2002/05/15 17:46:46 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDCmdMdTbl.t
 *
 * Description:
 *	State table for the "Modify Table" command
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *
 *	05/12/95	R. Manem	Creation
 *	07/14/95	R. Manem	Summarizing and sorting
 *	10/02/95	R. Manem	Warning message for stop button
 *	10/10/95	R. Manem	Check table dependency
 * 	12/15/97	vini 		added VDgettherow
 *	10/11/99	Ming		TR179900802
 *	05/15/02	ylong		TR6281
 *					at state form_display_checking, 
 *					do init_from_table before process_form
 *					to keep consistent for table and form.
 * -------------------------------------------------------------------*/


command_string  VDC_M_VDMdTbl,1,VDMdTbl
command_table   "vds.cmd"
class           VDCmdCrTbl
super_class     VDS_LOCATE
product_name    "$VDS"
options         "siTC"

form            "VDcreateTable",0,0,"-1","-1"


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
    message_key  		VD_M_VDMdTbl
    prompt  	 	 	" Identify Table or Row "	
    accept_key			VD_P_AccRej
    locate_class 		"VDdrwTbl,VDdrwTblRow"
    locate_properties 		"LC_DP_ONLY | LC_LC_ONLY | LC_WRITE_ONLY"
    locate_owner  		"LC_RIGID_OWNER | LC_FLEX_COMP"

    filter			vds_locate

    on EX_DATA

	do prompt ""
	do status "Processing.."

	do VDgettherow

	do store_and_process_table
	    on RETURN_CODE = VD_RESTART_CMD
		state .
	    on RETURN_CODE = VD_ERROR
		state terminate

	do is_table_uptodate
	    on RETURN_CODE = VD_ERROR
		state terminate

	do get_tbl_format
	    on RETURN_CODE = VD_ERROR
		state terminate

	do init_create_form				
	    on RETURN_CODE = VD_ERROR
		state terminate

	do init_from_table
	    on RETURN_CODE = VD_ERROR
		state terminate

	do get_tbl_type
	    on RETURN_CODE = VD_DRW_TBLTYPE_BOM
		state loc_objects

	    on RETURN_CODE = VD_DRW_TBLTYPE_GEN
		state process_form
    	state .


state loc_objects
    message_key  		VD_M_VDMdTbl
    prompt_key   		VD_P_IdElAdMvOn
    accept_key   		VD_P_AccRej

    locate_class 		"+ACncpx, GRclhdr, GRsmhdr"
    locate_properties 		"LC_DP_ONLY | LC_LC_ONLY"
    locate_owner  		"LC_RIGID_OWNER | LC_FLEX_COMP |
				LC_RIGID_COMP  | LC_FLEX_OWNER | LC_REF_OBJECTS"

    filter  			vds_locate

    on EX_DATA or EX_OBJID
	do process_locate
	    on RETURN_CODE = VD_RESTART_CMD 		
		state .
	    on RETURN_CODE = VD_ERROR 			
		state terminate

	do prompt ""
	do status "Processing.."
	do setup_rowList
	    on RETURN_CODE = VD_ERROR			state terminate

	do summ_and_sort_objs
	    on RETURN_CODE = VD_ERROR			state terminate

	do update_form			
	    on RETURN_CODE = VD_ERROR			state terminate

	do validate_assoc_updmode
	    on RETURN_CODE = VD_ERROR			state terminate

	do get_existing_cs
	    on RETURN_CODE = VD_ERROR			state terminate

	do disconnect_rows
	    on RETURN_CODE = VD_ERROR 			state terminate
	    
	do handle_row_delete
	    on RETURN_CODE = VD_ERROR 			state terminate

	do process_ads_tblname
	    on RETURN_CODE = VD_ERROR 			state terminate

	do status "WARNING: Do not hit the stop button"

	do place_table
	    on RETURN_CODE = VD_ERROR 			state terminate

  	state form_display_checking

    on EX_BACK_UP					state -

    on EX_RJT_MOVEON or EX_RESET			state process_form


state form_display_checking
    message_key           VD_M_VDMdTbl
    prompt                "Move-on for displaying form/Back-up for termination" 
    dynamics              off
    filter                get_event

    on EX_RJT_MOVEON

	do init_from_table
	    on RETURN_CODE = VD_ERROR
		state terminate

        state process_form

    on EX_BACK_UP
        state terminate

    on ELSE
        state .


	
state process_form
    message_key  		VD_M_VDMdTbl
    prompt_key   		VD_P_ModForm
    status			""
    display_form 		0
    filter 			vds_get_event

    on GR_UNKNOWN_TYPE.VD_FORM_ACCEPT
	do erase_form 0

	do prompt ""
	do status "Processing.."
	do validate_assoc_updmode
	    on RETURN_CODE = VD_ERROR
		state terminate

	do get_existing_cs
	    on RETURN_CODE = VD_ERROR
		state terminate

	do disconnect_rows
	    on RETURN_CODE = VD_ERROR
		state terminate
	    
	do handle_row_delete
	    on RETURN_CODE = VD_ERROR
		state terminate

	do process_ads_tblname

	do status "WARNING: Do not hit the stop button"

	do place_table
    	state terminate

    on GR_UNKNOWN_TYPE.VD_FORM_CANCEL
	do erase_form 0
    	state terminate

at init 	do validate_assoc_updmode
		do my_init
at delete	do erase_hilite
		do status ""
		do wrap_up

