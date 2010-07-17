/*
	I/STRUCT
	"Add Overlengths To Beam" command.
*/
command_string	VSC_M_VSAdOvLTBm,0,VSAdOvLTBm
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSovrlngCmd
product_name	"$STRUCT"
form		"VSovrLngths.fm",0,0,"-1","-1"
/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "VSmsg.h"
#include "vscmddef.h"
#include "vsdef.h"

state start
	prompt_key	VS_P_IdBmOrGr
	accept_key	VS_P_AccRej
	/*
	 * Reject `frozen' beams.
	 */
	execute 		setupActionHandler(
					&me->ret,
				    	VS_K_noFrozenFeature_LCAH,
				    	VS_m_BEAM )
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	locate_owner		"  LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate_noauto
		on EX_DATA
			do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			state formActive

		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			state formActive

state formActive
	execute		fillForm()
	display_form	0
	mask		"GRm_BACK_UP | GRm_RESTART"
	execute		set_dynamics_in_form( &me->ret, me->forms[0].form_ptr )
	filter		VSget_event_with_dynamics
		on GR_UNKNOWN_TYPE.VS_K_END_STATE
			/*
			 * Form has been checked off.
			 */
			do operation( &me->ret )
				on RETURN_CODE =  "VS_K_RESTART_CMD"
					state .
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do erase_form 0
			do formOpByIndex( 0, VS_FIf_RESET )
			do discard_all_input( &me->ret )
			state terminate
		on GR_UNKNOWN_TYPE.VS_K_CH_STATE
			/*
			 * Execute but don't leave command.
			 */
			do operation( &me->ret )
				on RETURN_CODE =  "VS_K_RESTART_CMD"
					state .
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state start
		on EX_BACK_UP or EX_RESTART
			do discard_all_input( &me->ret )
			state start

at init		do message_key VS_M_VSAdOvLTBm
at delete	do cleanUp()
/*----------------------------------------------------------------------------*/


