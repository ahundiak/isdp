/* $Id: VDCmdPlHdr.t,v 1.5 2001/05/23 13:17:01 paul_noel Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDCmdPlHdr.t
 *
 * Description:
 *	State table for the "Place Table Header" command
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *
 *	04/14/95	R. Manem	Creation
 *
 * -------------------------------------------------------------------*/


command_table   "vds.cmd"
class           VDCmdPlHdr
super_class     VDS_LOCATE
product_name    "$VDS_PATH"
options         "siTC"
start_state     start

command_string  VDC_M_VDPlHdr,VD_CMD_TBL_HDR,VDPlHdr
synonym         "Create Table by Stage",VD_CMD_STBL_PL,VDPlSTbl
synonym         "Create Table by Import",VD_CMD_ITBL_PL,VDPlITbl

form		VD_PLSTBL_FORM_NAME,0,0,"-1","-1"


/*---------------------
 * state table area
 */


state_table

#include "exdef.h"
#include "VDmsg.h"
#include "VDCmdDef.h"
#include "VDSFilter.h"
#include "VDtblCmdDef.h"

/* ======================================================================== */

state start
  on CMD_TYPE = VD_CMD_TBL_HDR
     state start_pltblhdr

  on CMD_TYPE = VD_CMD_STBL_PL
     state start_plstagetbl

  on CMD_TYPE = VD_CMD_ITBL_PL
     state start_plimporttbl

/* ======================================================================== */

state start_pltblhdr
    message_key  		VD_M_VDPlHdr
    prompt_key   		VD_P_ModForm

    display_form 		0
    filter 			vds_get_event

    on GR_UNKNOWN_TYPE.VD_FORM_EXECUTE
	do erase_form 0
	state getCoordSysExecute

    on GR_UNKNOWN_TYPE.VD_FORM_ACCEPT
	do erase_form 0
	state getCoordSys

    on GR_UNKNOWN_TYPE.VD_FORM_CANCEL
	do erase_form 0
    state terminate

/* ======================================================================== */

state start_plstagetbl
    message  			"Create Table by Stage"
    prompt_key   		VD_P_ModForm

    display_form 		0
    filter 			vds_get_event

    on GR_UNKNOWN_TYPE.VD_FORM_EXECUTE
        do erase_form 0
        state getCoordSysExecute

    on GR_UNKNOWN_TYPE.VD_FORM_ACCEPT
	do erase_form 0
	state getCoordSys

    on GR_UNKNOWN_TYPE.VD_FORM_CANCEL
	do erase_form 0

    state terminate

/* ======================================================================== */

state start_plimporttbl
    message	  		"Create Table by Import"
    prompt_key   		VD_P_ModForm

    display_form 		0
    filter 			vds_get_event

    on GR_UNKNOWN_TYPE.VD_FORM_EXECUTE
        do erase_form 0
        state getCoordSysExecute

    on GR_UNKNOWN_TYPE.VD_FORM_ACCEPT
	do erase_form 0
	state getCoordSys

    on GR_UNKNOWN_TYPE.VD_FORM_CANCEL
	do erase_form 0
    state terminate

/* ======================================================================== */

state getCoordSys
    message_key  		VD_M_VDPlHdr
    prompt_key   		VD_P_VDIdCS
    accept_key   		VD_P_AccRej

    locate_class 		"+GRgencs"
    locate_properties 		"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
    locate_owner  		"LC_RIGID_OWNER | LC_FLEX_COMP |
				LC_RIGID_COMP  | LC_FLEX_OWNER | LC_REF_OBJECTS"

    filter  			vds_locate

    on EX_DATA
	do prompt ""
	do status "Processing.."
	do store_cs
	do placeTblHdr
	do status ""
           on CMD_TYPE = VD_CMD_TBL_HDR
              state .
    state terminate

/* ======================================================================== */

state getCoordSysExecute
    message_key                 VD_M_VDPlHdr
    prompt_key                  VD_P_VDIdCS
    accept_key                  VD_P_AccRej

    locate_class                "+GRgencs"
    locate_properties           "LC_DP_ONLY | LC_LC_ONLY | LC_RW"
    locate_owner                "LC_RIGID_OWNER | LC_FLEX_COMP |
                                LC_RIGID_COMP  | LC_FLEX_OWNER | LC_REF_OBJECTS"

    filter                      vds_locate

    on EX_DATA
        do prompt ""
        do status "Processing.."
        do store_cs
        do placeTblHdr
        do status ""
           on CMD_TYPE = VD_CMD_TBL_HDR		state start_pltblhdr
	   on CMD_TYPE = VD_CMD_STBL_PL		state start_plstagetbl
	   on CMD_TYPE = VD_CMD_ITBL_PL		state start_plimporttbl

	state terminate

/* ======================================================================== */

at init 	do my_init
		do init_form

at delete	do erase_hilite
		do wrap_up

