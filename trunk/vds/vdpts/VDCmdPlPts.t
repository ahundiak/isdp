/* $Id: VDCmdPlPts.t,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $ */

/* I/VDS 
 * 
 * File:     vdpts/VDCmdPlPts.t
 *
 * Description:
 *
 * Depedencies:
 *
 * Revision History:
 *	$Log: VDCmdPlPts.t,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/26  16:49:12  pinnacle
# Replaced: vdpts/VDCmdPlPts.t for:  by v250_int for vds
#
# Revision 1.1  1997/05/30  09:08:32  pinnacle
# initial revision
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	05/30/97	Sundar		Creation Date
 * -------------------------------------------------------------------*/


/* VDC_M_VDPlPts	Place Associative Points From File */
/* VDC_M_VDWrPts	Write Associative Points Into File */

command_string    VDC_M_VDPlPts, 0, VDPlPts
synonym    	  VDC_M_VDWrPts, 1, VDWrPts
class             VDCmdPlPts
super_class       VDS_LOCATE
product_name      "$VDS"
options           "isC"
command_table     "vds.cmd"
spec_path	  "$VDS/spec"
start_state       start


state_table

#include "VDmsg.h"
#include "SMmsg.h"
#include "VDSFilter.h"
#define PLACE                   0
#define WRITE			1
#define VD_K_FILE_ACCEPTED   260
#define VD_K_FILE_CANCELED   261


state start
	on CMD_TYPE = PLACE				state cs_locate
	on CMD_TYPE = WRITE				state get_file_name

state cs_locate
	prompt			"Identify a coordinate system/Move on"
	accept_key		SM_P_AcRes
	locate_display		" ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                          	ALL_WINDOWS  | LC_ERASE_ALL "
	locate_class		"GRbasecs | GRgencs"
	locate_properties	" LC_DP_ONLY | LC_LC_ONLY "
	locate_owner            "LC_RIGID_COMP | LC_RIGID_OWNER | 
				LC_FLEX_COMP | LC_FLEX_OWNER"
	mask			"GRm_STRING | GRm_DATA | GRm_RJT_MOVEON"
	filter	 vds_locate_noauto

        on EX_DATA 
	    do  store_cs 				state get_file_name
	on EX_RJT_MOVEON
	    do store_active_cs				state get_file_name

state get_file_name
	execute         createFileForm( &me->ret )
			on ERROR
				do status "Error encountered"
					state terminate
			on ELSE         state KeyInFileName

state KeyInFileName
	prompt	"Key in name of data file"
	filter          get_event
		on GR_UNKNOWN_TYPE.VD_K_FILE_ACCEPTED
			do fileFormDismissed( VD_K_FILE_ACCEPTED )
				state getCmdType
		on GR_UNKNOWN_TYPE.VD_K_FILE_CANCELED
			do fileFormDismissed( VD_K_FILE_CANCELED )
			state terminate
		on ELSE	state .

state getCmdType
	on CMD_TYPE = PLACE				state place_points
	on CMD_TYPE = WRITE				state write_points

state place_points
	
	execute VDSplace_points( &me->ret )
		on ELSE state terminate

state write_points

	execute	VDSwrite_points( &me->ret )
		on ELSE state terminate

at wakeup       do fileFormOnOffOut( 1 )
at sleep        do fileFormOnOffOut( 0 ) do dehilite
at delete       do fileFormOnOffOut( 2 )

