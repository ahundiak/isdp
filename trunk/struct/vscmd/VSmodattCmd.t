/*
	I/STRUCT
	"Modify Attributes of Structural Element" command.
*/
command_string	VSC_M_VSMdAtStEl,0,VSMdAtStEl
command_table	"vs.cmd"
spec_path	"$STRUCT/spec"
class		VSmodattCmd
product_name	"$STRUCT"
form		"VSmodUsrAtt.fm",0,0,"-1","-1"

/*-STATE TABLE----------------------------------------------------------------*/
state_table

#include "lcdef.h"
#include "VSmsg.h"
#include "vsdef.h"
#include "vscmddef.h"

state start
	prompt_key	VS_P_IdStElOrSet
	accept_key	VS_P_AccRej
	execute                 setupActionHandler(
                                        &me->ret,
                                        VS_K_filterFeatureNeg_LCAH,
					VS_m_IMG_generic )
        
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
			state getAttr

		on EX_OBJID
			do process_fence( &me->ret, VS_K_OPRND )
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			state getAttr

state getAttr
	execute		dspAttrs( 0 )
	display_form	0
	prompt_key	VS_P_KyInAttr
	mask		"GRm_BACK_UP | GRm_RESTART"
	execute		set_dynamics_in_form( &me->ret, me->forms[0].form_ptr )
	filter		VSget_event_with_dynamics

		on GR_UNKNOWN_TYPE.VS_K_END_STATE
			/*
			 * Form has been checked off.
			 */
			do operation( &me->ret )
				/*
				 * Bad user input in form.
				 */
				on RETURN_CODE =  "VS_K_RESTART_CMD"
					state .
				on RETURN_CODE != "VS_K_ACT_SUCCESS"
					do handleError( me->ret ) state .
			do erase_form 0
			do formOpByIndex( 0, VS_FIf_RESET )
			do discard_all_input( &me->ret )
			state start

		on EX_BACK_UP or EX_RESTART
			do discard_all_input( &me->ret )
			state start

at init		do message_key	VS_M_VSMdAtStEl
at delete	do cleanUp()
/*----------------------------------------------------------------------------*/
