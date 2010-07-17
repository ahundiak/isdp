/*
	I/STRUCT
	"Select Side of Plate" event generator.
*/
command_string	VSC_M_VSSlSdPl,0,VSSlSdPl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSsdofplCmd
product_name	"$STRUCT"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	execute 		init_cmd( &me->ret )
	message_key		VS_M_VSSlSdPl
	prompt_key		VS_P_IdPlate
	accept_key		VS_P_AccRej
	execute 		setupActionHandler(	&me->ret,
							VS_K_filterFeature_LCAH,
							VS_m_PLATE )
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_RJT_MOVEON"
	filter			locate

		on EX_RJT_MOVEON				state terminate

		on EX_DATA or
		   EX_OBJID	do store_plate( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
								state haveError
				do swap_side( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
								state haveError
								state SelectSide


state SelectSide
	execute 		hilight_side( &me->ret )
	prompt_key		VS_P_AccSwapSide
	filter			get_event

		on EX_BACK_UP	do unhilight_side( &me->ret )
				do rmLastLocObjs( 0 )
								state -

		on EX_RJT_MOVEON do unhilight_side( &me->ret )
				 do swap_side( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
								state haveError
								state .

		on EX_DATA	 do unhilight_side( &me->ret )
				 do put_side_on_queue( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
								state terminate
								state terminate


state haveError
	status_key VS_E_ErrEncCmdTrm
	on ELSE 						state terminate

at delete do unhilight_side( &me->ret )

/*----------------------------------------------------------------------------*/
