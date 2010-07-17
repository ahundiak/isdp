/*
	I/STRUCT
	"Replace Stiffener with Beam"
*/
command_string	VSC_M_VSRpStBm,0,VSRpStBm
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSstf2bmCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vscmddef.h"
#include "vsdef.h"

state start
	/*
	 * Set locate action handler : only accept stiffeners among beams.
	 */
	message_key		VS_M_VSRpStBm
	on ELSE	state main

state main
	prompt_key		VS_P_IdStOrGr
	accept_key		VS_P_AccRej
	/*
	 * Reject `frozen' and image beams.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					  VS_m_FRZ_generic
					| VS_m_IMG_generic )
	locate_class		"+VSbeam"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"

	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA	do store_stiffener( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					on RETURN_CODE = "VS_K_ACT_SUCCESS"
						do operation() state .
					state .

		on EX_OBJID	do process_fence( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					on RETURN_CODE = "VS_K_NO_FENCE"
					   do status_key VS_W_NoObjLoc
						state .
					on RETURN_CODE = "VS_K_ACT_SUCCESS"
						do operation() state .
					state .

state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE do rmLastLocObjs( 0 )	state main
/*----------------------------------------------------------------------------*/
