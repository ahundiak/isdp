/*
	I/STRUCT
	"Evaluate Mass Properties" command.
*/
command_string	VSC_M_VSEvMPStEl,0,VSEvMPStEl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSevmaspCmd
product_name	"$STRUCT"
status_display	"VSmassProps.fm","-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start

	prompt_key		VS_P_IdStElOrSet
	accept_key		VS_P_AccRej
	/*
	 * Do not accept joints.
	 */
	execute 		setupActionHandler(
					&me->ret,
					VS_K_filterFeatureNeg_LCAH,
					VS_m_JOINT )
	locate_class		"+VSfeature"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
	/*
	 * Rigid component will be not located by a fence without the
	 * flag LC_RIGID_COMP_PRISM.
	 */
	locate_owner		"  LC_RIGID_COMP
				 | LC_RIGID_COMP_PRISM
				 | LC_RIGID_OWNER
				 | LC_FLEX_COMP
				 | LC_FLEX_OWNER
				 | LC_REF_OBJECTS"
	/*
	 * Accept locate by name.
	 */
	mask			"GRm_DATA | GRm_STRING | GRm_OBJID"
	filter			locate_noauto
		on EX_DATA
			do formOpByPtr( me->status_display_form_ptr,
					VS_FIf_ERASE )
			do store_operand( &me->ret, 0 )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state formActive

		on EX_OBJID
			do formOpByPtr( me->status_display_form_ptr,
					VS_FIf_ERASE )
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do operation( &me->ret )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do discard_all_input( &me->ret )
			state formActive

		on EX_BACK_UP
			do formOpByPtr( me->status_display_form_ptr,
					VS_FIf_ERASE )
			do discard_all_input( &me->ret )	  state start

state formActive
	prompt		""
	filter		get_event
			on EX_FORM_FINISHED		state start
			on EX_CMD_KEY or EX_CMD_STRING	state .

at init   do message_key VS_M_VSEvMPStEl
at wakeup do verifyLogin()
at sleep  do VSsleep(0)
/*----------------------------------------------------------------------------*/
