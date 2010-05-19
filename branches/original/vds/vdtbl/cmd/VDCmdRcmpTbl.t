/* $Id: VDCmdRcmpTbl.t,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd / VDCmdRcmpTbl.t
 *
 * Description:
 *	State table for the "Recompute table" command
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *
 *	10/05/95	R. Manem	Creation
 *
 * -------------------------------------------------------------------*/


command_string  VDC_M_RcmpTbl,5,VDRcmpTbl
command_table   "vds.cmd"
class           VDCmdCrTbl
super_class     VDS_LOCATE
product_name    "$VDS"
options         "siTC"


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
    message_key			VD_M_RcmpTbl
    prompt_key   		VD_P_IdTbl
    accept_key			VD_P_AccRej
    locate_class 		"VDdrwTbl"
    locate_properties 		"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
    locate_owner  		"LC_RIGID_OWNER | LC_FLEX_COMP"

    filter			vds_locate

    on EX_DATA
	do erase_hilite
	do prompt( "" )

	do is_table_uptodate
	    on RETURN_CODE = VD_ERROR
		state terminate

	do recompute_table
	state terminate

