/*
	I/STRUCT
	"Extend Stiffener Beyond Limiting Surfaces" and
	"Revert Extended Stiffener To Original Size" commands.
*/
command_string	VSC_M_VSExStByLS,0,VSExStByLS
synonym 	VSC_M_VSRvExStOS,1,VSRvExStOS
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSextstfCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vscmddef.h"

#define TRUE	1
#define FALSE	0

state start
	on CMD_TYPE = 0
		do message_key	VS_M_VSExStByLS
		/*
		 * Only accept not already extended stiffeners.
		 */
		do setupActionHandler( &me->ret,
				       VS_K_isAnExtOrOrgStiffener_LCAH,
				       FALSE )
		do setupAHrejectSts( VS_W_StfAlreadyExt )
		state main

	on CMD_TYPE = 1
		do message_key	VS_M_VSRvExStOS
		/*
		 * Only accept already extended stiffeners.
		 */
		do setupActionHandler( &me->ret,
				       VS_K_isAnExtOrOrgStiffener_LCAH,
				       TRUE )
		do setupAHrejectSts( VS_W_StfAlreadyRvt )
		state main


state main
	prompt_key		VS_P_IdStOrGr
	accept_key		VS_P_AccRej
	locate_class		"VSbeam"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	/*
	 * Accept locate by name or object.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret )	state .
			   do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret )	state .
			   do discard_all_input( &me->ret )		state .

		on EX_OBJID
			   do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret )	state .
			   do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret )	state .
			   do discard_all_input( &me->ret )		state .

/*----------------------------------------------------------------------------*/
