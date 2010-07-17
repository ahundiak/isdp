/*
	I/STRUCT
	"Modify Structural Element" command.
*/
command_string	VSC_M_VSMdStEl,0,VSMdStEl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSmdstelCmd
product_name	"$STRUCT"
form		"VSmodStElem.fm",0,0,"-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "VSmsg.h"
#include "vscmddef.h"

state start
	message_key		VS_M_VSMdStEl
	prompt_key		VS_P_IdStElSet
	accept_key		VS_P_AccRej
	/*
	 * Only retain editable elements.
	 */
	execute 		setupActionHandler(
						&me->ret,
						VS_K_isAnEditableFeature_LCAH,
						~0 )
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate

		on EX_DATA	do store_element( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
							state displayForm

		on EX_OBJID	do process_fence( &me->ret )
					on RETURN_CODE = "VS_K_RESTART_CMD"
						state haveError
					on RETURN_CODE = "VS_K_NO_FENCE"
					   do status_key VS_W_NoObjLoc
						state .
							state displayForm


state displayForm
	execute 		update_form( &me->ret )
	display_form		0

		on ELSE 				state manipForm


state manipForm
	prompt_key		VS_P_SelModif
	filter			get_event

		on GR_UNKNOWN_TYPE.VS_K_DROP_ELEM
				do unhilight_gs( &me->ret )
					 	state dropElement

		on EX_BACK_UP	do unhilight_gs( &me->ret )
				do dissolve_gs( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
						state abortCmd
				do erase_form 0
				do reset_form( &me->ret )
							state start


state dropElement
	execute 		setupActionHandler(
						&me->ret,
						VS_K_actionHandlerInCmd_LCAH,
						my_id )
	prompt_key		VS_P_IdElDrop
	accept_key		VS_P_AccRej
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID |
				 GRm_RJT_MOVEON"
	filter			locate

		on GR_UNKNOWN_TYPE.VS_K_DROP_ELEM	state .

		on EX_RJT_MOVEON do hilight_gs( &me->ret )
				 do setupActionHandler(
					&me->ret,VS_K_RESET_LCAH, 0 )
							state -

		on EX_OBJID or EX_DATA	 
				 do drop_element( &me->ret )
					on RETURN_CODE = "VS_K_ABORT_CMD"
						state abortCmd
				 do hilight_gs( &me->ret )
				 do setupActionHandler(
					&me->ret,VS_K_RESET_LCAH, 0 )
				 do update_form( &me->ret )
							state -


state haveError
	status_key VS_E_ErrEncCmdRst
	on ELSE state start


state abortCmd
	status_key VS_E_ErrEncCmdTrm
	on ELSE do waitTimer( 4 ) state terminate

/*----------------------------------------------------------------------------*/
